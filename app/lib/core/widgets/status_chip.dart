import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A compact pill chip used across AgroVision to indicate status, severity,
/// or sync state.
///
/// Provides named constructors for standard statuses:
/// - [StatusChip.healthy]
/// - [StatusChip.moderate]
/// - [StatusChip.highRisk]
/// - [StatusChip.needsAttention]
/// - [StatusChip.synced]
/// - [StatusChip.pending]
///
/// Example:
/// ```dart
/// StatusChip.moderate(label: 'Moderate')
/// StatusChip.healthy(label: 'Zero Pathogens')
/// StatusChip.highRisk(label: 'High Risk')
/// ```
class StatusChip extends StatelessWidget {
  /// The text label displayed on the chip.
  final String label;

  /// Optional leading icon or widget (e.g. check, dot, warning icon).
  final Widget? icon;

  /// Background color of the chip pill.
  final Color backgroundColor;

  /// Text and icon color.
  final Color foregroundColor;

  /// Optional border outline color.
  final Color? borderColor;

  /// Whether the chip is enabled. If false, opacity is reduced and interactions disabled.
  final bool isEnabled;

  /// Optional callback when tapped.
  final VoidCallback? onTap;

  /// Optional custom padding. Defaults to horizontal 10.0, vertical 4.0.
  final EdgeInsetsGeometry padding;

  /// Optional semantics label for screen readers.
  final String? semanticsLabel;

  const StatusChip({
    super.key,
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.isEnabled = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm + AppSpacing.xxs,
      vertical: AppSpacing.xs,
    ),
    this.semanticsLabel,
  });

  /// Factory helper to build a small colored indicator dot.
  static Widget _buildDot(Color color) {
    return Container(
      width: 7.0,
      height: 7.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Named constructor for **Healthy** status.
  /// Light green background with dark healthy green text and optional check/dot icon.
  factory StatusChip.healthy({
    Key? key,
    required String label,
    Widget? icon,
    bool isEnabled = true,
    VoidCallback? onTap,
    bool showDot = false,
  }) {
    const green = AppColors.healthy;
    return StatusChip(
      key: key,
      label: label,
      isEnabled: isEnabled,
      onTap: onTap,
      backgroundColor: const Color(0xFFE8F5E9),
      foregroundColor: green,
      borderColor: const Color(0xFFC8E6C9),
      icon: icon ?? (showDot ? _buildDot(green) : const Icon(Icons.check_circle_rounded, size: 14.0, color: green)),
    );
  }

  /// Named constructor for **Moderate** severity status.
  /// Warm amber tinted background with amber text and an amber indicator dot.
  factory StatusChip.moderate({
    Key? key,
    required String label,
    Widget? icon,
    bool isEnabled = true,
    VoidCallback? onTap,
    bool showDot = true,
  }) {
    const amber = AppColors.warning;
    return StatusChip(
      key: key,
      label: label,
      isEnabled: isEnabled,
      onTap: onTap,
      backgroundColor: const Color(0xFFFFF3E0),
      foregroundColor: const Color(0xFFB25E00),
      borderColor: const Color(0xFFFFE0B2),
      icon: icon ?? (showDot ? _buildDot(amber) : null),
    );
  }

  /// Named constructor for **High Risk** severity status.
  /// Soft red tinted background with danger red text and red indicator dot or warning icon.
  factory StatusChip.highRisk({
    Key? key,
    required String label,
    Widget? icon,
    bool isEnabled = true,
    VoidCallback? onTap,
    bool showDot = true,
  }) {
    const red = AppColors.danger;
    return StatusChip(
      key: key,
      label: label,
      isEnabled: isEnabled,
      onTap: onTap,
      backgroundColor: const Color(0xFFFFEBEE),
      foregroundColor: red,
      borderColor: const Color(0xFFFFCDD2),
      icon: icon ?? (showDot ? _buildDot(red) : const Icon(Icons.warning_amber_rounded, size: 14.0, color: red)),
    );
  }

  /// Named constructor for **Needs Attention** status.
  /// Amber tint with an alert or attention indicator.
  factory StatusChip.needsAttention({
    Key? key,
    required String label,
    Widget? icon,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return StatusChip(
      key: key,
      label: label,
      isEnabled: isEnabled,
      onTap: onTap,
      backgroundColor: const Color(0xFFFFF8E1),
      foregroundColor: const Color(0xFFE65100),
      borderColor: const Color(0xFFFFE082),
      icon: icon ?? const Icon(Icons.info_outline_rounded, size: 14.0, color: Color(0xFFE65100)),
    );
  }

  /// Named constructor for **Synced** status.
  /// Blue/green tint indicating successful sync.
  factory StatusChip.synced({
    Key? key,
    required String label,
    Widget? icon,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    const blue = AppColors.info;
    return StatusChip(
      key: key,
      label: label,
      isEnabled: isEnabled,
      onTap: onTap,
      backgroundColor: const Color(0xFFE3F2FD),
      foregroundColor: blue,
      borderColor: const Color(0xFFBBDEFB),
      icon: icon ?? const Icon(Icons.cloud_done_rounded, size: 14.0, color: blue),
    );
  }

  /// Named constructor for **Pending** status.
  /// Neutral light grey/slate background with pending icon or dot.
  factory StatusChip.pending({
    Key? key,
    required String label,
    Widget? icon,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    const grey = AppColors.textSecondary;
    return StatusChip(
      key: key,
      label: label,
      isEnabled: isEnabled,
      onTap: onTap,
      backgroundColor: const Color(0xFFF0F3F0),
      foregroundColor: grey,
      borderColor: AppColors.divider,
      icon: icon ?? const Icon(Icons.hourglass_top_rounded, size: 14.0, color: grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = isEnabled ? 1.0 : 0.5;

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderFull,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.0)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: 12.0,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    if (onTap != null && isEnabled) {
      content = InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderFull,
        child: content,
      );
    }

    return Semantics(
      container: true,
      enabled: isEnabled,
      button: onTap != null,
      label: semanticsLabel ?? label,
      child: Opacity(
        opacity: effectiveOpacity,
        child: content,
      ),
    );
  }
}
