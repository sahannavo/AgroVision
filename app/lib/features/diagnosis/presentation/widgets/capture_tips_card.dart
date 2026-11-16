import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Card showing guidance tips for better leaf capture in low confidence mode.
class CaptureTipsCard extends StatelessWidget {
  const CaptureTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: AppRadius.borderSm,
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Tips for better capture',
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: AppRadius.borderFull,
                ),
                child: const Text(
                  'Guidance',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTipItem(
            icon: Icons.wb_sunny_outlined,
            title: 'Daylight conditions',
            description:
                'Ensure bright natural daylight and avoid heavy backlight or dark shadows on leaf surface.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildTipItem(
            icon: Icons.filter_center_focus_rounded,
            title: 'Single leaf in focus',
            description:
                'Center one infected leaf with spots visible. Keep phone camera still at 15–20 cm distance.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildTipItem(
            icon: Icons.motion_photos_off_rounded,
            title: 'Avoid motion blur',
            description:
                'Hold the leaf steady against wind movement so lesion patterns and edges stay sharp.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.mdSm),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF6),
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 18),
          ),
          const SizedBox(width: AppSpacing.mdSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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
}
