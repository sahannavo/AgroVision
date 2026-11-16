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
  final String growthStage;
  final double areaSize;
  final String location;

  CropPlot({
    String? id,
    String? userId,
    String? name,
    String? plotName,
    this.variety,
    String? cropType,
    DateTime? plantedDate,
    String? soilType,
    Object? growthStage,
    this.bed,
    double? areaSize,
    double? area,
    String? location,
    this.status,
    this.areaUnit = 'acre',
  }) : id = id ?? '',
       userId = userId ?? '',
       name = name ?? plotName ?? cropType ?? 'Crop plot',
       cropType = cropType ?? 'Unknown',
       plantedDate = plantedDate ?? DateTime.now(),
       soilType = soilType ?? 'Unknown',
       growthStage = growthStage is GrowthStage
           ? growthStage.displayName
           : growthStage as String? ?? 'Seedling',
       areaSize = areaSize ?? area ?? 0,
       location = location ?? bed ?? '';

  final String? variety;
  final String? bed;
  final String? status;
  final String areaUnit;

  String get plotName => name;
  double get area => areaSize;

  /// Calculates the plot's age in days.
  int get ageInDays => DateTime.now().difference(plantedDate).inDays;

  CropPlot copyWith({
    String? id,
    String? userId,
    String? name,
    String? cropType,
    DateTime? plantedDate,
    String? soilType,
    Object? growthStage,
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
          variety == other.variety &&
          bed == other.bed &&
          status == other.status &&
          areaUnit == other.areaUnit &&
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
    variety,
    bed,
    status,
    areaUnit,
    areaSize,
    location,
  );

  @override
  String toString() =>
      'CropPlot(id: $id, name: $name, crop: $cropType, stage: $growthStage, area: $areaSize, location: $location)';
}
