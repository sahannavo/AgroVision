import 'package:flutter/foundation.dart';

/// Growth stages for nightshade crops in AgroVision.
enum GrowthStage {
  seedling,
  vegetative,
  flowering,
  fruiting;

  String get displayName {
    switch (this) {
      case GrowthStage.seedling:
        return 'Seedling Stage';
      case GrowthStage.vegetative:
        return 'Vegetative Stage';
      case GrowthStage.flowering:
        return 'Flowering Stage';
      case GrowthStage.fruiting:
        return 'Fruiting Stage';
    }
  }
}

/// Represents a farmer's cultivated crop plot.
@immutable
class CropPlot {
  final String id;
  final String userId;
  final String name;
  final String cropType;
  final DateTime plantedDate;
  final String soilType;
  final GrowthStage growthStage;
  final double areaSize;
  final String location;

  const CropPlot({
    required this.id,
    required this.userId,
    required this.name,
    required this.cropType,
    required this.plantedDate,
    required this.soilType,
    required this.growthStage,
    required this.areaSize,
    required this.location,
  });

  /// Calculates the plot's age in days.
  int get ageInDays => DateTime.now().difference(plantedDate).inDays;

  CropPlot copyWith({
    String? id,
    String? userId,
    String? name,
    String? cropType,
    DateTime? plantedDate,
    String? soilType,
    GrowthStage? growthStage,
    double? areaSize,
    String? location,
  }) {
    return CropPlot(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      cropType: cropType ?? this.cropType,
      plantedDate: plantedDate ?? this.plantedDate,
      soilType: soilType ?? this.soilType,
      growthStage: growthStage ?? this.growthStage,
      areaSize: areaSize ?? this.areaSize,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropPlot &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          cropType == other.cropType &&
          plantedDate == other.plantedDate &&
          soilType == other.soilType &&
          growthStage == other.growthStage &&
          areaSize == other.areaSize &&
          location == other.location;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        name,
        cropType,
        plantedDate,
        soilType,
        growthStage,
        areaSize,
        location,
      );

  @override
  String toString() =>
      'CropPlot(id: $id, name: $name, crop: $cropType, stage: $growthStage, area: $areaSize, location: $location)';
}
