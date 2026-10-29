import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Full-width secondary outlined button for the AgroVision application.
///
/// Styled with a white surface background, deep green border outline,
/// deep green label, rounded corners (12dp), and a fixed height of 52dp.
/// Supports optional leading icon, loading spinner, and disabled state.
///
/// Usage example:
/// ```dart
/// SecondaryButton(
///   label: 'Scan another leaf',
///   onPressed: () => print('Scanning again'),
///   icon: const Icon(Icons.camera_alt_outlined, size: 20),
/// )
/// ```
class SecondaryButton extends StatelessWidget {
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

  const SecondaryButton({
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
    final effectiveTextColor = _isEnabled
        ? AppColors.primary
        : AppColors.disabledText;

    final effectiveTextStyle = _isEnabled
        ? AppTextStyles.buttonSecondary
        : AppTextStyles.buttonDisabled;

    final effectiveBorderSide = BorderSide(
      color: _isEnabled ? AppColors.primary : AppColors.disabled,
      width: 1.5,
    );

    final content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme.merge(
                  data: IconThemeData(
                    size: 20,
                    color: effectiveTextColor,
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
        child: OutlinedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            disabledBackgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.disabledText,
            side: effectiveBorderSide,
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
