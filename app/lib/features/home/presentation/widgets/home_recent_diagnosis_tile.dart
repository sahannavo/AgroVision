import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../diagnosis/domain/diagnosis.dart';

class HomeRecentDiagnosisTile extends StatelessWidget {
  const HomeRecentDiagnosisTile({required this.diagnosis, super.key});

  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.borderLg,
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.45),
            ),
          ),
          child: const Icon(
            Icons.bug_report_outlined,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${diagnosis.predictedClass.displayName} · ${diagnosis.cropType}',
                style: AppTextStyles.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    color: AppColors.warning.withValues(alpha: 0.1),
                    child: Text(
                      '${(diagnosis.confidence * 100).round()}% confidence',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Yesterday', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
      ],
    ),
  );
}
