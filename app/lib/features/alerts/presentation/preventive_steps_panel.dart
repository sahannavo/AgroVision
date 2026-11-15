import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Expandable panel showing numbered preventive steps for an alert.
class PreventiveStepsPanel extends StatelessWidget {
  const PreventiveStepsPanel({
    super.key,
    required this.steps,
    this.showAddToSchedule = true,
  });

  final List<String> steps;
  final bool showAddToSchedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...steps.asMap().entries.map(
          (entry) => _StepItem(step: entry.value, number: entry.key + 1),
        ),
        if (showAddToSchedule) ...[
          const SizedBox(height: AppSpacing.md),
          _AddToScheduleButton(),
        ],
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.step, required this.number});

  final String step;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: AppTextStyles.chip.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Follow this step to reduce outbreak risk.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToScheduleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showScheduleConfirmation(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add to Spray Schedule'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
    );
  }

  void _showScheduleConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Spray schedule is not available yet. Keep these steps for your next application.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
