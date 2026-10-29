import 'package:flutter/foundation.dart';

/// Status of an irrigation and fertilizer day action.
enum PlanStatus {
  done,
  today,
  upcoming,
  skipped;

  String get displayName {
    switch (this) {
      case PlanStatus.done:
        return 'Done';
      case PlanStatus.today:
        return 'Today';
      case PlanStatus.upcoming:
        return 'Upcoming';
      case PlanStatus.skipped:
        return 'Skipped';
    }
  }
}

/// Day-specific irrigation and fertilizer recommendation.
@immutable
class IrrigationDayPlan {
  final DateTime date;
  final PlanStatus status;
  final double waterLitresPerM2;
  final String? fertilizer;
  final String note;
  final String timeOfDay;

  const IrrigationDayPlan({
    required this.date,
    required this.status,
    required this.waterLitresPerM2,
    this.fertilizer,
    required this.note,
    this.timeOfDay = '06:30 AM',
  });

  IrrigationDayPlan copyWith({
    DateTime? date,
    PlanStatus? status,
    double? waterLitresPerM2,
    String? fertilizer,
    String? note,
    String? timeOfDay,
  }) {
    return IrrigationDayPlan(
      date: date ?? this.date,
      status: status ?? this.status,
      waterLitresPerM2: waterLitresPerM2 ?? this.waterLitresPerM2,
      fertilizer: fertilizer ?? this.fertilizer,
      note: note ?? this.note,
      timeOfDay: timeOfDay ?? this.timeOfDay,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IrrigationDayPlan &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          status == other.status &&
          waterLitresPerM2 == other.waterLitresPerM2 &&
          fertilizer == other.fertilizer &&
          note == other.note &&
          timeOfDay == other.timeOfDay;

  @override
  int get hashCode => Object.hash(
        date.year,
        date.month,
        date.day,
        status,
        waterLitresPerM2,
        fertilizer,
        note,
        timeOfDay,
      );

  @override
  String toString() =>
      'IrrigationDayPlan(date: $date, status: $status, water: $waterLitresPerM2 L/m², fertilizer: $fertilizer, note: $note)';
}

/// Weekly irrigation and fertilization summary.
@immutable
class WeeklyPlannerSummary {
  final double waterThisWeekLitresPerM2;
  final DateTime? nextFertilizerDate;
  final String nextFertilizerName;

  const WeeklyPlannerSummary({
    required this.waterThisWeekLitresPerM2,
    this.nextFertilizerDate,
    this.nextFertilizerName = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyPlannerSummary &&
          runtimeType == other.runtimeType &&
          waterThisWeekLitresPerM2 == other.waterThisWeekLitresPerM2 &&
          nextFertilizerDate == other.nextFertilizerDate &&
          nextFertilizerName == other.nextFertilizerName;

  @override
  int get hashCode => Object.hash(
        waterThisWeekLitresPerM2,
        nextFertilizerDate,
        nextFertilizerName,
      );

  @override
  String toString() =>
      'WeeklyPlannerSummary(waterThisWeek: $waterThisWeekLitresPerM2 L/m², nextFert: $nextFertilizerDate)';
}

/// Complete irrigation plan for a crop plot.
@immutable
class CropIrrigationPlan {
  final String cropId;
  final WeeklyPlannerSummary summary;
  final List<IrrigationDayPlan> days;

  const CropIrrigationPlan({
    required this.cropId,
    required this.summary,
    required this.days,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropIrrigationPlan &&
          runtimeType == other.runtimeType &&
          cropId == other.cropId &&
          summary == other.summary &&
          listEquals(days, other.days);

  @override
  int get hashCode => Object.hash(cropId, summary, Object.hashAll(days));

  @override
  String toString() => 'CropIrrigationPlan(cropId: $cropId, days: ${days.length})';
}

