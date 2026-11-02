import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';

/// Available crop choices supported by AgroVision on-device AI.
const List<String> kSupportedCrops = [
  'Tomato',
  'Potato',
  'Chilli',
  'Eggplant',
];

/// Bottom capture controls containing crop selection chips, gallery picker,
/// large shutter button, and tips button.
class CaptureControls extends StatelessWidget {
  final String selectedCrop;
  final ValueChanged<String> onCropSelected;
  final VoidCallback? onShutterPressed;
  final VoidCallback? onGalleryPressed;
  final VoidCallback? onTipsPressed;
  final bool isCapturing;

  const CaptureControls({
    super.key,
    required this.selectedCrop,
    required this.onCropSelected,
    this.onShutterPressed,
    this.onGalleryPressed,
    this.onTipsPressed,
    this.isCapturing = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crop Selector Chips
          _buildCropSelector(),

          const SizedBox(height: AppSpacing.md),

          // Bottom Controls: Gallery | Shutter | Tips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gallery button
                _buildCircularActionButton(
                  icon: Icons.photo_library_outlined,
                  semanticsLabel: 'Choose leaf photo from gallery',
                  onTap: isCapturing ? null : onGalleryPressed,
                ),

                // Large Shutter button
                _buildShutterButton(),

                // Tips button
                _buildCircularActionButton(
                  icon: Icons.lightbulb_outline_rounded,
                  semanticsLabel: 'View leaf capture tips',
                  onTap: isCapturing ? null : onTipsPressed,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildCropSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: kSupportedCrops.map((crop) {
          final isSelected = crop.toLowerCase() == selectedCrop.toLowerCase();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '$crop crop',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onCropSelected(crop),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0x99000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.lime
                            : Colors.white.withValues(alpha: 0.2),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      crop,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCircularActionButton({
    required IconData icon,
    required String semanticsLabel,
    required VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0x66000000),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShutterButton() {
    return Semantics(
      button: true,
      label: 'Take photo of leaf',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCapturing ? null : onShutterPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isCapturing ? AppColors.lime : Colors.white,
                shape: BoxShape.circle,
              ),
              child: isCapturing
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the capture guidance bottom modal sheet with 3 key tips.
Future<void> showCaptureTipsModalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.2),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Tips for Accurate Diagnosis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 3 Tips
            _buildTipItem(
              icon: Icons.filter_center_focus_rounded,
              title: '1. Frame One Leaf in Focus',
              description:
                  'Place a single leaf showing visible symptoms inside the corner brackets.',
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            _buildTipItem(
              icon: Icons.wb_sunny_outlined,
              title: '2. Good, Even Light',
              description:
                  'Capture in bright, natural daylight. Avoid deep shadows or strong flash glares.',
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            _buildTipItem(
              icon: Icons.stay_current_portrait_rounded,
              title: '3. Hold Steady (10–15 cm)',
              description:
                  'Keep your phone flat and steady 10 to 15 cm from the leaf surface to eliminate blur.',
            ),

            const SizedBox(height: AppSpacing.lg),

            // Dismiss Button
            PrimaryButton(
              label: 'Got it, let\'s scan',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTipItem({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

