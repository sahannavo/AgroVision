import 'package:flutter/material.dart';

/// Reusable application color tokens for the AgroVision design system.
///
/// Contains primary brand, status, text, and surface colors.
abstract final class AppColors {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lime = Color(0xFF8BC34A);
  static const Color waterBlue = Color(0xFF0288D1);

  // Background and Surface
  static const Color background = Color(0xFFF8FBF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E5E0);

  // Typography Colors
  static const Color textPrimary = Color(0xFF1A2E1C);
  static const Color textSecondary = Color(0xFF616E63);
  static const Color textTertiary = Color(0xFF8E9B90);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Semantic Colors
  static const Color healthy = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color danger = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // Overlay / Transparency
  static const Color barrier = Color(0x66000000);
}
