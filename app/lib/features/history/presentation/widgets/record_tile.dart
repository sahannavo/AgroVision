import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../diagnosis/domain/diagnosis.dart';

/// Single diagnosis record tile displayed in the Recent Records list.
///
/// Tapping the tile navigates to `/diagnose/result` with the [Diagnosis] entity.
///
/// Example:
/// ```dart
/// RecordTile(diagnosis: diagnosis)
/// ```
class RecordTile extends StatelessWidget {
  final Diagnosis diagnosis;
  final VoidCallback? onTap;

  const RecordTile({
    super.key,
    required this.diagnosis,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = diagnosis.predictedClass.isHealthy;
    final statusColor = isHealthy ? AppColors.healthy : AppColors.danger;
    final confidencePct = (diagnosis.confidence * 100).toInt();
    final dateStr = DateFormat('dd MMM yyyy').format(diagnosis.diagnosedAt);

    final isSynced = diagnosis.syncStatus == SyncStatus.synced;
    final syncBgColor = isSynced
        ? AppColors.healthy.withOpacity(0.08)
        : AppColors.warning.withOpacity(0.12);
    final syncTextColor = isSynced ? AppColors.healthy : AppColors.warning;

    return Semantics(
      button: true,
      label:
          'Diagnosis: ${diagnosis.predictedClass.displayName} on ${diagnosis.cropType}. Confidence: $confidencePct%. Date: $dateStr. Sync: ${diagnosis.syncStatus.displayName}',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap ??
              () {
                context.push('/diagnose/result', extra: diagnosis);
              },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider, width: 1.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Crop / Diagnosis Icon Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    isHealthy
                        ? Icons.eco_rounded
                        : Icons.coronavirus_outlined,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        diagnosis.predictedClass.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${diagnosis.cropType} · $dateStr',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Confidence & Sync Status Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Confidence Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '$confidencePct%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Sync Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: syncBgColor,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSynced
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_upload_outlined,
                            size: 11,
                            color: syncTextColor,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            diagnosis.syncStatus.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: syncTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
