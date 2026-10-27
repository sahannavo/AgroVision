import '../domain/irrigation_day_plan.dart';
import '../domain/planner_repository.dart';

/// Fake implementation of [PlannerRepository] with sample data from design PNGs
/// (Tomato · Plot A, 7-day schedule with rain skip and weekly water summary).
class FakePlannerRepository implements PlannerRepository {
  FakePlannerRepository({
    this.delay = const Duration(milliseconds: 300),
  });

  final Duration delay;

  @override
  Future<CropIrrigationPlan> planFor(String cropId) async {
    await Future<void>.delayed(delay);

    final now = DateTime.now();
    return CropIrrigationPlan(
      cropId: cropId,
      summary: WeeklyPlannerSummary(
        waterThisWeekLitresPerM2: 15.0,
        nextFertilizerDate: now.add(const Duration(days: 4)),
        nextFertilizerName: 'MOP (Muriate of Potash) Top-dressing',
      ),
      days: [
        IrrigationDayPlan(
          date: now.subtract(const Duration(days: 2)),
          status: PlanStatus.done,
          waterLitresPerM2: 4.0,
          note: 'Normal cycle completed',
          timeOfDay: '06:30 AM',
        ),
        IrrigationDayPlan(
          date: now.subtract(const Duration(days: 1)),
          status: PlanStatus.done,
          waterLitresPerM2: 4.0,
          note: 'Normal cycle completed',
          timeOfDay: '06:30 AM',
        ),
        IrrigationDayPlan(
          date: now,
          status: PlanStatus.today,
          waterLitresPerM2: 3.5,
          fertilizer: 'Urea top-dressing (Stage 3)',
          note: 'Apply fertilizer early morning around drip circle',
          timeOfDay: '06:30 AM',
        ),
        IrrigationDayPlan(
          date: now.add(const Duration(days: 1)),
          status: PlanStatus.skipped,
          waterLitresPerM2: 0.0,
          note: 'Rain expected. Skip watering.',
          timeOfDay: 'Morning',
        ),
        IrrigationDayPlan(
          date: now.add(const Duration(days: 2)),
          status: PlanStatus.upcoming,
          waterLitresPerM2: 4.0,
          note: 'Standard scheduled irrigation',
          timeOfDay: '06:30 AM',
        ),
        IrrigationDayPlan(
          date: now.add(const Duration(days: 3)),
          status: PlanStatus.upcoming,
          waterLitresPerM2: 3.5,
          note: 'Standard scheduled irrigation',
          timeOfDay: '06:30 AM',
        ),
        IrrigationDayPlan(
          date: now.add(const Duration(days: 4)),
          status: PlanStatus.upcoming,
          waterLitresPerM2: 4.0,
          fertilizer: 'MOP Top-dressing',
          note: 'Fertilizer booster application',
          timeOfDay: '06:30 AM',
        ),
      ],
    );
  }
}
