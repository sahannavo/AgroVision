import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../crop_plots/presentation/add_crop_plot_sheet.dart';

/// Empty state view displayed on the Planner screen when no crop plots exist.
///
/// Closely matches the visual specification in `docs/design/planner_empty.png`.
class PlannerEmptyState extends StatelessWidget {
  /// Callback when the "Add crop plot" button is tapped.
  /// If null, defaults to invoking [showAddCropPlotSheet].
  final VoidCallback? onAddCropPlot;

  const PlannerEmptyState({
    super.key,
    this.onAddCropPlot,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Empty Card with illustration, message, chips and Add Crop Plot button
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: EmptyState(
              padding: EdgeInsets.zero,
              illustration: _buildIllustration(),
              title: 'No crop plots yet',
              message:
                  'Add a plot to get a tailored watering and fertilizer schedule.',
              extraContent: _buildCropChips(),
              buttonLabel: 'Add crop plot',
              buttonIcon: Icons.add_circle_outline,
              onButtonPressed: onAddCropPlot ?? () => showAddCropPlotSheet(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Informational guide banner
          _buildPrecisionScheduleInfoCard(),
          const SizedBox(height: AppSpacing.lg),

          // Fast Setup Templates section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FAST SETUP TEMPLATES',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                  fontSize: 12,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'Auto-fill soil',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Two fast setup template cards
          Row(
            children: [
              Expanded(
                child: _buildTemplateCard(
                  icon: Icons.local_florist_outlined,
                  title: 'Maha Season',
                  subtitle: 'Yala & Dry Zone',
                  onTap: onAddCropPlot ?? () => showAddCropPlotSheet(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildTemplateCard(
                  icon: Icons.water_drop_outlined,
                  title: 'Drip Line Plot',
                  subtitle: 'Sensor Linked',
                  onTap: onAddCropPlot ?? () => showAddCropPlotSheet(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// Custom circular water drop & plant badge matching planner_empty.png
  Widget _buildIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFD1E8FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco,
              size: 40,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFC6E070),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Tag chip row (Tomato • Chilli • Brinjal • Potato)
  Widget _buildCropChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(AppColors.primaryGreen),
          const SizedBox(width: 4),
          const Text('Tomato', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          _buildDot(AppColors.primaryGreen),
          const SizedBox(width: 4),
          const Text('Chilli', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          _buildDot(AppColors.waterBlue),
          const SizedBox(width: 4),
          const Text('Brinjal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          _buildDot(AppColors.primaryGreen),
          const SizedBox(width: 4),
          const Text('Potato', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Informational card with eco leaf icon
  Widget _buildPrecisionScheduleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3E8),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFD6EAD6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco,
              size: 18,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precision schedules for your field',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AgroVision calculates tailored irrigation and fertilizer recommendations for tomato, chilli, potato, and eggplant based on local Sri Lankan weather and soil sensors.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Template card for fast setup
  Widget _buildTemplateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
