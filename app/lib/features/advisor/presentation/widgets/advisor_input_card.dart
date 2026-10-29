import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/crop_chip_selector.dart';

/// Top card on the [AdvisorScreen] collecting farming parameters:
/// - Location detection ("Detect" action).
/// - Soil type selector (Clay, Loam, Sandy, Silt).
/// - Cultivation season segmented switch (Maha, Yala).
/// - Cached weather status banner.
/// - "Get recommendations" submission button.
class AdvisorInputCard extends StatelessWidget {
  /// Current selected or detected location.
  final String location;

  /// Current selected soil type.
  final String selectedSoil;

  /// Current selected cultivation season.
  final String selectedSeason;

  /// Whether the cached weather banner should be displayed.
  final bool isWeatherCached;

  /// Relative or formatted time string for cached weather data.
  final String weatherCachedDurationText;

  /// Whether recommendations are currently loading.
  final bool isLoading;

  /// Callback when user taps "Detect" location.
  final VoidCallback onDetectLocation;

  /// Callback when user selects a soil type chip.
  final ValueChanged<String> onSoilChanged;

  /// Callback when user selects a cultivation season segment.
  final ValueChanged<String> onSeasonChanged;

  /// Callback when user taps "Get recommendations".
  final VoidCallback onGetRecommendations;

  const AdvisorInputCard({
    super.key,
    required this.location,
    required this.selectedSoil,
    required this.selectedSeason,
    this.isWeatherCached = true,
    this.weatherCachedDurationText = '3 hrs ago',
    this.isLoading = false,
    required this.onDetectLocation,
    required this.onSoilChanged,
    required this.onSeasonChanged,
    required this.onGetRecommendations,
  });

  static const List<String> soilOptions = ['Clay', 'Loam', 'Sandy', 'Silt'];
  static const String mahaSeason = 'Maha (Oct - Feb)';
  static const String yalaSeason = 'Yala (May - Aug)';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Field Location Row
          Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryGreen,
                    size: 20.0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Field location',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      location,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Detect current location',
                child: TextButton.icon(
                  onPressed: onDetectLocation,
                  icon: const Icon(
                    Icons.my_location_rounded,
                    size: 16.0,
                    color: AppColors.primaryGreen,
                  ),
                  label: Text(
                    'Detect',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.mdSm),
          const Divider(color: AppColors.divider, height: 1.0),
          const SizedBox(height: AppSpacing.mdSm),

          // 2. Soil Type Section
          Text(
            'Soil type',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OptionChips<String>(
            options: soilOptions,
            selectedOption: selectedSoil,
            onOptionSelected: (soil) {
              if (soil != null) {
                onSoilChanged(soil);
              }
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // 3. Cultivation Season Section
          Text(
            'Cultivation season',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SeasonSegmentedControl(
            selectedSeason: selectedSeason,
            onSeasonChanged: onSeasonChanged,
          ),

          const SizedBox(height: AppSpacing.mdSm),

          // 4. Cached Weather Chip
          if (isWeatherCached) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.mdSm,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 18.0,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Using weather saved $weatherCachedDurationText',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.divider.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Offline',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.mdSm),
          ],

          // 5. Submit Button: "Get recommendations"
          SizedBox(
            width: double.infinity,
            height: 50.0,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onGetRecommendations,
              icon: isLoading
                  ? const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.tips_and_updates_outlined,
                      size: 20.0,
                      color: AppColors.textOnPrimary,
                    ),
              label: Text(
                isLoading ? 'Analyzing Crops...' : 'Get recommendations',
                style: AppTextStyles.button.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom segmented switch for Cultivation Season matching the Figma visual design.
class _SeasonSegmentedControl extends StatelessWidget {
  final String selectedSeason;
  final ValueChanged<String> onSeasonChanged;

  const _SeasonSegmentedControl({
    required this.selectedSeason,
    required this.onSeasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    const maha = AdvisorInputCard.mahaSeason;
    const yala = AdvisorInputCard.yalaSeason;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxs + 2),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              title: maha,
              isSelected: selectedSeason == maha || selectedSeason.toLowerCase().contains('maha'),
              onTap: () => onSeasonChanged(maha),
            ),
          ),
          Expanded(
            child: _buildSegment(
              title: yala,
              isSelected: selectedSeason == yala || selectedSeason.toLowerCase().contains('yala'),
              onTap: () => onSeasonChanged(yala),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm + 2),
          border: isSelected
              ? Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2), width: 1.0)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4.0,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
