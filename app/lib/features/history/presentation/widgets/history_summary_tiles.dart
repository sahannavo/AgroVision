import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Single statistic item displayed in [HistorySummaryTiles].
class SummaryTileData {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const SummaryTileData({
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
  });
}

/// A row of three responsive metric cards summarizing history analytics.
///
/// Example usage for Diagnoses tab:
/// ```dart
/// HistorySummaryTiles.diagnoses(
///   totalScans: 28,
///   healthyPercent: 75,
///   topIssue: 'Late Blight',
/// )
/// ```
class HistorySummaryTiles extends StatelessWidget {
  final List<SummaryTileData> tiles;

  const HistorySummaryTiles({
    super.key,
    required this.tiles,
  });

  /// Factory constructor for the 3 summary metrics of the Diagnoses tab.
  factory HistorySummaryTiles.diagnoses({
    Key? key,
    required int totalScans,
    required int healthyPercent,
    required String topIssue,
  }) {
    return HistorySummaryTiles(
      key: key,
      tiles: [
        SummaryTileData(
          label: 'Total Scans',
          value: '$totalScans',
          icon: Icons.qr_code_scanner_rounded,
          accentColor: AppColors.primaryGreen,
        ),
        SummaryTileData(
          label: 'Healthy Rate',
          value: '$healthyPercent%',
          icon: Icons.check_circle_outline_rounded,
          accentColor: AppColors.healthy,
        ),
        SummaryTileData(
          label: 'Top Issue',
          value: topIssue.isEmpty ? 'None' : topIssue,
          icon: Icons.warning_amber_rounded,
          accentColor: AppColors.warning,
        ),
      ],
    );
  }

  /// Factory constructor for the 3 summary metrics of the Decisions tab.
  factory HistorySummaryTiles.decisions({
    Key? key,
    required int totalDecisions,
    required String impact,
    required String topAction,
  }) {
    return HistorySummaryTiles(
      key: key,
      tiles: [
        SummaryTileData(
          label: 'Decisions',
          value: '$totalDecisions',
          icon: Icons.fact_check_outlined,
          accentColor: AppColors.primaryGreen,
        ),
        SummaryTileData(
          label: 'Impact',
          value: impact,
          icon: Icons.trending_up_rounded,
          accentColor: AppColors.healthy,
        ),
        SummaryTileData(
          label: 'Top Action',
          value: topAction,
          icon: Icons.handyman_outlined,
          accentColor: AppColors.waterBlue,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MetricCard(data: tiles[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final SummaryTileData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.accentColor ?? AppColors.primaryGreen;

    return Semantics(
      container: true,
      label: '${data.label}: ${data.value}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    data.icon,
                    size: 16.0,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
