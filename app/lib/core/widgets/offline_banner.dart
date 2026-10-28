import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/connectivity_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A small pill tag used in top bars and headers to indicate offline status.
///
/// Example usage:
/// ```dart
/// if (!isOnline) const OfflinePill()
/// ```
class OfflinePill extends StatelessWidget {
  /// The label displayed inside the pill. Defaults to `'Offline'`.
  final String label;

  /// Whether the pill is enabled. When disabled, colors are muted.
  final bool enabled;

  const OfflinePill({
    super.key,
    this.label = 'Offline',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = enabled
        ? AppColors.warning.withOpacity(0.14)
        : AppColors.disabled;
    final contentColor = enabled ? AppColors.warning : AppColors.disabledText;

    return Semantics(
      label: 'Network status: $label',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: enabled
                ? AppColors.warning.withOpacity(0.3)
                : AppColors.disabled,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 14.0,
              color: contentColor,
              semanticLabel: 'Offline icon',
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A slim banner displayed across the screen to inform farmers when the app is offline.
///
/// Offers a standard explicit constructor and an [OfflineBanner.auto] constructor
/// that automatically listens to [connectivityProvider] and displays only when offline.
///
/// Example usage:
/// ```dart
/// // Standard banner:
/// const OfflineBanner(
///   message: 'Offline. Showing weather saved 2 hours ago.',
/// )
///
/// // Auto banner (watches connectivityProvider):
/// const OfflineBanner.auto(
///   message: 'Offline. Showing weather saved 2 hours ago.',
/// )
/// ```
class OfflineBanner extends StatelessWidget {
  /// Informational message explaining the offline status and fallback data.
  final String message;

  /// Optional trailing widget, e.g. a refresh button or sync state indicator.
  final Widget? trailing;

  /// Whether the banner is in an enabled state. Mutes colors when disabled.
  final bool enabled;

  /// Internal flag indicating whether this banner automatically listens to [connectivityProvider].
  final bool auto;

  /// Standard constructor for [OfflineBanner].
  const OfflineBanner({
    super.key,
    this.message = 'Offline. Showing weather saved 2 hours ago.',
    this.trailing,
    this.enabled = true,
  }) : auto = false;

  /// Auto constructor that automatically monitors [connectivityProvider]
  /// and shows the banner only when the device is offline.
  const OfflineBanner.auto({
    super.key,
    this.message = 'Offline. Showing weather saved 2 hours ago.',
    this.trailing,
    this.enabled = true,
  }) : auto = true;

  Widget _buildContent(BuildContext context) {
    final backgroundColor = enabled
        ? AppColors.warning.withOpacity(0.12)
        : AppColors.disabled;
    final iconColor = enabled ? AppColors.warning : AppColors.disabledText;
    final textColor = enabled ? AppColors.textPrimary : AppColors.disabledText;

    return Semantics(
      label: 'Offline banner: $message',
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: enabled
                  ? AppColors.warning.withOpacity(0.25)
                  : AppColors.disabled,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 18.0,
              color: iconColor,
              semanticLabel: 'Offline indicator',
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!auto) {
      return _buildContent(context);
    }

    return Consumer(
      builder: (context, ref, _) {
        final isOnline = ref.watch(connectivityProvider);
        if (isOnline) {
          return const SizedBox.shrink();
        }
        return _buildContent(context);
      },
    );
  }
}
