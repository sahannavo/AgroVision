library;

/// UI models and data structures for the Planner feature.

enum CropGrowthStage {
  seedling('Seedling'),
  vegetative('Vegetative'),
  flowering('Flowering'),
  fruiting('Fruiting');

  final String label;
  const CropGrowthStage(this.label);
}

enum DayPlanStatus {
  completed('Completed'),
  done('Done'),
  today('Today'),
  upcoming('Upcoming'),
  skipped('Watering Skipped');

  final String label;
  const DayPlanStatus(this.label);
}

class CropPlotItem {
  final String id;
  final String cropName;
  final String plotName;
  final String location;
  final String season;
  final CropGrowthStage stage;
  final int stageDay;

  const CropPlotItem({
    required this.id,
    required this.cropName,
    required this.plotName,
    required this.location,
    required this.season,
    required this.stage,
    required this.stageDay,
  });

  String get displayName => '$cropName • $plotName';
  String get regionSubtitle => '$location • $season'.toUpperCase();
}

class DailyForecastItem {
  final String dayName;
  final int tempC;
  final int rainPercentage;
  final String iconCode;

  const DailyForecastItem({
    required this.dayName,
    required this.tempC,
    required this.rainPercentage,
    required this.iconCode,
  });
}

class IrrigationDayPlan {
  final String id;
  final String dateLabel;
  final DayPlanStatus status;
  final String waterAmount;
  final String scheduleTime;
  final bool isSkipped;
  final String? skipReason;
  final String? skipDetail;
  final String? fertilizerTitle;
  final String? fertilizerDetail;
  final String? fertilizerTag;

  const IrrigationDayPlan({
    required this.id,
    required this.dateLabel,
    required this.status,
    required this.waterAmount,
    required this.scheduleTime,
    this.isSkipped = false,
    this.skipReason,
    this.skipDetail,
    this.fertilizerTitle,
    this.fertilizerDetail,
    this.fertilizerTag,
  });
}
