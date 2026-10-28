import 'package:flutter/material.dart';

/// Corner radius tokens for AgroVision
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double button = 12.0;

  static final BorderRadius buttonBorderRadius = BorderRadius.circular(button);
}

/// Corner radius tokens for cards, buttons, dialogs, and chips across AgroVision.
abstract final class AppRadius {
  /// 4.0
  static const double xs = 4.0;

  /// 8.0
  static const double sm = 8.0;

  /// 12.0
  static const double md = 12.0;

  /// 16.0
  static const double lg = 16.0;

  /// 24.0
  static const double xl = 24.0;

  /// 32.0
  static const double xxl = 32.0;

  /// 999.0 for pills and circular borders
  static const double full = 999.0;

  // Pre-built BorderRadius instances
  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderFull = BorderRadius.all(
    Radius.circular(full),
  );
}
