import 'package:flutter/material.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Farm registration screen stub for route [AppRoutes.registerFarm].
class RegisterFarmScreen extends StatelessWidget {
  const RegisterFarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Register Farm'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.agriculture_rounded,
                size: 56,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('RegisterFarmScreen', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Route: ${AppRoutes.registerFarm}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

