import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/planner/data/local_planner_repository.dart';
import 'package:app/features/planner/domain/irrigation_engine.dart';
import 'package:app/features/planner/presentation/planner_ui_models.dart';

void main() {
  group('LocalPlannerRepository Unit Tests', () {
    late LocalPlannerRepository repository;

    setUp(() {
      repository = LocalPlannerRepository();
    });

    test('generates plan and caches it for offline access', () async {
      const forecast = [
        EngineDailyForecast(tempC: 30, rainPercentage: 10),
        EngineDailyForecast(tempC: 29, rainPercentage: 10),
        EngineDailyForecast(tempC: 26, rainPercentage: 80, rainMm: 20),
        EngineDailyForecast(tempC: 28, rainPercentage: 15),
        EngineDailyForecast(tempC: 31, rainPercentage: 5),
        EngineDailyForecast(tempC: 30, rainPercentage: 10),
        EngineDailyForecast(tempC: 28, rainPercentage: 15),
      ];

      final plan = await repository.planFor(
        'tomato',
        growthStage: 'Flowering',
        areaAcres: 1.5,
        forecast: forecast,
      );

      expect(plan.cropId, 'tomato');
      expect(plan.daySchedules.length, 7);

      // Verify cached copy is preserved
      final cached = repository.getCachedSchedule('tomato');
      expect(cached, isNotNull);
      expect(cached!.summary.totalWaterLitresPerSqm, plan.summary.totalWaterLitresPerSqm);
    });

    test('convertToUiDayPlans transforms engine schedule to UI models with rain skip status', () async {
      const forecast = [
        EngineDailyForecast(tempC: 28, rainPercentage: 0),
        EngineDailyForecast(tempC: 28, rainPercentage: 0),
        EngineDailyForecast(tempC: 24, rainPercentage: 90, rainMm: 25), // Skipped
        EngineDailyForecast(tempC: 28, rainPercentage: 0),
        EngineDailyForecast(tempC: 28, rainPercentage: 0),
        EngineDailyForecast(tempC: 28, rainPercentage: 0),
        EngineDailyForecast(tempC: 28, rainPercentage: 0),
      ];

      final plan = await repository.planFor(
        'potato',
        growthStage: 'Flowering',
        forecast: forecast,
      );

      final uiPlans = repository.convertToUiDayPlans(plan);

      expect(uiPlans.length, 7);

      final skippedDay = uiPlans[2];
      expect(skippedDay.isSkipped, isTrue);
      expect(skippedDay.status, DayPlanStatus.skipped);
      expect(skippedDay.skipReason, 'Rain expected. Skip watering.');
    });

    test('generates correct plan without weather forecast (pure offline fallback)', () async {
      final plan = await repository.planFor(
        'eggplant',
        growthStage: 'Vegetative',
        forecast: null,
      );

      expect(plan.cropId, 'eggplant');
      expect(plan.growthStage, 'Vegetative');
      expect(plan.daySchedules.length, 7);
      expect(plan.summary.totalWaterLitresPerSqm, greaterThan(0));
    });
  });
}
