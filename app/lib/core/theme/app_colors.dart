import 'package:flutter/material.dart';

/// Reusable application color tokens for the AgroVision design system.
///
/// Contains primary brand, status, text, and surface colors.
abstract final class AppColors {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primary = primaryGreen;
  static const Color primaryLight = lime;
  static const Color primaryContainer = successLight;
  static const Color lime = Color(0xFF8CBF3F);
  static const Color waterBlue = Color(0xFF0288D1);

  // Background and Surface
  static const Color background = Color(0xFFF8FBF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F1);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardBackground = cardSurface;
  static const Color divider = Color(0xFFE0E5E0);
  static const Color outline = divider;
  static const Color offlineBanner = Color(0xFF455A64);
  static const Color mapUserMarker = waterBlue;

  // Typography Colors
  static const Color text = Color(0xFF1E293B);
  static const Color textPrimary = text;
  static const Color secondaryText = Color(0xFF64748B);
  static const Color textSecondary = secondaryText;
  static const Color textTertiary = Color(0xFF8E9B90);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color onPrimary = textOnPrimary;

  // Status & Semantic Colors
  static const Color healthy = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color danger = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color unreadDot = danger;
  static const Color highRisk = danger;
  static const Color moderateRisk = warning;
  static const Color peripheral = textSecondary;
  static const Color highRiskBg = Color(0xFFFFEBEE);
  static const Color moderateRiskBg = Color(0xFFFFF3E0);
  static const Color peripheralBg = Color(0xFFECEFF1);
  static const Color error = danger;

  // Disabled State
  static const Color disabled = Color(0xFFE2E8F0);
  static const Color disabledText = Color(0xFF94A3B8);

  // Neutrals & Shortcuts
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color barrier = Color(0x66000000);
}
