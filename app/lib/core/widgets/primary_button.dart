import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Full-width primary action button for the AgroVision application.
///
/// Styled with deep green background, white label, rounded corners (12dp),
/// and a fixed height of 52dp. Supports optional leading icon, loading spinner,
/// and disabled state.
///
/// Usage example:
/// ```dart
/// PrimaryButton(
///   label: 'Log in',
///   onPressed: () => print('Submitted'),
///   isLoading: false,
///   icon: const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  /// Button text label.
  final String label;

  /// Callback when button is tapped. When null, the button is rendered disabled.
  final VoidCallback? onPressed;

  /// Shows a circular progress spinner instead of label/icon when true.
  final bool isLoading;

  /// Optional leading icon displayed before the label.
  final Widget? icon;

  /// Button height, defaults to 52dp as specified in the design system.
  final double height;

  /// Button width, defaults to full width (double.infinity).
  final double? width;

  /// Accessibility semantics label override.
  final String? semanticsLabel;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 52.0,
    this.width = double.infinity,
    this.semanticsLabel,
  });

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = _isEnabled
        ? AppTextStyles.button
        : AppTextStyles.buttonDisabled;

    final content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme.merge(
                  data: const IconThemeData(
                    size: 20,
                    color: AppColors.white,
                  ),
                  child: icon!,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  style: effectiveTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: semanticsLabel ?? label,
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.disabled,
            foregroundColor: AppColors.white,
            disabledForegroundColor: AppColors.disabledText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}
