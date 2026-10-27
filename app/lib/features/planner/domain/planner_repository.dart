import 'irrigation_day_plan.dart';

/// Contract for irrigation and fertilizer planning.
abstract class PlannerRepository {
  /// Generates or fetches the 7-day irrigation and fertilizer plan for a given crop plot.
  Future<CropIrrigationPlan> planFor(String cropId);
}
