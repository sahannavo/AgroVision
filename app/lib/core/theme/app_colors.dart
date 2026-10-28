import 'package:flutter/material.dart';

/// App color tokens for AgroVision sampled from design specification.
class AppColors {
  AppColors._();

  /// Primary deep green for main buttons and active states
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryGreen = primary;

  /// Lime accent for scan lines, corner brackets, highlights
  static const Color lime = Color(0xFF8CBF3F);

  /// Water blue for irrigation, rainfall
  static const Color waterBlue = Color(0xFF29B6F6);

  /// Screen background color
  static const Color background = Color(0xFFF8FAF7);

  /// Card/surface background
  static const Color surface = Color(0xFFFFFFFF);

  /// Primary text color
  static const Color text = Color(0xFF1E293B);

  /// Secondary text color
  static const Color secondaryText = Color(0xFF64748B);

  /// Status colors
  static const Color healthy = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  /// Disabled state colors
  static const Color disabled = Color(0xFFE2E8F0);
  static const Color disabledText = Color(0xFF94A3B8);

  /// Neutral shortcuts
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

