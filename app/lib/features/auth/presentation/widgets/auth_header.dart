import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shared AgroVision logo + wordmark + sub-label header used on auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo mark
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: AppRadius.borderSm,
          ),
          child: const Icon(
            Icons.energy_savings_leaf_rounded,
            color: AppColors.textOnPrimary,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AgroVision',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primaryGreen,
              ),
            ),
            Text(
              'SRI LANKA',
              style: AppTextStyles.labelSmall.copyWith(
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
