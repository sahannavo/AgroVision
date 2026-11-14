import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../alerts/domain/outbreak_alert.dart';

class HomeOutbreakBanner extends StatelessWidget {
  const HomeOutbreakBanner({
    required this.alert,
    required this.onViewSteps,
    super.key,
  });

  final OutbreakAlert alert;
  final VoidCallback onViewSteps;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.warning.withValues(alpha: 0.08),
      borderRadius: AppRadius.borderLg,
      border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.warning.withValues(alpha: 0.2),
          child: Icon(Icons.warning_amber_rounded, color: AppColors.warning),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${alert.disease} reported within ${alert.radiusKm.round()} km',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${alert.reportCount} reports this week in Mawathagama',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onViewSteps,
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            backgroundColor: AppColors.warning.withValues(alpha: 0.2),
            foregroundColor: AppColors.warning,
          ),
          child: const Text('View steps'),
        ),
      ],
    ),
  );
}
