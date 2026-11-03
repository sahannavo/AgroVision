import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Modal bottom sheet content widget for adding or editing a crop plot.
class AddCropPlotSheet extends StatelessWidget {
  const AddCropPlotSheet({
    super.key,
    this.plot,
  });

  /// The crop plot to edit, or null when adding a new plot.
  final dynamic plot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plot == null ? 'Add Crop Plot' : 'Edit Crop Plot',
                style: AppTextStyles.headingMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'AddCropPlotSheet stub',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.textOnPrimary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Displays the bottom sheet for adding or editing a crop plot.
Future<T?> showAddCropPlotSheet<T>(
  BuildContext context, {
  dynamic plot,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => AddCropPlotSheet(plot: plot),
  );
}
