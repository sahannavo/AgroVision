library;

import '../domain/fertilizer_plan.dart';
import '../domain/irrigation_engine.dart';
import '../presentation/planner_ui_models.dart';

/// Abstract repository interface for irrigation and fertilizer planning.
abstract class PlannerRepository {
  /// Generates a 7-day irrigation and fertilizer plan for the given [cropId].
  Future<FullIrrigationPlan> planFor(
    String cropId, {
    String growthStage = 'Flowering',
    double areaAcres = 1.0,
    List<EngineDailyForecast>? forecast,
  });

  /// Converts engine day schedules into presentation-layer [IrrigationDayPlan] list.
  List<IrrigationDayPlan> convertToUiDayPlans(FullIrrigationPlan plan);
}

/// Offline, local implementation of [PlannerRepository].
///
/// Features:
/// - Reads from static crop stage baselines derived from `irrigation_requirements.json`.
/// - Integrates with [IrrigationEngine] to compute 7-day schedules.
/// - Caches generated plans locally in memory for offline retrieval.
/// - Respects the `USE_FAKES` environment define.
class LocalPlannerRepository implements PlannerRepository {
  /// Local cache simulating offline persistent storage for irrigationSchedules.
  final Map<String, FullIrrigationPlan> _scheduleCache = {};

  /// Whether to use mock / fake data fallback.
  static const bool useFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

  @override
  Future<FullIrrigationPlan> planFor(
    String cropId, {
    String growthStage = 'Flowering',
    double areaAcres = 1.0,
    List<EngineDailyForecast>? forecast,
  }) async {
    final normalizedCrop = cropId.toLowerCase().trim();

    // 1. Retrieve baseline stage requirements
    final stageReq = _getStageRequirement(normalizedCrop, growthStage);

    // 2. Generate plan using the pure IrrigationEngine
    final plan = IrrigationEngine.generatePlan(
      cropId: normalizedCrop,
      growthStage: growthStage,
      plotAreaAcres: areaAcres,
      forecastDays: forecast,
      stageWaterLitresPerWeek: stageReq.waterLitresPerWeek,
      stageFertilizer: stageReq.fertilizer,
      preferredTimeOfDay: stageReq.preferredTimeOfDay,
      isWeatherCached: forecast != null,
    );

    // 3. Store snapshot in local cache
    _scheduleCache[normalizedCrop] = plan;

    return plan;
  }

  /// Retrieves cached schedule for a crop, if available.
  FullIrrigationPlan? getCachedSchedule(String cropId) {
    return _scheduleCache[cropId.toLowerCase().trim()];
  }

  @override
  List<IrrigationDayPlan> convertToUiDayPlans(FullIrrigationPlan plan) {
    return plan.daySchedules.map((schedule) {
      DayPlanStatus status;
      if (schedule.isSkipped) {
        status = DayPlanStatus.skipped;
      } else if (schedule.status == 'Today') {
        status = DayPlanStatus.today;
      } else if (schedule.status == 'Completed') {
        status = DayPlanStatus.completed;
      } else if (schedule.status == 'Done') {
        status = DayPlanStatus.done;
      } else {
        status = DayPlanStatus.upcoming;
      }

      return IrrigationDayPlan(
        id: '${plan.cropId}-${schedule.date.millisecondsSinceEpoch}',
        dateLabel: schedule.dateLabel,
        status: status,
        waterAmount: '${schedule.waterAmountLitresPerSqm.toStringAsFixed(0)} L/m²',
        scheduleTime: schedule.isSkipped ? 'Skipped' : schedule.preferredTimeOfDay,
        isSkipped: schedule.isSkipped,
        skipReason: schedule.skipReason,
        skipDetail: schedule.skipDetail,
        fertilizerTitle: schedule.fertilizer != null
            ? '${schedule.fertilizer!.fertilizerType} · ${schedule.fertilizer!.amountGramsPerPlant.toStringAsFixed(0)} g / plant'
            : null,
        fertilizerTag: schedule.fertilizer?.tag,
        fertilizerDetail: schedule.fertilizer?.applicationMethod,
      );
    }).toList();
  }

  /// Resolves baseline parameters according to the agronomic requirement tables.
  _StageBaseline _getStageRequirement(String cropId, String stage) {
    switch (cropId) {
      case 'potato':
        switch (stage.toLowerCase()) {
          case 'seedling':
            return _StageBaseline(
              waterLitresPerWeek: 18.0,
              preferredTimeOfDay: 'Morning (7:00 AM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Basal (NPK 10:25:20)',
                amountGramsPerPlant: 25.0,
                intervalDays: 20,
                applicationMethod: 'Furrow placement before seed tuber placement',
                tag: 'Basal',
              ),
            );
          case 'vegetative':
            return _StageBaseline(
              waterLitresPerWeek: 25.0,
              preferredTimeOfDay: 'Morning (6:30 AM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Urea Top-dress',
                amountGramsPerPlant: 10.0,
                intervalDays: 21,
                applicationMethod: 'Band placement followed by earthing up',
                tag: 'Top-dress',
              ),
            );
          case 'fruiting':
            return _StageBaseline(
              waterLitresPerWeek: 20.0,
              preferredTimeOfDay: 'Morning (7:00 AM)',
              fertilizer: null,
            );
          case 'flowering':
          default:
            return _StageBaseline(
              waterLitresPerWeek: 32.0,
              preferredTimeOfDay: 'Evening (5:30 PM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Potassium Sulfate (SOP)',
                amountGramsPerPlant: 15.0,
                intervalDays: 21,
                applicationMethod: 'Soil surface application before tuber enlargement',
                tag: 'Top-dress',
              ),
            );
        }

      case 'chilli':
        switch (stage.toLowerCase()) {
          case 'seedling':
            return _StageBaseline(
              waterLitresPerWeek: 12.0,
              preferredTimeOfDay: 'Morning (6:30 AM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Basal Mixture',
                amountGramsPerPlant: 12.0,
                intervalDays: 18,
                applicationMethod: 'In-hole application at planting',
                tag: 'Basal',
              ),
            );
          case 'vegetative':
            return _StageBaseline(
              waterLitresPerWeek: 20.0,
              preferredTimeOfDay: 'Morning (6:30 AM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Top-dress 1 (Urea)',
                amountGramsPerPlant: 7.0,
                intervalDays: 14,
                applicationMethod: 'Ring application 8cm away from stem',
                tag: 'Top-dress',
              ),
            );
          case 'fruiting':
            return _StageBaseline(
              waterLitresPerWeek: 28.0,
              preferredTimeOfDay: 'Evening (6:00 PM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Top-dress 3 (MOP + Urea)',
                amountGramsPerPlant: 10.0,
                intervalDays: 14,
                applicationMethod: 'Apply after each harvesting flush',
                tag: 'Top-dress',
              ),
            );
          case 'flowering':
          default:
            return _StageBaseline(
              waterLitresPerWeek: 26.0,
              preferredTimeOfDay: 'Evening (5:30 PM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'NPK Top-dress (12:12:17)',
                amountGramsPerPlant: 15.0,
                intervalDays: 14,
                applicationMethod: 'Band application before flowering peak',
                tag: 'Top-dress',
              ),
            );
        }

      case 'eggplant':
        switch (stage.toLowerCase()) {
          case 'seedling':
            return _StageBaseline(
              waterLitresPerWeek: 14.0,
              preferredTimeOfDay: 'Morning (6:30 AM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Basal (NPK 5:15:15)',
                amountGramsPerPlant: 15.0,
                intervalDays: 20,
                applicationMethod: 'Incorporate in planting pits',
                tag: 'Basal',
              ),
            );
          case 'vegetative':
            return _StageBaseline(
              waterLitresPerWeek: 24.0,
              preferredTimeOfDay: 'Morning (6:30 AM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Top-dress 1 (Urea)',
                amountGramsPerPlant: 8.0,
                intervalDays: 14,
                applicationMethod: 'Circular band application',
                tag: 'Top-dress',
              ),
            );
          case 'fruiting':
            return _StageBaseline(
              waterLitresPerWeek: 34.0,
              preferredTimeOfDay: 'Evening (6:00 PM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'MOP + Urea Top-dress',
                amountGramsPerPlant: 12.0,
                intervalDays: 14,
                applicationMethod: 'Repeat every 2 weeks during prolonged fruit picks',
                tag: 'Top-dress',
              ),
            );
          case 'flowering':
          default:
            return _StageBaseline(
              waterLitresPerWeek: 30.0,
              preferredTimeOfDay: 'Evening (5:30 PM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'NPK 12–12–17',
                amountGramsPerPlant: 18.0,
                intervalDays: 14,
                applicationMethod: 'Surface application around drip ring',
                tag: 'Top-dress',
              ),
            );
        }

      case 'tomato':
      default:
        switch (stage.toLowerCase()) {
          case 'seedling':
            return _StageBaseline(
              waterLitresPerWeek: 14.0,
              preferredTimeOfDay: 'Morning (6:30 AM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Basal (NPK 4:25:8)',
                amountGramsPerPlant: 10.0,
                intervalDays: 14,
                applicationMethod: 'Soil incorporation at transplanting',
                tag: 'Basal',
              ),
            );
          case 'vegetative':
            return _StageBaseline(
              waterLitresPerWeek: 22.0,
              preferredTimeOfDay: 'Morning (6:30 AM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'Top-dress 1 (Urea)',
                amountGramsPerPlant: 8.0,
                intervalDays: 14,
                applicationMethod: 'Side dressing 10cm from base',
                tag: 'Top-dress',
              ),
            );
          case 'fruiting':
            return _StageBaseline(
              waterLitresPerWeek: 32.0,
              preferredTimeOfDay: 'Evening (6:00 PM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'MOP + Urea',
                amountGramsPerPlant: 12.0,
                intervalDays: 14,
                applicationMethod: 'Top-dress prior to final fruit swelling',
                tag: 'Top-dress',
              ),
            );
          case 'flowering':
          default:
            return _StageBaseline(
              waterLitresPerWeek: 28.0,
              preferredTimeOfDay: 'Evening (5:30 PM)',
              fertilizer: const FertilizerScheduleItem(
                fertilizerType: 'NPK 12–12–17',
                amountGramsPerPlant: 20.0,
                intervalDays: 14,
                applicationMethod: 'Apply along drip perimeter circle (15cm from main stem)',
                tag: 'Top-dress',
              ),
            );
        }
    }
  }
}

class _StageBaseline {
  final double waterLitresPerWeek;
  final String preferredTimeOfDay;
  final FertilizerScheduleItem? fertilizer;

  const _StageBaseline({
    required this.waterLitresPerWeek,
    required this.preferredTimeOfDay,
    this.fertilizer,
  });
}
