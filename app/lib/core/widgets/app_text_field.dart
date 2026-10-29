import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A standard input field following the AgroVision design system.
///
/// Adheres to:
/// - 52dp height constraint with 12dp corner radius ([AppRadius.md]).
/// - Floating label and optional hint text.
/// - Optional leading icon with muted semantic coloring.
/// - Trailing password visibility toggle or metric unit text (e.g., 'kg', 'ha').
/// - Error and disabled states with accessible touch targets (>= 48dp).
///
/// Example:
/// ```dart
/// AppTextField(
///   labelText: 'Field Location',
///   hintText: 'e.g., Kurunegala, NW',
///   leadingIcon: Icons.location_on_outlined,
///   controller: locationController,
/// )
///
/// AppTextField.password(
///   labelText: 'Password',
///   controller: passwordController,
/// )
///
/// AppTextField(
///   labelText: 'Land Size',
///   unitText: 'Acres',
///   keyboardType: TextInputType.number,
/// )
/// ```
class AppTextField extends StatefulWidget {
  /// Floating label text displayed on the field border.
  final String? labelText;

  /// Placeholder hint text displayed when input is empty.
  final String? hintText;

  /// Helper text displayed beneath the input field.
  final String? helperText;

  /// Error message displayed beneath the input field with danger styling.
  final String? errorText;

  /// Optional trailing measurement or currency unit (e.g., "kg", "ha").
  final String? unitText;

  /// Optional leading icon displayed inside the prefix area.
  final IconData? leadingIcon;

  /// Custom leading widget to override [leadingIcon].
  final Widget? prefix;

  /// Custom trailing widget to override default trailing behavior.
  final Widget? suffix;

  /// Controller for managing the text value.
  final TextEditingController? controller;

  /// Initial value if no [controller] is provided.
  final String? initialValue;

  /// Whether the input obscures text (useful for PINs or passwords).
  final bool isPassword;

  /// Whether the text field is interactive.
  final bool enabled;

  /// Whether the text field is read-only.
  final bool readOnly;

  /// Whether to auto-focus the field upon mounting.
  final bool autofocus;

  /// Maximum line count. Defaults to 1 for standard input fields.
  final int maxLines;

  /// Keyboard type for software input.
  final TextInputType? keyboardType;

  /// Action key on the software keyboard.
  final TextInputAction? textInputAction;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the user finishes entering text or presses submit.
  final ValueChanged<String>? onSubmitted;

  /// Tap callback when field is tapped (useful for date pickers or dropdown sheets).
  final VoidCallback? onTap;

  /// Form field validation callback.
  final FormFieldValidator<String>? validator;

  /// Focus node for controlling field focus.
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.unitText,
    this.leadingIcon,
    this.prefix,
    this.suffix,
    this.controller,
    this.initialValue,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
  });

  /// Factory constructor configured specifically for password or secret inputs.
  const AppTextField.password({
    super.key,
    this.labelText = 'Password',
    this.hintText,
    this.helperText,
    this.errorText,
    this.unitText,
    this.leadingIcon = Icons.lock_outline_rounded,
    this.prefix,
    this.suffix,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.visiblePassword,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
  })  : isPassword = true,
        maxLines = 1;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPassword != widget.isPassword) {
      _obscureText = widget.isPassword;
    }
  }

  Widget? _buildPrefix() {
    if (widget.prefix != null) return widget.prefix;
    if (widget.leadingIcon == null) return null;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.sm,
      ),
      child: Icon(
        widget.leadingIcon,
        color: widget.enabled ? AppColors.textSecondary : AppColors.textTertiary,
        size: 20.0,
      ),
    );
  }

  Widget? _buildSuffix() {
    if (widget.suffix != null) return widget.suffix;

    if (widget.isPassword) {
      final isCurrentlyObscured = _obscureText;
      return Semantics(
        label: isCurrentlyObscured ? 'Show password' : 'Hide password',
        button: true,
        child: IconButton(
          icon: Icon(
            isCurrentlyObscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: widget.enabled
                ? AppColors.textSecondary
                : AppColors.textTertiary,
            size: 20.0,
          ),
          onPressed: widget.enabled
              ? () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                }
              : null,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          splashRadius: 20,
        ),
      );
    }

    if (widget.unitText != null && widget.unitText!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Center(
          widthFactor: 1,
          child: Text(
            widget.unitText!,
            style: AppTextStyles.labelMedium.copyWith(
              color: widget.enabled
                  ? AppColors.textSecondary
                  : AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = widget.enabled;

    final border = OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(
        color: AppColors.divider,
        width: 1.0,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(
        color: AppColors.primaryGreen,
        width: 1.5,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(
        color: AppColors.danger,
        width: 1.0,
      ),
    );

    final focusedErrorBorder = OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(
        color: AppColors.danger,
        width: 1.5,
      ),
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(
        color: AppColors.divider.withValues(alpha: 0.5),
        width: 1.0,
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52.0),
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        focusNode: widget.focusNode,
        enabled: effectiveEnabled,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        obscureText: _obscureText,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        validator: widget.validator,
        style: AppTextStyles.bodyMedium.copyWith(
          color: effectiveEnabled
              ? AppColors.textPrimary
              : AppColors.textTertiary,
        ),
        cursorColor: AppColors.primaryGreen,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          prefixIcon: _buildPrefix(),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 48,
          ),
          suffixIcon: _buildSuffix(),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          filled: true,
          fillColor: effectiveEnabled
              ? AppColors.surface
              : AppColors.divider.withValues(alpha: 0.25),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14.0,
          ),
          isDense: true,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          floatingLabelStyle: AppTextStyles.labelMedium.copyWith(
            color: widget.errorText != null
                ? AppColors.danger
                : AppColors.primaryGreen,
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          errorStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.danger,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: focusedErrorBorder,
          disabledBorder: disabledBorder,
        ),
      ),
    );
  }
}
