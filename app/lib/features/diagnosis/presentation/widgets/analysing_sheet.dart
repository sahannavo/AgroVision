import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/secondary_button.dart';

/// Full-screen analysing view featuring the captured photo with an animated
/// moving lime laser scan line, and an informative bottom modal sheet with
/// progress indicator and cancel button.
class AnalysingView extends StatefulWidget {
  /// Path to the captured or picked photo file on disk.
  final String imagePath;

  /// Selected crop type (e.g., 'Tomato', 'Potato').
  final String cropType;

  /// Callback when the user cancels the ongoing analysis.
  final VoidCallback onCancel;

  const AnalysingView({
    super.key,
    required this.imagePath,
    required this.cropType,
    required this.onCancel,
  });

  @override
  State<AnalysingView> createState() => _AnalysingViewState();
}

class _AnalysingViewState extends State<AnalysingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Widget _buildPhoto() {
    final file = File(widget.imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderPhoto(),
      );
    }
    return _buildPlaceholderPhoto();
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.eco_rounded,
              size: 64,
              color: AppColors.lime,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${widget.cropType} Leaf',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Upper Photo Preview Area
          Positioned.fill(
            bottom: 240, // Reserve height for bottom sheet
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildPhoto(),

                // Dark vignette gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),

                // Animated moving lime laser scan line
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment(0.0, (_scanAnimation.value * 2.0) - 1.0),
                      child: Container(
                        height: 3.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lime.withValues(alpha: 0.7),
                              blurRadius: 14.0,
                              spreadRadius: 3.0,
                            ),
                            BoxShadow(
                              color: AppColors.lime.withValues(alpha: 0.4),
                              blurRadius: 28.0,
                              spreadRadius: 6.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Top cancel shortcut button
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                  left: AppSpacing.md,
                  child: Semantics(
                    button: true,
                    label: 'Cancel analysis',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onCancel,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0x66000000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Analysis Status Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Header row with spinning indicator and title
                    Row(
                      children: [
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.8,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm + 4),
                        Text(
                          'Analysing ${widget.cropType} leaf…',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Progress bar
                    ClipRRect(
                      borderRadius: AppRadius.borderXs,
                      child: const LinearProgressIndicator(
                        minHeight: 5,
                        backgroundColor: Color(0xFFE8F5E9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.lime,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Explanation line
                    const Text(
                      'Running on-device neural network to detect leaf diseases, pests, and nutrient deficiencies. No internet connection required.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Cancel Button
                    SecondaryButton(
                      label: 'Cancel',
                      onPressed: widget.onCancel,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

