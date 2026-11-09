import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeOfflineNotice extends StatelessWidget {
  const HomeOfflineNotice({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: AppColors.disabled,
      borderRadius: AppRadius.borderMd,
    ),
    child: Row(
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Offline. Showing weather saved 2 hours ago.',
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    ),
  );
}

class HomeOfflineAlertsCard extends StatelessWidget {
  const HomeOfflineAlertsCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.borderLg,
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.background,
          child: Icon(Icons.cloud_off_outlined, color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alerts unavailable offline',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Connect to the internet to check recent pest and disease reports',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
