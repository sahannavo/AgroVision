import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../diagnosis/domain/diagnosis.dart';
import '../../domain/decision_log_entry.dart';

/// Vertical timeline displaying the chronological farm decision log.
///
/// Example:
/// ```dart
/// DecisionTimeline(
///   entries: decisionList,
/// )
/// ```
class DecisionTimeline extends StatelessWidget {
  final List<DecisionLogEntry> entries;

  const DecisionTimeline({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_note_outlined,
                size: 48,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No decisions logged yet',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Actions you take on advice or diagnoses will appear here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Decision Log',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isLast = index == entries.length - 1;
              return _TimelineItem(
                entry: entry,
                isLast: isLast,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final DecisionLogEntry entry;
  final bool isLast;

  const _TimelineItem({
    required this.entry,
    required this.isLast,
  });

  IconData _iconForAction(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('spray') || lower.contains('fungicide') || lower.contains('treatment')) {
      return Icons.sanitizer_outlined;
    }
    if (lower.contains('water') || lower.contains('irrigat')) {
      return Icons.water_drop_outlined;
    }
    if (lower.contains('crop') || lower.contains('plant') || lower.contains('seed')) {
      return Icons.spa_outlined;
    }
    return Icons.fact_check_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(entry.date);
    final isSynced = entry.syncStatus == SyncStatus.synced;
    final actionIcon = _iconForAction(entry.title);

    return Semantics(
      container: true,
      label:
          'Decision: ${entry.title}. Result: ${entry.resultLabel}. Date: $dateStr. Detail: ${entry.detail}',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline line + Node Icon
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    actionIcon,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.divider,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),

            // Content Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.divider, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Date & Sync Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSynced
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_upload_outlined,
                              size: 12,
                              color: isSynced
                                  ? AppColors.healthy
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              entry.syncStatus.displayName,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isSynced
                                    ? AppColors.healthy
                                    : AppColors.warning,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Title
                    Text(
                      entry.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Detail
                    Text(
                      entry.detail,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Result Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs + 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.healthy.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.healthy.withOpacity(0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: AppColors.healthy,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            entry.resultLabel,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.healthy,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
