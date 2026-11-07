import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/planner/domain/fertilizer_plan.dart';
import 'package:app/features/planner/domain/irrigation_engine.dart';

void main() {
  group('IrrigationEngine Unit Tests', () {
    const tomatoStageWaterWeekly = 28.0; // Flowering stage: 28 L/m²/week
    const tomatoFertilizer = FertilizerScheduleItem(
      fertilizerType: 'NPK 12–12–17',
      amountGramsPerPlant: 20.0,
      intervalDays: 14,
      applicationMethod: 'Apply along drip perimeter circle',
      tag: 'Top-dress',
    );

    test('a rainy day is skipped and explains why', () {
      final forecast = [
        const EngineDailyForecast(tempC: 28, rainPercentage: 10, rainMm: 0),
        const EngineDailyForecast(tempC: 27, rainPercentage: 20, rainMm: 2),
        const EngineDailyForecast(tempC: 25, rainPercentage: 85, rainMm: 18), // Heavy rain
        const EngineDailyForecast(tempC: 29, rainPercentage: 10, rainMm: 0),
        const EngineDailyForecast(tempC: 30, rainPercentage: 5, rainMm: 0),
        const EngineDailyForecast(tempC: 29, rainPercentage: 10, rainMm: 0),
        const EngineDailyForecast(tempC: 28, rainPercentage: 15, rainMm: 0),
      ];

      final plan = IrrigationEngine.generatePlan(
        cropId: 'tomato',
        growthStage: 'Flowering',
        plotAreaAcres: 1.0,
        stageWaterLitresPerWeek: tomatoStageWaterWeekly,
        stageFertilizer: tomatoFertilizer,
        forecastDays: forecast,
        startDate: DateTime(2026, 10, 12),
      );

      expect(plan.daySchedules.length, 7);

      // Wednesday (dayIndex 2) must be skipped
      final wednesday = plan.daySchedules[2];
      expect(wednesday.isSkipped, isTrue);
      expect(wednesday.waterAmountLitresPerSqm, 0.0);
      expect(wednesday.status, 'Watering Skipped');
      expect(wednesday.skipReason, 'Rain expected. Skip watering.');
      expect(wednesday.skipDetail, contains('Rainfall forecast'));
    });

    test('a dry hot day gets more water (+20% adjustment)', () {
      // Normal day vs Hot day (>= 32°C and <= 10% rain)
      final forecast = [
        const EngineDailyForecast(tempC: 28, rainPercentage: 10, rainMm: 0), // Normal
        const EngineDailyForecast(tempC: 33, rainPercentage: 5, rainMm: 0),  // Hot & Dry
        const EngineDailyForecast(tempC: 28, rainPercentage: 10, rainMm: 0),
        const EngineDailyForecast(tempC: 28, rainPercentage: 10, rainMm: 0),
        const EngineDailyForecast(tempC: 28, rainPercentage: 10, rainMm: 0),
        const EngineDailyForecast(tempC: 28, rainPercentage: 10, rainMm: 0),
        const EngineDailyForecast(tempC: 28, rainPercentage: 10, rainMm: 0),
      ];

      final plan = IrrigationEngine.generatePlan(
        cropId: 'tomato',
        growthStage: 'Flowering',
        plotAreaAcres: 1.0,
        stageWaterLitresPerWeek: 25.0, // base daily = 5.0
        stageFertilizer: tomatoFertilizer,
        forecastDays: forecast,
        startDate: DateTime(2026, 10, 12),
      );

      final normalDay = plan.daySchedules[0];
      final hotDay = plan.daySchedules[1];

      expect(normalDay.waterAmountLitresPerSqm, 5.0);
      expect(hotDay.waterAmountLitresPerSqm, 6.0); // 5.0 * 1.20 = 6.0
    });

    test('growth stage changes the fertilizer specification and schedule', () {
      const seedlingFertilizer = FertilizerScheduleItem(
        fertilizerType: 'Basal (NPK 4:25:8)',
        amountGramsPerPlant: 10.0,
        intervalDays: 14,
        applicationMethod: 'Soil incorporation at transplanting',
        tag: 'Basal',
      );

      final plan = IrrigationEngine.generatePlan(
        cropId: 'tomato',
        growthStage: 'Seedling',
        plotAreaAcres: 1.0,
        stageWaterLitresPerWeek: 14.0,
        stageFertilizer: seedlingFertilizer,
        startDate: DateTime(2026, 10, 12),
      );

      final fertDay = plan.daySchedules[4]; // Friday (Day 4)
      expect(fertDay.fertilizer, isNotNull);
      expect(fertDay.fertilizer!.fertilizerType, 'Basal (NPK 4:25:8)');
      expect(fertDay.fertilizer!.amountGramsPerPlant, 10.0);
      expect(fertDay.fertilizer!.tag, 'Basal');
    });

    test('no weather cache or forecast still returns a safe basic plan', () {
      final plan = IrrigationEngine.generatePlan(
        cropId: 'chilli',
        growthStage: 'Vegetative',
        plotAreaAcres: 0.5,
        stageWaterLitresPerWeek: 20.0,
        forecastDays: null, // No forecast
      );

      expect(plan.daySchedules.length, 7);
      expect(plan.summary.totalWaterLitresPerSqm, greaterThan(0));
      for (final day in plan.daySchedules) {
        expect(day.waterAmountLitresPerSqm, greaterThanOrEqualTo(0));
      }
    });

    test('summary includes water this week and next fertilizer info', () {
      final plan = IrrigationEngine.generatePlan(
        cropId: 'tomato',
        growthStage: 'Flowering',
        plotAreaAcres: 1.0,
        stageWaterLitresPerWeek: 28.0,
        stageFertilizer: tomatoFertilizer,
        startDate: DateTime(2026, 10, 12),
      );

      expect(plan.summary.totalWaterLitresPerSqm, greaterThan(20.0));
      expect(plan.summary.activeWateringDaysCount, greaterThan(0));
      expect(plan.summary.nextFertilizerDate, contains('Fri'));
      expect(plan.summary.fertilizerProduct, contains('NPK 12–12–17'));
    });
  });
}
