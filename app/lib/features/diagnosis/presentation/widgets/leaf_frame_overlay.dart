import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Top HUD bar displayed above the camera preview.
///
/// Features:
/// - Back navigation button (tap target >= 48dp)
/// - Offline badge pill: "AI runs on your phone" with a cloud-off icon
/// - Flash mode toggle button
class CameraTopBar extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onFlashPressed;
  final CameraFlashMode flashMode;

  const CameraTopBar({
    super.key,
    this.onBackPressed,
    this.onFlashPressed,
    this.flashMode = CameraFlashMode.off,
  });

  IconData _getFlashIcon() {
    switch (flashMode) {
      case CameraFlashMode.torch:
      case CameraFlashMode.always:
        return Icons.flash_on_rounded;
      case CameraFlashMode.auto:
        return Icons.flash_auto_rounded;
      case CameraFlashMode.off:
        return Icons.flash_off_rounded;
    }
  }

  String _getFlashSemantics() {
    switch (flashMode) {
      case CameraFlashMode.torch:
      case CameraFlashMode.always:
        return 'Flash on, tap to change';
      case CameraFlashMode.auto:
        return 'Flash auto, tap to change';
      case CameraFlashMode.off:
        return 'Flash off, tap to change';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            Semantics(
              button: true,
              label: 'Back',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBackPressed,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0x66000000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            // AI Status Pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 4,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: const Color(0x80000000),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.lime,
                    size: 15,
                  ),
                  SizedBox(width: AppSpacing.xs + 2),
                  Text(
                    'AI runs on your phone',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Flash mode toggle
            Semantics(
              button: true,
              label: _getFlashSemantics(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onFlashPressed,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0x66000000),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getFlashIcon(),
                      color: flashMode == CameraFlashMode.off
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.lime,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Viewfinder overlay with rounded leaf frame cutout, lime corner brackets,
/// and guidance hint chip.
class LeafFrameOverlay extends StatelessWidget {
  /// Aspect ratio of the central target cutout (width / height).
  final double aspectRatio;

  /// Corner bracket length in pixels.
  final double cornerLength;

  /// Corner bracket stroke width.
  final double strokeWidth;

  const LeafFrameOverlay({
    super.key,
    this.aspectRatio = 0.85,
    this.cornerLength = 32.0,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Leaf frame dimensions: width ~76% of screen width
        final frameWidth = math.min(screenWidth * 0.78, 340.0);
        final frameHeight = frameWidth / aspectRatio;

        final left = (screenWidth - frameWidth) / 2;
        final top = (screenHeight - frameHeight) / 2 - 20; // Slight upward offset for bottom controls
        final frameRect = Rect.fromLTWH(left, top, frameWidth, frameHeight);

        return Stack(
          children: [
            // Darkened viewfinder mask with rounded cutout
            CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: _LeafViewfinderPainter(
                frameRect: frameRect,
                cornerRadius: 24.0,
                cornerLength: cornerLength,
                strokeWidth: strokeWidth,
                bracketColor: AppColors.lime,
                maskColor: Colors.black.withValues(alpha: 0.45),
              ),
            ),

            // Guidance Hint Chip placed below the target frame
            Positioned(
              left: 20,
              right: 20,
              top: frameRect.bottom + AppSpacing.md,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCC1E293B),
                    borderRadius: AppRadius.buttonBorderRadius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco_rounded,
                        color: AppColors.lime,
                        size: 16,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          'Place one leaf in the frame, in good light',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter rendering the translucent dark mask with rounded cutout
/// and 4 lime corner brackets.
class _LeafViewfinderPainter extends CustomPainter {
  final Rect frameRect;
  final double cornerRadius;
  final double cornerLength;
  final double strokeWidth;
  final Color bracketColor;
  final Color maskColor;

  _LeafViewfinderPainter({
    required this.frameRect,
    required this.cornerRadius,
    required this.cornerLength,
    required this.strokeWidth,
    required this.bracketColor,
    required this.maskColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maskPaint = Paint()..color = maskColor;

    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutRRect = RRect.fromRectAndRadius(frameRect, Radius.circular(cornerRadius));
    final cutoutPath = Path()..addRRect(cutoutRRect);

    // Difference between screen and frame cutout
    final overlayPath = Path.combine(PathOperation.difference, outerPath, cutoutPath);
    canvas.drawPath(overlayPath, maskPaint);

    // Draw lime corner brackets
    final bracketPaint = Paint()
      ..color = bracketColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final l = frameRect.left;
    final t = frameRect.top;
    final r = frameRect.right;
    final b = frameRect.bottom;
    final cl = cornerLength;
    final cr = cornerRadius;

    // Top-Left corner
    final tlPath = Path()
      ..moveTo(l, t + cl)
      ..lineTo(l, t + cr)
      ..arcToPoint(Offset(l + cr, t), radius: Radius.circular(cr))
      ..lineTo(l + cl, t);
    canvas.drawPath(tlPath, bracketPaint);

    // Top-Right corner
    final trPath = Path()
      ..moveTo(r - cl, t)
      ..lineTo(r - cr, t)
      ..arcToPoint(Offset(r, t + cr), radius: Radius.circular(cr))
      ..lineTo(r, t + cl);
    canvas.drawPath(trPath, bracketPaint);

    // Bottom-Left corner
    final blPath = Path()
      ..moveTo(l, b - cl)
      ..lineTo(l, b - cr)
      ..arcToPoint(Offset(l + cr, b), radius: Radius.circular(cr))
      ..lineTo(l + cl, b);
    canvas.drawPath(blPath, bracketPaint);

    // Bottom-Right corner
    final brPath = Path()
      ..moveTo(r - cl, b)
      ..lineTo(r - cr, b)
      ..arcToPoint(Offset(r, b - cr), radius: Radius.circular(cr))
      ..lineTo(r, b - cl);
    canvas.drawPath(brPath, bracketPaint);
  }

  @override
  bool shouldRepaint(covariant _LeafViewfinderPainter oldDelegate) {
    return oldDelegate.frameRect != frameRect ||
        oldDelegate.bracketColor != bracketColor ||
        oldDelegate.maskColor != maskColor;
  }
}

/// Flash mode options supported by the camera HUD.
enum CameraFlashMode {
  off,
  auto,
  always,
  torch,
}

