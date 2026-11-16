import 'dart:convert';
import 'package:flutter/services.dart';
import 'planting_recommendation.dart';

/// Explicit named scoring weights for the multi-criteria agronomic evaluation engine.
///
/// Documented for University Report Section 5 (System Architecture & Algorithmic Design):
/// - Soil suitability: 35%
/// - Seasonal alignment (Maha / Yala): 30%
/// - Regional temperature compatibility: 20%
/// - Rain and moisture requirement match: 15%
abstract final class AdvisorScoringWeights {
  static const double soilWeight = 35.0;
  static const double seasonWeight = 30.0;
  static const double temperatureWeight = 20.0;
  static const double rainWeight = 15.0;
  static const double totalMaxScore = 100.0;
}

/// Baseline requirement definition for nightshade crops cultivated in Sri Lanka.
class CropRequirementProfile {
  final String crop;
  final String scientificName;
  final List<String> preferredSoils;
  final List<String> tolerableSoils;
  final List<String> optimalSeasons;
  final double minOptimalTemp;
  final double maxOptimalTemp;
  final int minHarvestDays;
  final int maxHarvestDays;
  final String defaultHighlight;

  const CropRequirementProfile({
    required this.crop,
    required this.scientificName,
    required this.preferredSoils,
    required this.tolerableSoils,
    required this.optimalSeasons,
    required this.minOptimalTemp,
    required this.maxOptimalTemp,
    required this.minHarvestDays,
    required this.maxHarvestDays,
    required this.defaultHighlight,
  });

  factory CropRequirementProfile.fromJson(Map<String, dynamic> json) {
    return CropRequirementProfile(
      crop: json['crop'] as String,
      scientificName: json['scientificName'] as String,
      preferredSoils: List<String>.from(json['preferredSoils'] ?? []),
      tolerableSoils: List<String>.from(json['tolerableSoils'] ?? []),
      optimalSeasons: List<String>.from(json['optimalSeasons'] ?? []),
      minOptimalTemp: (json['minOptimalTemp'] as num?)?.toDouble() ?? 20.0,
      maxOptimalTemp: (json['maxOptimalTemp'] as num?)?.toDouble() ?? 32.0,
      minHarvestDays: (json['minHarvestDays'] as num?)?.toInt() ?? 75,
      maxHarvestDays: (json['maxHarvestDays'] as num?)?.toInt() ?? 90,
      defaultHighlight: json['defaultHighlight'] as String? ?? 'High yield zone',
    );
  }
}

/// Pure deterministic scoring engine evaluating crop suitability for farmers.
///
/// Designed as a rule-based multi-attribute decision matrix, operating 100% offline
/// without requiring heavy neural network dependencies.
class CropSuitabilityEngine {
  static const List<CropRequirementProfile> defaultProfiles = [
    CropRequirementProfile(
      crop: 'Tomato',
      scientificName: 'Solanum lycopersicum',
      preferredSoils: ['Loam', 'Sandy Loam', 'Silt'],
      tolerableSoils: ['Clay', 'Sandy'],
      optimalSeasons: ['Maha', 'Yala'],
      minOptimalTemp: 21.0,
      maxOptimalTemp: 29.5,
      minHarvestDays: 70,
      maxHarvestDays: 80,
      defaultHighlight: 'High yield zone',
    ),
    CropRequirementProfile(
      crop: 'Chilli',
      scientificName: 'Capsicum annuum',
      preferredSoils: ['Loam', 'Sandy Loam'],
      tolerableSoils: ['Sandy', 'Clay', 'Silt'],
      optimalSeasons: ['Yala', 'Maha'],
      minOptimalTemp: 24.0,
      maxOptimalTemp: 33.0,
      minHarvestDays: 70,
      maxHarvestDays: 90,
      defaultHighlight: 'Tolerates heat',
    ),
    CropRequirementProfile(
      crop: 'Eggplant',
      scientificName: 'Solanum melongena',
      preferredSoils: ['Loam', 'Silt', 'Clay'],
      tolerableSoils: ['Sandy'],
      optimalSeasons: ['Maha', 'Yala'],
      minOptimalTemp: 22.0,
      maxOptimalTemp: 32.0,
      minHarvestDays: 80,
      maxHarvestDays: 90,
      defaultHighlight: 'Consistent yield',
    ),
    CropRequirementProfile(
      crop: 'Potato',
      scientificName: 'Solanum tuberosum',
      preferredSoils: ['Loam', 'Sandy Loam'],
      tolerableSoils: ['Silt'],
      optimalSeasons: ['Maha'],
      minOptimalTemp: 16.0,
      maxOptimalTemp: 24.0,
      minHarvestDays: 90,
      maxHarvestDays: 105,
      defaultHighlight: 'Prefers hilly cooler zones',
    ),
  ];

  /// Evaluates crop suitability score and generates ordered recommendations.
  static List<PlantingRecommendation> evaluate({
    required String soil,
    required String season,
    double? currentTemperature,
    int? rainChance,
    List<CropRequirementProfile>? customProfiles,
  }) {
    final profiles = customProfiles ?? defaultProfiles;
    final normalizedSoil = soil.trim().toLowerCase();
    final normalizedSeason = season.toLowerCase().contains('yala') ? 'Yala' : 'Maha';
    final temp = currentTemperature ?? 29.0;
    final rain = rainChance ?? 40;

    final recommendations = <PlantingRecommendation>[];

    for (final profile in profiles) {
      double score = 0.0;
      final reasonChips = <String>[];
      bool caution = false;
      String? cautionNote;

      // 1. Soil Match (Weight 35)
      final isPrefSoil = profile.preferredSoils.any((s) => normalizedSoil.contains(s.toLowerCase()));
      final isTolerableSoil = profile.tolerableSoils.any((s) => normalizedSoil.contains(s.toLowerCase()));

      if (isPrefSoil) {
        score += AdvisorScoringWeights.soilWeight;
        reasonChips.add('Suits $soil');
      } else if (isTolerableSoil) {
        score += AdvisorScoringWeights.soilWeight * 0.65;
        reasonChips.add('Moderate on $soil');
      } else {
        score += AdvisorScoringWeights.soilWeight * 0.25;
        reasonChips.add('Suboptimal soil');
      }

      // 2. Season Match (Weight 30)
      if (profile.optimalSeasons.contains(normalizedSeason)) {
        score += AdvisorScoringWeights.seasonWeight;
        reasonChips.add('Good for $normalizedSeason');
      } else {
        score += AdvisorScoringWeights.seasonWeight * 0.5;
        reasonChips.add('Off-peak season');
      }

      // 3. Temperature Match (Weight 20)
      if (temp >= profile.minOptimalTemp && temp <= profile.maxOptimalTemp) {
        score += AdvisorScoringWeights.temperatureWeight;
      } else if (temp > profile.maxOptimalTemp) {
        final diff = temp - profile.maxOptimalTemp;
        if (diff > 4.0) {
          // Severe thermal penalty (e.g., Potato in lowlands)
          caution = true;
          cautionNote = 'Too warm this season (Low elevation thermal stress)';
          score += AdvisorScoringWeights.temperatureWeight * 0.2;
        } else {
          score += AdvisorScoringWeights.temperatureWeight * 0.6;
        }
      } else {
        score += AdvisorScoringWeights.temperatureWeight * 0.7;
      }

      // 4. Rain & Moisture Match (Weight 15)
      if (rain >= 30 && rain <= 70) {
        score += AdvisorScoringWeights.rainWeight;
        reasonChips.add('Moderate water need');
      } else {
        score += AdvisorScoringWeights.rainWeight * 0.75;
      }

      reasonChips.add(profile.defaultHighlight);

      final finalScorePercent = score.round().clamp(0, 100);

      recommendations.add(
        PlantingRecommendation(
          crop: profile.crop,
          scientificName: profile.scientificName,
          scorePercent: finalScorePercent,
          reasonChips: reasonChips,
          harvestDays: profile.minHarvestDays,
          caution: caution,
          cautionNote: cautionNote,
        ),
      );
    }

    // Order descending by scorePercent
    recommendations.sort((a, b) => b.scorePercent.compareTo(a.scorePercent));
    return recommendations;
  }

  /// Optional loader parsing external crop_requirements.json authored by AHMS.
  static Future<List<CropRequirementProfile>?> loadExternalRequirements() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/crop_requirements.json');
      final rawList = json.decode(jsonString) as List<dynamic>;
      return rawList.map((e) => CropRequirementProfile.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }
}
