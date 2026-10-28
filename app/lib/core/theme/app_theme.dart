import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme definition for AgroVision
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: AppColors.white,
        onSurface: AppColors.text,
      ),
    );
  }
}

