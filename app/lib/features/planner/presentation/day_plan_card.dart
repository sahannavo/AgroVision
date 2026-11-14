import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import 'planner_ui_models.dart';

/// Single day plan card in "This week's plan".
///
/// Matches the design in `Planner.png`:
/// - Header: Day name and date (e.g. "Monday, 12 Oct"), and status chip (e.g. Completed, Done, Upcoming, Watering Skipped, Dual Action Day).
/// - Normal watering row: Water drop icon + "4 L/m² drip irrigation · Evening (6:00 PM)".
/// - Rain skipped row: Muted blue background, cloud-rain icon, bold "Rain expected. Skip watering." and sensor note. Left edge teal stripe.
/// - Fertilizer row: Flask icon, NPK formula, dosage, tag "Top-dress", and application instruction note.
class DayPlanCard extends StatefulWidget {
  final IrrigationDayPlan plan;
  final bool initialExpanded;

  const DayPlanCard({
    super.key,
    required this.plan,
    this.initialExpanded = false,
  });

  @override
  State<DayPlanCard> createState() => _DayPlanCardState();
}

class _DayPlanCardState extends State<DayPlanCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded || widget.plan.status == DayPlanStatus.today;
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final isSkipped = plan.isSkipped || plan.status == DayPlanStatus.skipped;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: isSkipped ? const Color(0xFFEAF5F0) : AppColors.cardSurface,
      stripeColor: isSkipped ? const Color(0xFF00796B) : null,
      stripeWidth: 4,
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Date & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        plan.dateLabel,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (plan.fertilizerTitle != null && !isSkipped) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8BC34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusChip(plan),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Main Action content
          if (isSkipped)
            _buildSkippedContent(plan)
          else ...[
            _buildWateringScheduleRow(plan),
            if (plan.fertilizerTitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildFertilizerRow(plan),
            ],
          ],
        ],
      ),
    );
  }

  /// Status badge chip
  Widget _buildStatusChip(IrrigationDayPlan plan) {
    String label;
    Color bgColor;
    Color textColor;
    IconData? icon;

    switch (plan.status) {
      case DayPlanStatus.completed:
        label = 'Completed';
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle_outline;
        break;
      case DayPlanStatus.done:
        label = 'Done';
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle_outline;
        break;
      case DayPlanStatus.today:
        label = 'Today';
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.today;
        break;
      case DayPlanStatus.skipped:
        label = 'Watering Skipped';
        bgColor = const Color(0xFFDFF0EB);
        textColor = const Color(0xFF00796B);
        icon = Icons.block;
        break;
      case DayPlanStatus.upcoming:
        if (plan.fertilizerTitle != null) {
          label = 'Dual Action Day';
          bgColor = const Color(0xFFE6F3D2);
          textColor = const Color(0xFF558B2F);
          icon = null;
        } else {
          label = 'Upcoming';
          bgColor = Colors.transparent;
          textColor = AppColors.textSecondary;
          icon = null;
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: bgColor == Colors.transparent
            ? Border.all(color: Colors.transparent)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Normal watering schedule row
  Widget _buildWateringScheduleRow(IrrigationDayPlan plan) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8F4),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.water_drop_outlined,
            size: 18,
            color: Color(0xFF0277BD),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${plan.waterAmount} drip irrigation · ${plan.scheduleTime}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rain skipped banner matching Wednesday in Planner.png
  Widget _buildSkippedContent(IrrigationDayPlan plan) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F0EC),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFC7E5DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_outlined,
              size: 20,
              color: Color(0xFF00796B),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.skipReason ?? 'Rain expected. Skip watering.',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  plan.skipDetail ??
                      'Monsoon shower forecast (~18mm). Check tensiometer soil moisture sensor at noon before resuming drip schedule.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fertilizer banner matching Friday in Planner.png
  Widget _buildFertilizerRow(IrrigationDayPlan plan) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5D8),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFD4E89F),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.science_outlined,
              size: 18,
              color: Color(0xFF558B2F),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        plan.fertilizerTitle ?? 'NPK 12–12–17 · 20 g / plant',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (plan.fertilizerTag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFD4E89F),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          plan.fertilizerTag!,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF558B2F),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  plan.fertilizerDetail ??
                      'Apply along drip perimeter circle (15cm from main stem) prior to scheduled irrigation cycle.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
