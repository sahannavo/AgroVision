import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../weather/domain/weather_forecast.dart';

class HomeWeatherCard extends StatelessWidget {
  const HomeWeatherCard({
    required this.forecast,
    required this.isOffline,
    super.key,
  });

  final WeatherForecast forecast;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final days = forecast.daily.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.waterBlue, AppColors.info],
        ),
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${forecast.currentTemperature.round()}°C',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Kurunegala Field',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.wb_sunny_outlined,
                size: 34,
                color: AppColors.warning,
              ),
            ],
          ),
          Text(
            'Partly cloudy',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
          if (isOffline) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.18),
                borderRadius: AppRadius.borderFull,
              ),
              child: Text(
                '☁ Saved 2h ago',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
          Divider(
            color: AppColors.white.withValues(alpha: 0.4),
            height: AppSpacing.lg,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '♢ Humidity ${forecast.humidity}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '♧ Rain chance ${forecast.rainChance}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var index = 0; index < days.length; index++) ...[
                Expanded(
                  child: _ForecastDay(day: days[index], index: index),
                ),
                if (index != days.length - 1)
                  const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.white.withValues(alpha: 0.4)),
            ),
            child: Text(
              '💧 No rain expected. Irrigate tomatoes this evening.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastDay extends StatelessWidget {
  const _ForecastDay({required this.day, required this.index});

  final DailyForecast day;
  final int index;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    decoration: BoxDecoration(
      color: AppColors.white.withValues(alpha: 0.14),
      borderRadius: AppRadius.borderSm,
    ),
    child: Column(
      children: [
        Text(
          ['TODAY', 'TOMORROW', 'WED'][index],
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.xs),
        Icon(
          index == 1 ? Icons.cloud_outlined : Icons.wb_sunny_outlined,
          size: 18,
          color: AppColors.warning,
        ),
        Text(
          '${day.high.round()}° / ${day.low.round()}°',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
        ),
      ],
    ),
  );
}
