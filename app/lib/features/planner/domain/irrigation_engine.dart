library;

import 'fertilizer_plan.dart';

/// Pure, offline, weather-driven irrigation and fertilizer calculation engine.
///
/// Implements agronomic rules defined in `AgroVision_Sprint_Plan_And_Prompts.docx`:
/// - Skips watering when forecast rain covers need or exceeds threshold.
/// - Increases water volume on hot, dry days.
/// - Schedules stage-specific fertilizer applications.
/// - Computes weekly summaries (water volume this week, next fertilizer date).
/// - Fallback gracefully when no weather forecast is available.
class IrrigationEngine {
  // Named constants for agronomic thresholds and rule parameters
  static const double kRainSkipThresholdMm = 15.0;
  static const int kRainSkipChancePercent = 70;
  static const int kHotDryTempThresholdC = 32;
  static const int kHotDryRainChanceLimit = 10;
  static const double kHotWeatherWaterMultiplier = 1.20;
  static const int kDefaultActiveDaysPerWeek = 5;

  /// Month names for human-readable date formatting without external packages.
  static const List<String> _kMonthShort = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> _kWeekdayNames = [
    '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  /// Generates a pure 7-day irrigation and fertilizer plan.
  ///
  /// Parameters:
  /// - [cropId]: Target crop ID (e.g. 'tomato', 'potato', 'chilli', 'eggplant').
  /// - [growthStage]: One of 'Seedling', 'Vegetative', 'Flowering', 'Fruiting'.
  /// - [plotAreaAcres]: Field area in acres.
  /// - [forecastDays]: List of daily forecasts (tempC, rainPercentage, rainMm). Can be null or empty.
  /// - [stageWaterLitresPerWeek]: Baseline water requirement from `irrigation_requirements.json`.
  /// - [stageFertilizer]: Stage fertilizer baseline details.
  /// - [preferredTimeOfDay]: Preferred time of day for irrigation.
  /// - [startDate]: Starting reference date for the 7-day forecast. Defaults to DateTime.now().
  static FullIrrigationPlan generatePlan({
    required String cropId,
    required String growthStage,
    required double plotAreaAcres,
    List<EngineDailyForecast>? forecastDays,
    required double stageWaterLitresPerWeek,
    FertilizerScheduleItem? stageFertilizer,
    String preferredTimeOfDay = 'Morning (6:30 AM)',
    DateTime? startDate,
    bool isWeatherCached = false,
  }) {
    final effectiveStart = startDate ?? DateTime.now();
    final daySchedules = <EngineDaySchedule>[];

    // Base daily water requirement (split across active watering days)
    final baseDailyWater = stageWaterLitresPerWeek / kDefaultActiveDaysPerWeek;

    double totalWaterLitres = 0.0;
    int activeWaterDaysCount = 0;
    String? nextFertilizerDateLabel;
    String? fertilizerProductName;

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final date = effectiveStart.add(Duration(days: dayIndex));
      final dateLabel = '${_kWeekdayNames[date.weekday]}, ${date.day} ${_kMonthShort[date.month]}';

      final forecast = (forecastDays != null && dayIndex < forecastDays.length)
          ? forecastDays[dayIndex]
          : null;

      bool isSkipped = false;
      String? skipReason;
      String? skipDetail;
      double dayWater = baseDailyWater;

      // 1. Evaluate Weather Conditions (if forecast is available)
      if (forecast != null) {
        final rainChance = forecast.rainPercentage;
        final rainMm = forecast.rainMm;
        final tempC = forecast.tempC;

        // Rule: Skip watering when forecast rain covers need
        if (rainChance >= kRainSkipChancePercent || rainMm >= kRainSkipThresholdMm) {
          isSkipped = true;
          dayWater = 0.0;
          skipReason = 'Rain expected. Skip watering.';
          skipDetail = 'Rainfall forecast (${rainMm.toStringAsFixed(0)}mm, $rainChance% chance). Check soil moisture sensor at noon before resuming drip schedule.';
        }
        // Rule: Increase water volume on hot, dry days
        else if (tempC >= kHotDryTempThresholdC && rainChance <= kHotDryRainChanceLimit) {
          dayWater = (baseDailyWater * kHotWeatherWaterMultiplier);
        }
      }

      // Round water to clean half or whole litres
      final roundedWater = isSkipped ? 0.0 : (dayWater * 2).round() / 2;

      if (!isSkipped) {
        totalWaterLitres += roundedWater;
        activeWaterDaysCount++;
      }

      // 2. Evaluate Fertilizer Application Schedule
      // In a 7-day schedule, we schedule fertilizer on mid-week (e.g. Day 4 / Friday) if applicable
      FertilizerScheduleItem? scheduledFertilizer;
      if (stageFertilizer != null && dayIndex == 4) {
        scheduledFertilizer = stageFertilizer;
        nextFertilizerDateLabel = '${_kWeekdayNames[date.weekday].substring(0, 3)} ${date.day} ${_kMonthShort[date.month]}';
        fertilizerProductName = '${stageFertilizer.fertilizerType} top-dress';
      }

      // 3. Determine status label
      String status;
      if (isSkipped) {
        status = 'Watering Skipped';
      } else if (dayIndex == 0) {
        status = 'Today';
      } else if (dayIndex < 0) {
        status = 'Completed';
      } else {
        status = scheduledFertilizer != null ? 'Dual Action Day' : 'Upcoming';
      }

      daySchedules.add(
        EngineDaySchedule(
          date: date,
          dateLabel: dateLabel,
          waterAmountLitresPerSqm: roundedWater,
          preferredTimeOfDay: preferredTimeOfDay,
          isSkipped: isSkipped,
          skipReason: skipReason,
          skipDetail: skipDetail,
          fertilizer: scheduledFertilizer,
          status: status,
        ),
      );
    }

    // Default fertilizer date if not falling on this cycle
    final effectiveNextFertDate = nextFertilizerDateLabel ??
        '${_kWeekdayNames[effectiveStart.add(const Duration(days: 4)).weekday].substring(0, 3)} ${effectiveStart.add(const Duration(days: 4)).day} ${_kMonthShort[effectiveStart.month]}';
    final effectiveFertProduct = fertilizerProductName ??
        (stageFertilizer != null ? '${stageFertilizer.fertilizerType} top-dress' : 'None scheduled');

    final summary = WeeklyPlannerSummary(
      totalWaterLitresPerSqm: (totalWaterLitres * 10).round() / 10,
      activeWateringDaysCount: activeWaterDaysCount,
      nextFertilizerDate: effectiveNextFertDate,
      fertilizerProduct: effectiveFertProduct,
    );

    return FullIrrigationPlan(
      cropId: cropId,
      growthStage: growthStage,
      summary: summary,
      daySchedules: daySchedules,
      generatedAt: DateTime.now(),
      isWeatherCached: isWeatherCached,
    );
  }
}

/// Weather input structure required by the Irrigation Engine.
class EngineDailyForecast {
  final int tempC;
  final int rainPercentage;
  final double rainMm;

  const EngineDailyForecast({
    required this.tempC,
    required this.rainPercentage,
    this.rainMm = 0.0,
  });
}
