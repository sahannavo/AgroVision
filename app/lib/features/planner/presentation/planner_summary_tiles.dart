import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

/// Two side-by-side summary cards for the Planner screen.
///
/// Matches the design in `Planner.png`:
/// - Tile 1: Water drop icon, "Water this week", "28 L/m²", "Scheduled over 5 days".
/// - Tile 2: Flask/fertilizer icon, "Next fertilizer", "Fri 16 Oct", "NPK 12-12-17 top-dress".
class PlannerSummaryTiles extends StatelessWidget {
  final String waterAmount;
  final String waterScheduleSummary;
  final String nextFertilizerDate;
  final String fertilizerType;

  const PlannerSummaryTiles({
    super.key,
    this.waterAmount = '28',
    this.waterScheduleSummary = 'Scheduled over 5 days',
    this.nextFertilizerDate = 'Fri 16 Oct',
    this.fertilizerType = 'NPK 12–12–17 top-dress',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Water summary tile
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6EEFA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        size: 16,
                        color: AppColors.waterBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Water this week',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: waterAmount,
                        style: AppTextStyles.headingLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0D47A1),
                          fontSize: 26,
                        ),
                      ),
                      TextSpan(
                        text: ' L/m²',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  waterScheduleSummary,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Fertilizer summary tile
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5D0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.science_outlined,
                        size: 16,
                        color: Color(0xFF558B2F),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Next fertilizer',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  nextFertilizerDate,
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E6930),
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  fertilizerType,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
