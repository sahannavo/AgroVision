import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A reusable empty state display widget for AgroVision.
///
/// Follows the design specifications in `docs/design/` (such as `Planner, no crop plots.png`):
/// - Slot for an illustration or icon ([illustration]).
/// - Prominent title text ([title]).
/// - Informative subtitle or message ([message]).
/// - Optional primary action button ([buttonLabel], [onButtonPressed], [buttonIcon]).
/// - Optional custom content slot ([extraContent]) for chips, badges, or hints.
///
/// ### Example Usage:
/// ```dart
/// EmptyState(
///   illustration: Icon(Icons.eco_outlined, size: 72, color: AppColors.primaryGreen),
///   title: 'No crop plots yet',
///   message: 'Add a plot to get a tailored watering and fertilizer schedule.',
///   buttonLabel: 'Add crop plot',
///   buttonIcon: Icons.add_circle_outline,
///   onButtonPressed: () => showAddCropPlotSheet(context),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// The slot for the empty state visual (an image, icon, or styled container).
  final Widget illustration;

  /// The primary headline explaining the empty state.
  final String title;

  /// Explanatory guidance message.
  final String message;

  /// Optional label for the primary action button.
  final String? buttonLabel;

  /// Optional icon displayed alongside the [buttonLabel].
  final IconData? buttonIcon;

  /// Callback executed when the primary button is tapped.
  final VoidCallback? onButtonPressed;

  /// Optional custom widget rendered below the message and above the button
  /// (e.g. crop tags, setup templates, helper chips).
  final Widget? extraContent;

  /// Padding around the empty state content. Defaults to [AppSpacing.lg].
  final EdgeInsetsGeometry padding;

  /// Whether the primary button is interactive. Defaults to true.
  final bool buttonEnabled;

  const EmptyState({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.buttonIcon,
    this.onButtonPressed,
    this.extraContent,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.buttonEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            illustration,
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            if (extraContent != null) ...[
              const SizedBox(height: AppSpacing.md),
              extraContent!,
            ],
            if (buttonLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: buttonEnabled ? onButtonPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.lg,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                    textStyle: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (buttonIcon != null) ...[
                        Icon(buttonIcon, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(buttonLabel!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
