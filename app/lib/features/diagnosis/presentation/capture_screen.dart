import 'package:flutter/material.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Diagnosis capture screen stub for route [AppRoutes.diagnoseCapture].
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Capture Crop Leaf'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_rounded,
                size: 56,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('CaptureScreen', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Route: ${AppRoutes.diagnoseCapture}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

