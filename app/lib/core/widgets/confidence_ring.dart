import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A circular confidence indicator ring that displays a percentage value
/// in the centre along with an optional caption (e.g., "MATCH").
///
/// Automatically switches stroke color to [AppColors.warning] when confidence
/// is below [warningThreshold] (defaults to 0.70 / 70%), and [AppColors.primaryGreen]
/// when equal or above.
///
/// Example:
/// ```dart
/// ConfidenceRing(
///   confidence: 0.92,
///   caption: 'MATCH',
/// )
/// ```
class ConfidenceRing extends StatelessWidget {
  /// Confidence value between 0.0 and 1.0 (or percentage 0 to 100).
  /// Values greater than 1.0 will be normalized assuming a 0-100 range.
  final double confidence;

  /// Optional caption displayed beneath the percentage (e.g., "MATCH").
  final String? caption;

  /// Size (diameter) of the ring widget. Defaults to 64.0.
  final double size;

  /// Stroke width of the ring circle. Defaults to 5.0.
  final double strokeWidth;

  /// Threshold below which the color turns to [AppColors.warning].
  /// Default is 0.70 (70%).
  final double warningThreshold;

  /// Custom color override for the progress arc.
  /// If null, determined dynamically by [warningThreshold].
  final Color? color;

  /// Background track color for the uncompleted portion of the ring.
  final Color? trackColor;

  /// Optional semantic label for screen readers.
  final String? semanticsLabel;

  const ConfidenceRing({
    super.key,
    required this.confidence,
    this.caption,
    this.size = 64.0,
    this.strokeWidth = 5.0,
    this.warningThreshold = 0.70,
    this.color,
    this.trackColor,
    this.semanticsLabel,
  });

  /// Normalizes the confidence value into a 0.0 .. 1.0 fraction.
  double get _normalizedValue {
    if (confidence.isNaN || confidence.isInfinite) return 0.0;
    if (confidence > 1.0) {
      return (confidence / 100.0).clamp(0.0, 1.0);
    }
    return confidence.clamp(0.0, 1.0);
  }

  /// Percentage integer representation (0 - 100).
  int get percentage => (_normalizedValue * 100).round();

  /// Resolves the progress arc color.
  Color get _resolvedColor {
    if (color != null) return color!;
    return _normalizedValue >= warningThreshold
        ? AppColors.primaryGreen
        : AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final value = _normalizedValue;
    final arcColor = _resolvedColor;
    final resolvedTrackColor = trackColor ?? AppColors.divider;
    final label = semanticsLabel ??
        '$percentage percent ${caption != null ? caption! : "confidence"}';

    return Semantics(
      container: true,
      label: label,
      value: '$percentage%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(arcColor),
                backgroundColor: resolvedTrackColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(strokeWidth),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: size * 0.28,
                        height: 1.0,
                      ),
                    ),
                    if (caption != null && caption!.isNotEmpty) ...[
                      const SizedBox(height: 1.0),
                      Text(
                        caption!.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: (size * 0.15).clamp(8.0, 11.0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.textSecondary,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
