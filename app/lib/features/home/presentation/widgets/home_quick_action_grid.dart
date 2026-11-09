import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeQuickActionGrid extends StatelessWidget {
  const HomeQuickActionGrid({
    required this.onScan,
    required this.onAdvisor,
    required this.onPlanner,
    required this.onHistory,
    super.key,
  });

  final VoidCallback onScan;
  final VoidCallback onAdvisor;
  final VoidCallback onPlanner;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        'Scan leaf',
        'Instant AI pest check',
        Icons.camera_alt_outlined,
        AppColors.healthy,
        onScan,
      ),
      (
        'Planting Advisor',
        'Maha season guides',
        Icons.agriculture_outlined,
        AppColors.healthy,
        onAdvisor,
      ),
      (
        'Irrigation planner',
        'Schedule watering',
        Icons.water_drop_outlined,
        AppColors.waterBlue,
        onPlanner,
      ),
      (
        'History',
        'Past scan records',
        Icons.history,
        AppColors.textSecondary,
        onHistory,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, index) {
        final action = actions[index];
        return Semantics(
          button: true,
          label: action.$1,
          child: InkWell(
            onTap: action.$5,
            borderRadius: AppRadius.borderLg,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderLg,
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(action.$3, color: action.$4, size: 25),
                  const Spacer(),
                  Text(action.$1, style: AppTextStyles.titleSmall),
                  Text(action.$2, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
