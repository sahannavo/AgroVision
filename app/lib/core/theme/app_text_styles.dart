import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography tokens for AgroVision
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle button = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonDisabled = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.disabledText,
    letterSpacing: 0.2,
  );
}

