import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import 'planner_ui_models.dart';

/// Stepper widget displaying crop phenology stages.
///
/// Matches the design in `Planner.png`:
/// - Header: "PHENOLOGY TIMELINE" with badge "● Flowering · Day 48".
/// - Stepper: Seedling -> Vegetative -> Flowering -> Fruiting.
/// - Prior stages show checked green circles.
/// - Active stage shows highlighted dark green icon circle with label highlighted.
/// - Future stages show grey outlined circle with faded label.
class GrowthStageStepper extends StatelessWidget {
  final CropGrowthStage currentStage;
  final int stageDay;

  const GrowthStageStepper({
    super.key,
    required this.currentStage,
    this.stageDay = 48,
  });

  @override
  Widget build(BuildContext context) {
    final stages = CropGrowthStage.values;
    final currentIndex = stages.indexOf(currentStage);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: PHENOLOGY TIMELINE & Stage Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PHENOLOGY TIMELINE',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E89F),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${currentStage.label} · Day $stageDay',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF335C0A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Stepper Line and Circles
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(stages.length, (index) {
                      final isCompleted = index < currentIndex;
                      final isActive = index == currentIndex;
                      return Expanded(
                        child: Row(
                          children: [
                            // Left connector line
                            if (index > 0)
                              Expanded(
                                child: Container(
                                  height: 3,
                                  color: index <= currentIndex
                                      ? AppColors.primaryGreen
                                      : AppColors.divider,
                                ),
                              ),
                            // Node circle
                            _buildNodeCircle(
                              isCompleted: isCompleted,
                              isActive: isActive,
                              index: index,
                            ),
                            // Right connector line
                            if (index < stages.length - 1)
                              Expanded(
                                child: Container(
                                  height: 3,
                                  color: index < currentIndex
                                      ? AppColors.primaryGreen
                                      : AppColors.divider,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Stage Labels below nodes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(stages.length, (index) {
                      final stage = stages[index];
                      final isActive = index == currentIndex;
                      final isCompleted = index < currentIndex;

                      return Expanded(
                        child: Text(
                          stage.label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : (isCompleted ? FontWeight.w600 : FontWeight.w400),
                            color: isActive
                                ? AppColors.primaryGreen
                                : (isCompleted
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCircle({
    required bool isCompleted,
    required bool isActive,
    required int index,
  }) {
    if (isCompleted) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    if (isActive) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFF1B5E20),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_florist,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    // Future node
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.divider,
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.circle_outlined,
        color: AppColors.textTertiary,
        size: 12,
      ),
    );
  }
}
