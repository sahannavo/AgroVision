import 'package:app/features/planner/data/fake_planner_repository.dart';
import 'package:app/features/planner/domain/irrigation_day_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakePlannerRepository', () {
    test('planFor returns 7-day irrigation schedule with weekly summary', () async {
      final repo = FakePlannerRepository(delay: Duration.zero);
      final plan = await repo.planFor('plot_tomato_01');

      expect(plan.cropId, equals('plot_tomato_01'));
      expect(plan.days.length, equals(7));

      // Weekly summary
      expect(plan.summary.waterThisWeekLitresPerM2, equals(15.0));
      expect(plan.summary.nextFertilizerDate, isNotNull);
      expect(plan.summary.nextFertilizerName, contains('MOP'));

      // Check states across days
      final doneDays = plan.days.where((d) => d.status == PlanStatus.done);
      expect(doneDays.length, equals(2));

      final today = plan.days.firstWhere((d) => d.status == PlanStatus.today);
      expect(today.waterLitresPerM2, equals(3.5));
      expect(today.fertilizer, contains('Urea'));

      final skippedDay = plan.days.firstWhere((d) => d.status == PlanStatus.skipped);
      expect(skippedDay.waterLitresPerM2, equals(0.0));
      expect(skippedDay.note, contains('Rain expected'));

      final upcomingDays = plan.days.where((d) => d.status == PlanStatus.upcoming);
      expect(upcomingDays.length, equals(3));
    });
  });
}

