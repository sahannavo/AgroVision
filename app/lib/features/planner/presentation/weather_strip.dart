import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import 'planner_ui_models.dart';

/// 7-day weather forecast strip for irrigation planning.
///
/// Matches the design in `Planner.png`:
/// - Header: "7-DAY IRRIGATION FORECAST" with link "Sri Lanka Met Dept".
/// - 7 columns: Day of week, weather icon, temperature in °C, rain probability percentage.
/// - Active selected day is highlighted in a dark green pill container.
class WeatherStrip extends StatelessWidget {
  final List<DailyForecastItem> forecast;
  final int selectedIndex;
  final ValueChanged<int>? onDaySelected;

  const WeatherStrip({
    super.key,
    required this.forecast,
    this.selectedIndex = 2, // defaults to Wed as in mock
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '7-DAY IRRIGATION FORECAST',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Sri Lanka Met Dept',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.waterBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 7-day strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(forecast.length, (index) {
              final item = forecast[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDaySelected?.call(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF237327) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.dayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildWeatherIcon(item.iconCode, isSelected),
                        const SizedBox(height: 6),
                        Text(
                          '${item.tempC}°',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.rainPercentage}%',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFFC6E070)
                                : (item.rainPercentage >= 50
                                    ? AppColors.waterBlue
                                    : AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(String code, bool isSelected) {
    IconData icon;
    Color color;

    switch (code) {
      case 'rain':
        icon = Icons.grain;
        color = isSelected ? Colors.white : AppColors.waterBlue;
        break;
      case 'cloudy':
        icon = Icons.cloud_outlined;
        color = isSelected ? Colors.white : AppColors.textSecondary;
        break;
      case 'partly_cloudy':
        icon = Icons.wb_cloudy_outlined;
        color = isSelected ? Colors.white : Colors.orange;
        break;
      case 'sunny':
      default:
        icon = Icons.wb_sunny_outlined;
        color = isSelected ? Colors.white : Colors.orange;
        break;
    }

    return Icon(icon, size: 20, color: color);
  }
}
