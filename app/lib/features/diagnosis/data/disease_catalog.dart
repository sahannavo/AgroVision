import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle, AssetBundle;

import '../domain/disease_class.dart';

/// Single disease catalog entry mapped directly to assets/data/disease_catalog.json schema.
@immutable
class DiseaseCatalogEntry {
  final String label;
  final String crop;
  final String displayName;
  final String scientificName;
  final String severityHint;
  final String description;
  final List<String> actionSteps;
  final List<String> prevention;
  final bool isHealthy;

  const DiseaseCatalogEntry({
    required this.label,
    required this.crop,
    required this.displayName,
    required this.scientificName,
    required this.severityHint,
    required this.description,
    required this.actionSteps,
    required this.prevention,
    this.isHealthy = false,
  });

  factory DiseaseCatalogEntry.fromJson(Map<String, dynamic> json) {
    return DiseaseCatalogEntry(
      label: json['label'] as String? ?? 'Unknown',
      crop: json['crop'] as String? ?? DiseaseCatalog.extractCrop(json['label'] as String? ?? ''),
      displayName: json['displayName'] as String? ?? DiseaseCatalog.formatDisplayName(json['label'] as String? ?? ''),
      scientificName: json['scientificName'] as String? ?? 'Solanaceae pathology',
      severityHint: json['severityHint'] as String? ?? 'moderate',
      description: json['description'] as String? ?? 'No description available for this condition.',
      actionSteps: (json['actionSteps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Isolate affected foliage.', 'Avoid overhead irrigation.', 'Consult local extension officer.'],
      prevention: (json['prevention'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Practice crop rotation.', 'Ensure proper airflow and spacing.', 'Use disease-free seed.'],
      isHealthy: json['isHealthy'] as bool? ?? false,
    );
  }

  /// Safe generic fallback entry returned when a model label has no catalog entry.
  /// Logs a warning to the console and ensures the application never crashes.
  factory DiseaseCatalogEntry.genericFallback(String label) {
    debugPrint('WARNING: Label "$label" missing from disease catalog. Using safe generic fallback.');
    final crop = DiseaseCatalog.extractCrop(label);
    final isHealthy = label.toLowerCase().contains('healthy');

    return DiseaseCatalogEntry(
      label: label,
      crop: crop,
      displayName: DiseaseCatalog.formatDisplayName(label),
      scientificName: isHealthy ? '$crop (Normal Growth)' : 'Unspecified foliar condition',
      severityHint: isHealthy ? 'low' : 'moderate',
      description: isHealthy
          ? 'The foliage appears healthy with normal vegetative development and no critical pathogen symptoms.'
          : 'A foliar symptom has been identified. Monitor crop progression carefully and consult local agricultural extension officers.',
      actionSteps: isHealthy
          ? const [
              'Continue routine field scouting across lower and upper leaf surfaces.',
              'Maintain standard irrigation schedules and balanced fertilizer intervals.',
              'Log regular scans in history to track vegetative vitality.'
            ]
          : const [
              'Isolate and monitor affected plant rows to observe symptom progression.',
              'Water at the base or through drip irrigation to prevent moisture on leaves.',
              'Consult your local Department of Agriculture extension officer with a leaf sample.'
            ],
      prevention: isHealthy
          ? const [
              'Maintain optimal soil moisture and aeration.',
              'Adhere to recommended pruning, weeding, and mulching guidelines.',
              'Keep field perimeters free of wild nightshade weeds.'
            ]
          : const [
              'Maintain recommended plant spacing for adequate canopy ventilation.',
              'Avoid overhead watering during cool or humid conditions.',
              'Practice 3-year crop rotation with non-Solanaceae crops.'
            ],
      isHealthy: isHealthy,
    );
  }

  /// Maps the canonical label string to the corresponding domain [DiseaseClass] enum value.
  DiseaseClass get diseaseClass => DiseaseCatalog.mapToDiseaseClass(label);

  /// Converts this catalog entry into a rich [DiseaseInfo] entity.
  DiseaseInfo toDiseaseInfo() {
    return DiseaseInfo(
      diseaseClass: diseaseClass,
      displayName: displayName,
      scientificName: scientificName,
      description: description,
      recommendedActionSteps: actionSteps,
      preventionTips: prevention,
      isHealthy: isHealthy,
    );
  }
}

/// Catalog loader and lookup table for agronomic disease information.
class DiseaseCatalog {
  final Map<String, DiseaseCatalogEntry> _entries;

  const DiseaseCatalog(this._entries);

  /// Total count of catalog entries.
  int get length => _entries.length;

  /// All known canonical labels in this catalog.
  Iterable<String> get labels => _entries.keys;

  /// Creates a [DiseaseCatalog] by decoding a JSON string.
  factory DiseaseCatalog.fromJsonString(String jsonString) {
    final decoded = json.decode(jsonString);
    if (decoded is! List) {
      throw FormatException('Expected JSON array of disease catalog entries, got ${decoded.runtimeType}');
    }
    final map = <String, DiseaseCatalogEntry>{};
    for (final item in decoded) {
      if (item is Map<String, dynamic>) {
        final entry = DiseaseCatalogEntry.fromJson(item);
        map[entry.label] = entry;
      }
    }
    return DiseaseCatalog(map);
  }

  /// Asynchronously loads the catalog from assets with a filesystem fallback for unit test environments.
  static Future<DiseaseCatalog> loadFromAsset({
    AssetBundle? bundle,
    String assetPath = 'assets/data/disease_catalog.json',
  }) async {
    String jsonString;
    try {
      final effectiveBundle = bundle ?? rootBundle;
      jsonString = await effectiveBundle.loadString(assetPath);
    } catch (_) {
      // In headless test environments rootBundle may fail; attempt direct filesystem read
      final file = File(assetPath);
      if (file.existsSync()) {
        jsonString = await file.readAsString();
      } else {
        final nestedFile = File('app/$assetPath');
        if (nestedFile.existsSync()) {
          jsonString = await nestedFile.readAsString();
        } else {
          debugPrint('WARNING: Catalog asset not found at $assetPath. Using empty catalog fallback.');
          return const DiseaseCatalog({});
        }
      }
    }
    return DiseaseCatalog.fromJsonString(jsonString);
  }

  /// Synchronously loads from a filesystem file.
  factory DiseaseCatalog.fromFileSync(File file) {
    final jsonString = file.readAsStringSync();
    return DiseaseCatalog.fromJsonString(jsonString);
  }

  /// Looks up a catalog entry by its exact canonical label string.
  /// If missing, logs a warning and returns a safe generic fallback.
  DiseaseCatalogEntry lookup(String label) {
    final entry = _entries[label];
    if (entry != null) {
      return entry;
    }
    return DiseaseCatalogEntry.genericFallback(label);
  }

  /// Returns true if the exact label is registered in the catalog.
  bool containsLabel(String label) => _entries.containsKey(label);

  /// Maps a canonical label (e.g. `Tomato___Early_blight`) to domain [DiseaseClass].
  static DiseaseClass mapToDiseaseClass(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('healthy')) {
      return DiseaseClass.healthy;
    }
    if (lower.contains('nitrogen_deficiency')) {
      return DiseaseClass.nitrogenDeficiency;
    }
    if (lower.contains('early_blight')) {
      return DiseaseClass.earlyBlight;
    }
    if (lower.contains('late_blight')) {
      return DiseaseClass.lateBlight;
    }
    if (lower.contains('bacterial_spot')) {
      return DiseaseClass.bacterialSpot;
    }
    if (lower.contains('leaf_curl') || lower.contains('curl')) {
      return DiseaseClass.leafCurl;
    }
    // Agronomic fallbacks for extended 18-class model classes:
    // Fungal foliar spots (Leaf Mold, Septoria, Target Spot) map to earlyBlight
    if (lower.contains('leaf_mold') || lower.contains('septoria') || lower.contains('target_spot')) {
      return DiseaseClass.earlyBlight;
    }
    // Viral/pest distortion (Spider mites, Tomato mosaic virus) map to leafCurl
    if (lower.contains('spider_mites') || lower.contains('mosaic_virus')) {
      return DiseaseClass.leafCurl;
    }
    return DiseaseClass.earlyBlight;
  }

  /// Extracts crop name prefix from canonical label (e.g. `Tomato___Early_blight` -> `Tomato`).
  static String extractCrop(String label) {
    if (label.contains('___')) {
      final cropPart = label.split('___').first.trim();
      if (cropPart.isNotEmpty) return cropPart;
    }
    return 'Nightshade';
  }

  /// Formats a readable display name from a canonical label string.
  static String formatDisplayName(String label) {
    var raw = label;
    if (raw.contains('___')) {
      raw = raw.split('___').last;
    }
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ')
        .trim();
  }
}
