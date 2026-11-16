import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Donut chart visualizing disease distribution with a clear color-coded legend.
///
/// Example:
/// ```dart
/// DiseaseDonutChart(
///   diseaseBreakdown: {
///     'Late Blight': 12,
///     'Early Blight': 8,
///     'Septoria': 5,
///     'Healthy': 15,
///   },
/// )
/// ```
class DiseaseDonutChart extends StatelessWidget {
  /// Map of disease name to occurrences count.
  final Map<String, int> diseaseBreakdown;

  const DiseaseDonutChart({
    super.key,
    required this.diseaseBreakdown,
  });

  static const List<Color> _palette = [
    AppColors.danger,
    AppColors.warning,
    AppColors.waterBlue,
    AppColors.lime,
    AppColors.primaryGreen,
    Color(0xFF8E24AA), // Purple accent
  ];

  @override
  Widget build(BuildContext context) {
    final entries = diseaseBreakdown.entries.toList();
    final totalCount =
        entries.fold<int>(0, (sum, entry) => sum + entry.value);

    final summaryText = entries
        .map((e) =>
            '${e.key}: ${e.value} (${totalCount > 0 ? ((e.value / totalCount) * 100).toStringAsFixed(0) : 0}%)')
        .join(', ');

    return Semantics(
      container: true,
      label: 'Disease breakdown donut chart. Total: $totalCount scans. $summaryText',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disease breakdown',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Proportion of detected plant issues',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (entries.isEmpty || totalCount == 0)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    'No disease breakdown data available',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Donut PieChart
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: entries.asMap().entries.map((item) {
                              final index = item.key;
                              final entry = item.value;
                              final color = _palette[index % _palette.length];
                              final isLarge = entry.value / totalCount > 0.3;

                              return PieChartSectionData(
                                color: color,
                                value: entry.value.toDouble(),
                                radius: isLarge ? 24.0 : 20.0,
                                showTitle: false,
                              );
                            }).toList(),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$totalCount',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'total',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: entries.asMap().entries.map((item) {
                        final index = item.key;
                        final entry = item.value;
                        final color = _palette[index % _palette.length];
                        final pct = totalCount > 0
                            ? ((entry.value / totalCount) * 100).toStringAsFixed(0)
                            : '0';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxs + 1,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '${entry.value} ($pct%)',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
