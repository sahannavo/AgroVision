import 'package:flutter/foundation.dart';

/// Recommendation for a crop given soil type, season, and regional climate.
@immutable
class PlantingRecommendation {
  final String crop;
  final String scientificName;
  final int scorePercent;
  final List<String> reasonChips;
  final int harvestDays;
  final bool caution;
  final String? cautionNote;

  const PlantingRecommendation({
    required this.crop,
    required this.scientificName,
    required this.scorePercent,
    required this.reasonChips,
    required this.harvestDays,
    this.caution = false,
    this.cautionNote,
  });

  PlantingRecommendation copyWith({
    String? crop,
    String? scientificName,
    int? scorePercent,
    List<String>? reasonChips,
    int? harvestDays,
    bool? caution,
    String? cautionNote,
  }) {
    return PlantingRecommendation(
      crop: crop ?? this.crop,
      scientificName: scientificName ?? this.scientificName,
      scorePercent: scorePercent ?? this.scorePercent,
      reasonChips: reasonChips ?? this.reasonChips,
      harvestDays: harvestDays ?? this.harvestDays,
      caution: caution ?? this.caution,
      cautionNote: cautionNote ?? this.cautionNote,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantingRecommendation &&
          runtimeType == other.runtimeType &&
          crop == other.crop &&
          scientificName == other.scientificName &&
          scorePercent == other.scorePercent &&
          listEquals(reasonChips, other.reasonChips) &&
          harvestDays == other.harvestDays &&
          caution == other.caution &&
          cautionNote == other.cautionNote;

  @override
  int get hashCode => Object.hash(
        crop,
        scientificName,
        scorePercent,
        Object.hashAll(reasonChips),
        harvestDays,
        caution,
        cautionNote,
      );

  @override
  String toString() =>
      'PlantingRecommendation(crop: $crop, score: $scorePercent%, harvestDays: $harvestDays, caution: $caution)';
}
