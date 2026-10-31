import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Supported filter seasons in AgroVision.
enum HistorySeason {
  all('All Seasons'),
  yala('Yala'),
  maha('Maha');

  final String displayName;
  const HistorySeason(this.displayName);
}

/// Supported crop filters for history records.
enum HistoryCrop {
  all('All Crops'),
  tomato('Tomato'),
  potato('Potato'),
  chilli('Chilli'),
  eggplant('Eggplant');

  final String displayName;
  const HistoryCrop(this.displayName);
}

/// Sort options for history entries.
enum HistorySort {
  newest('Newest'),
  confidence('Highest Confidence'),
  severity('Severity');

  final String displayName;
  const HistorySort(this.displayName);
}

/// Filter bar providing interactive chips to filter history and analytics in memory.
///
/// Example:
/// ```dart
/// HistoryFilterBar(
///   selectedSeason: selectedSeason,
///   selectedCrop: selectedCrop,
///   selectedSort: selectedSort,
///   onSeasonChanged: (s) => setState(() => selectedSeason = s),
///   onCropChanged: (c) => setState(() => selectedCrop = c),
///   onSortChanged: (sort) => setState(() => selectedSort = sort),
/// )
/// ```
class HistoryFilterBar extends StatelessWidget {
  final HistorySeason selectedSeason;
  final HistoryCrop selectedCrop;
  final HistorySort selectedSort;
  final ValueChanged<HistorySeason> onSeasonChanged;
  final ValueChanged<HistoryCrop> onCropChanged;
  final ValueChanged<HistorySort> onSortChanged;

  const HistoryFilterBar({
    super.key,
    required this.selectedSeason,
    required this.selectedCrop,
    required this.selectedSort,
    required this.onSeasonChanged,
    required this.onCropChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Season Menu / Chip
          _FilterDropdownChip<HistorySeason>(
            label: selectedSeason.displayName,
            icon: Icons.calendar_month_outlined,
            items: HistorySeason.values,
            selectedItem: selectedSeason,
            itemLabel: (s) => s.displayName,
            onSelected: onSeasonChanged,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Crop Menu / Chip
          _FilterDropdownChip<HistoryCrop>(
            label: selectedCrop.displayName,
            icon: Icons.eco_outlined,
            items: HistoryCrop.values,
            selectedItem: selectedCrop,
            itemLabel: (c) => c.displayName,
            onSelected: onCropChanged,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Sort Menu / Chip
          _FilterDropdownChip<HistorySort>(
            label: selectedSort.displayName,
            icon: Icons.sort_rounded,
            items: HistorySort.values,
            selectedItem: selectedSort,
            itemLabel: (s) => s.displayName,
            onSelected: onSortChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterDropdownChip<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<T> items;
  final T selectedItem;
  final String Function(T) itemLabel;
  final ValueChanged<T> onSelected;

  const _FilterDropdownChip({
    required this.label,
    required this.icon,
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedItem != items.first;

    return Semantics(
      button: true,
      label: 'Filter: $label',
      child: PopupMenuButton<T>(
        initialValue: selectedItem,
        tooltip: 'Change $label',
        onSelected: onSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        color: AppColors.surface,
        elevation: 3,
        itemBuilder: (context) {
          return items.map((item) {
            final isCurrent = item == selectedItem;
            return PopupMenuItem<T>(
              value: item,
              child: Row(
                children: [
                  Text(
                    itemLabel(item),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isCurrent
                          ? AppColors.primaryGreen
                          : AppColors.textPrimary,
                      fontWeight:
                          isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  if (isCurrent)
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen.withOpacity(0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.divider,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15.0,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18.0,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
