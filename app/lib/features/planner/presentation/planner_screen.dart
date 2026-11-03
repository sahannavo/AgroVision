import 'package:flutter/material.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Irrigation and task planner screen stub for route [AppRoutes.planner].
class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Planner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 56,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('PlannerScreen', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Route: ${AppRoutes.planner}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

