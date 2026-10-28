import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A reusable section header component for AgroVision screens.
///
/// Displays a section [title] with an optional action label (e.g., "Manage", "View all")
/// or a custom [trailing] widget (e.g., status badges, count tags).
///
/// ### Example Usage:
/// ```dart
/// SectionHeader(
///   title: "This week's plan",
///   actionLabel: 'View all',
///   onActionTap: () => print('View all tapped'),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  /// The main heading text for the section.
  final String title;

  /// Optional text label for an interactive trailing action.
  final String? actionLabel;

  /// Optional callback invoked when the [actionLabel] is pressed.
  final VoidCallback? onActionTap;

  /// Optional custom trailing widget (e.g., action counter chips, badges).
  /// Takes precedence over [actionLabel] if both are provided.
  final Widget? trailing;

  /// Inner padding for the header row. Defaults to vertical spacing of [AppSpacing.sm].
  final EdgeInsetsGeometry padding;

  /// TextStyle for the [title]. Defaults to [AppTextStyles.titleMedium].
  final TextStyle? titleStyle;

  /// TextStyle for the [actionLabel]. Defaults to [AppTextStyles.labelLarge].
  final TextStyle? actionStyle;

  /// Optional semantic label for the trailing action button.
  final String? actionSemanticLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(
      vertical: AppSpacing.sm,
      horizontal: AppSpacing.xs,
    ),
    this.titleStyle,
    this.actionStyle,
    this.actionSemanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle ?? AppTextStyles.titleMedium;
    final effectiveActionStyle = (actionStyle ?? AppTextStyles.labelLarge).copyWith(
      color: AppColors.primaryGreen,
      fontWeight: FontWeight.w600,
    );

    Widget? trailingWidget = trailing;

    if (trailingWidget == null && actionLabel != null) {
      trailingWidget = Semantics(
        button: true,
        label: actionSemanticLabel ?? actionLabel,
        child: InkWell(
          onTap: onActionTap,
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            child: Text(
              actionLabel!,
              style: effectiveActionStyle,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: effectiveTitleStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailingWidget != null) trailingWidget,
        ],
      ),
    );
  }
}
