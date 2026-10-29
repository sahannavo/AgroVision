import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/planting_recommendation.dart';

/// Card widget displaying an individual crop suitability result.
///
/// Implements the exact layout and states shown in `Advisor with results.png`:
/// - Crop icon badge color-coded by crop family.
/// - Crop common name, scientific name, and rank pill badge.
/// - Match score percentage with color-coded progress bar (green for strong match,
///   amber for caution).
/// - Reason chips (with danger styling for thermal or environmental cautions).
/// - Estimated days to harvest and navigation link to the planting plan.
class CropMatchCard extends StatelessWidget {
  /// The recommendation data model for this crop.
  final PlantingRecommendation recommendation;

  /// Rank position in the recommendation list (1-indexed).
  final int rank;

  /// Callback when the card or planting plan action is tapped.
  final VoidCallback? onTapPlan;

  const CropMatchCard({
    super.key,
    required this.recommendation,
    required this.rank,
    this.onTapPlan,
  });

  _CropVisualDetails _getVisualDetails(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('tomato')) {
      return const _CropVisualDetails(
        containerColor: Color(0xFFFFEBEE),
        iconColor: Color(0xFFD32F2F),
        icon: Icons.eco_rounded,
        displayName: 'Tomato',
      );
    }
    if (lower.contains('chilli') || lower.contains('chili')) {
      return const _CropVisualDetails(
        containerColor: Color(0xFFFBE9E7),
        iconColor: Color(0xFFE64A19),
        icon: Icons.local_fire_department_rounded,
        displayName: 'Chilli',
      );
    }
    if (lower.contains('eggplant') || lower.contains('brinjal')) {
      return const _CropVisualDetails(
        containerColor: Color(0xFFE3F2FD),
        iconColor: Color(0xFF1976D2),
        icon: Icons.spa_rounded,
        displayName: 'Eggplant',
      );
    }
    return const _CropVisualDetails(
      containerColor: Color(0xFFEFEBE9),
      iconColor: Color(0xFF5D4037),
      icon: Icons.grain_rounded,
      displayName: 'Potato',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCaution = recommendation.caution;
    final visual = _getVisualDetails(recommendation.crop);

    final scoreColor = isCaution ? AppColors.warning : AppColors.textPrimary;
    final progressColor = isCaution ? AppColors.warning : AppColors.primaryGreen;
    final progressTrackColor = isCaution
        ? AppColors.warning.withValues(alpha: 0.15)
        : AppColors.primaryGreen.withValues(alpha: 0.12);

    final rankBadgeLabel = rank == 1 ? '#1 Choice' : '#$rank';
    final actionLabel = isCaution ? 'Advisory details' : 'Planting plan';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTapPlan,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Crop Icon Box
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: visual.containerColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Icon(
                          visual.icon,
                          color: visual.iconColor,
                          size: 22.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.mdSm),

                    // Title & Scientific Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                visual.displayName,
                                style: AppTextStyles.headingSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: rank == 1
                                      ? AppColors.primaryGreen.withValues(alpha: 0.12)
                                      : AppColors.divider.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  rankBadgeLabel,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: rank == 1
                                        ? AppColors.primaryGreen
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            recommendation.scientificName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Score Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${recommendation.scorePercent}%',
                          style: AppTextStyles.headingMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          isCaution ? 'Caution' : 'Match',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isCaution
                                ? AppColors.warning
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.mdSm),

                // Color-coded progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: (recommendation.scorePercent / 100.0).clamp(0.0, 1.0),
                    minHeight: 6.0,
                    backgroundColor: progressTrackColor,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: AppSpacing.mdSm),

                // Reason chips
                Wrap(
                  spacing: AppSpacing.xs + 2,
                  runSpacing: AppSpacing.xs + 2,
                  children: [
                    // Caution chip (if caution flag is set)
                    if (isCaution)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 2,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.thermostat_rounded,
                              size: 14.0,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              recommendation.cautionNote?.split('.').first ??
                                  'Too warm this season',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Normal reason chips
                    ...recommendation.reasonChips.map((chip) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 2,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          chip,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: AppSpacing.mdSm),

                // Divider
                const Divider(color: AppColors.divider, height: 1.0),
                const SizedBox(height: AppSpacing.sm),

                // Bottom Footer Row: Harvest Days & Action Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14.0,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          'Harvest in ~${recommendation.harvestDays} days',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Semantics(
                      button: true,
                      label: '$actionLabel for ${visual.displayName}',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionLabel,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2.0),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16.0,
                            color: AppColors.primaryGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CropVisualDetails {
  final Color containerColor;
  final Color iconColor;
  final IconData icon;
  final String displayName;

  const _CropVisualDetails({
    required this.containerColor,
    required this.iconColor,
    required this.icon,
    required this.displayName,
  });
}
