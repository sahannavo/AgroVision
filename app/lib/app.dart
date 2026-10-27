import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_radius.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';

/// Root application widget for AgroVision.
class AgroVisionApp extends StatelessWidget {
  const AgroVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroVision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const PlaceholderHomeScreen(),
    );
  }
}

/// Simple placeholder screen displayed until router and feature screens are implemented.
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AgroVision')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(
                  Icons.eco,
                  size: 48,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('AgroVision', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Smart Agricultural Management & Crop Diagnosis',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.healthy,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text(
                            'Task 1: Theme & Core Foundation',
                            style: AppTextStyles.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Material 3 Light Theme Active',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
