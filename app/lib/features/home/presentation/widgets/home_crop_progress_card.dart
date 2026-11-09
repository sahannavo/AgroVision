import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../crop_plots/domain/crop_plot.dart';

class HomeCropProgressCard extends StatelessWidget {
  const HomeCropProgressCard({required this.plot, super.key});

  final CropPlot plot;

  @override
  Widget build(BuildContext context) {
    final progress = switch (plot.growthStage.toLowerCase()) {
      'seedling stage' || 'seedling' => 0.2,
      'vegetative stage' || 'vegetative' => 0.4,
      'flowering stage' || 'flowering' => 0.65,
      'fruiting stage' || 'fruiting' => 0.85,
      _ => 0.0,
    };
    final needsAttention = plot.cropType == 'Chilli';
    return SizedBox(
      width: 194,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: needsAttention
                      ? AppColors.warning.withValues(alpha: 0.12)
                      : AppColors.healthy.withValues(alpha: 0.12),
                  child: Icon(
                    needsAttention ? Icons.spa_outlined : Icons.eco_outlined,
                    size: 18,
                    color: needsAttention
                        ? AppColors.warning
                        : AppColors.healthy,
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: needsAttention
                          ? StatusChip.needsAttention(label: 'Needs ...')
                          : StatusChip.healthy(label: 'Healthy', showDot: true),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${plot.cropType} • ${_plotLabel(plot)}',
              style: AppTextStyles.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Stage: ${plot.growthStage.replaceAll(' Stage', '')} (Day ${plot.ageInDays})',
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text('Cycle progress', style: AppTextStyles.bodySmall),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.healthy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              borderRadius: AppRadius.borderFull,
              color: needsAttention ? AppColors.warning : AppColors.lime,
              backgroundColor: AppColors.background,
            ),
          ],
        ),
      ),
    );
  }

  String _plotLabel(CropPlot value) {
    if (value.cropType == 'Tomato') return 'Plot A';
    if (value.cropType == 'Chilli') return 'Plot B';
    return value.name;
  }
}
