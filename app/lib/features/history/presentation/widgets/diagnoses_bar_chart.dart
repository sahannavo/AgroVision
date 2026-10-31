import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Bar chart presenting weekly scan volume for the last 8 weeks with the latest bar highlighted.
///
/// Example:
/// ```dart
/// DiagnosesBarChart(
///   weeklyScans: {'W1': 2, 'W2': 4, 'W3': 3, 'W4': 6, 'W5': 5, 'W6': 8, 'W7': 7, 'W8': 10},
/// )
/// ```
class DiagnosesBarChart extends StatelessWidget {
  /// Map of week label to scan count (e.g., {'W1': 3, 'W2': 5, ...}).
  final Map<String, int> weeklyScans;

  const DiagnosesBarChart({
    super.key,
    required this.weeklyScans,
  });

  @override
  Widget build(BuildContext context) {
    final entries = weeklyScans.entries.toList();
    final maxVal = entries.isEmpty
        ? 5
        : entries.map((e) => e.value).fold<int>(0, max);
    final maxY = maxVal == 0 ? 5.0 : (maxVal * 1.25).ceilToDouble();

    final latestScan = entries.isNotEmpty ? entries.last.value : 0;
    final totalWeekly =
        entries.fold<int>(0, (sum, item) => sum + item.value);

    return Semantics(
      container: true,
      label:
          'Diagnoses per week bar chart for the last 8 weeks. Total weekly scans: $totalWeekly. Latest week has $latestScan scans.',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnoses per week',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Last 8 weeks trend',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Latest Week',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 170.0,
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'No weekly scan data available',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        maxY: maxY,
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final label = entries[groupIndex].key;
                              final val = rod.toY.toInt();
                              return BarTooltipItem(
                                '$label: $val scans',
                                AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 26,
                              interval: (maxY / 3).clamp(1.0, 50.0).toDouble(),
                              getTitlesWidget: (value, meta) {
                                if (value == 0 || value == meta.max) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  value.toInt().toString(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= entries.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    entries[index].key,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: index == entries.length - 1
                                          ? AppColors.primaryGreen
                                          : AppColors.textSecondary,
                                      fontSize: 10,
                                      fontWeight: index == entries.length - 1
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: (maxY / 3).clamp(1.0, 50.0).toDouble(),
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: AppColors.divider.withOpacity(0.5),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: entries.asMap().entries.map((item) {
                          final index = item.key;
                          final entry = item.value;
                          final isLatest = index == entries.length - 1;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: isLatest
                                    ? AppColors.primaryGreen
                                    : AppColors.primaryGreen.withOpacity(0.35),
                                width: 14.0,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppRadius.xs),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
