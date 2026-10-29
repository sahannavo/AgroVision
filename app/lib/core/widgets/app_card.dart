import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A reusable surface card widget designed for the AgroVision design system.
///
/// Features:
/// - White card surface ([AppColors.cardSurface]).
/// - Default rounded corners of radius 16 ([AppRadius.lg]).
/// - Soft green-tinted elevation shadow.
/// - Optional tap handling with ink ripple effect.
/// - Optional severity stripe on the left edge.
/// - Support for an enabled/disabled state.
///
/// ### Example Usage:
/// ```dart
/// AppCard(
///   onTap: () => print('Card tapped'),
///   stripeColor: AppColors.waterBlue,
///   child: Text('Card content here'),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// The primary content of the card.
  final Widget child;

  /// Optional callback invoked when the card is tapped.
  final VoidCallback? onTap;

  /// Optional callback invoked on a long-press gesture.
  final VoidCallback? onLongPress;

  /// Padding applied inside the card around [child].
  /// Defaults to [AppSpacing.md] (16.0).
  final EdgeInsetsGeometry padding;

  /// Margin around the outer edge of the card.
  final EdgeInsetsGeometry? margin;

  /// Optional accent color for a left-edge severity or indicator stripe.
  final Color? stripeColor;

  /// Width of the left-edge severity stripe when [stripeColor] is provided.
  /// Defaults to 4.0.
  final double stripeWidth;

  /// Corner radius of the card. Defaults to [AppRadius.borderLg] (16.0).
  final BorderRadius? borderRadius;

  /// Background color of the card. Defaults to [AppColors.cardSurface].
  final Color? backgroundColor;

  /// Border outline for the card. Defaults to a 1px border with [AppColors.divider].
  final BoxBorder? border;

  /// Whether the card responds to interactions. Defaults to true.
  final bool enabled;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.stripeColor,
    this.stripeWidth = 4.0,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.enabled = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.borderLg;
    final effectiveBgColor = backgroundColor ?? AppColors.cardSurface;
    final isInteractive = enabled && (onTap != null || onLongPress != null);

    // Soft green-tinted shadow
    final cardBoxShadow = [
      BoxShadow(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        blurRadius: 16.0,
        spreadRadius: 0.0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 4.0,
        spreadRadius: 0.0,
        offset: const Offset(0, 1),
      ),
    ];

    final effectiveBorder = border ?? Border.all(
      color: AppColors.divider,
      width: 1.0,
    );

    Widget cardContent = padding == EdgeInsets.zero
        ? child
        : Padding(padding: padding, child: child);

    if (stripeColor != null) {
      cardContent = Stack(
        children: [
          cardContent,
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: stripeWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: enabled ? stripeColor : stripeColor!.withValues(alpha: 0.4),
                borderRadius: BorderRadius.only(
                  topLeft: effectiveRadius.topLeft,
                  bottomLeft: effectiveRadius.bottomLeft,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget result = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
        boxShadow: cardBoxShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Material(
          color: Colors.transparent,
          child: isInteractive
              ? InkWell(
                  onTap: enabled ? onTap : null,
                  onLongPress: enabled ? onLongPress : null,
                  child: cardContent,
                )
              : cardContent,
        ),
      ),
    );

    if (semanticLabel != null) {
      result = Semantics(
        label: semanticLabel,
        enabled: enabled,
        button: isInteractive,
        child: result,
      );
    }

    return result;
  }
}
