import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../crop_plots/domain/crop_plot.dart';

/// Individual tile in the "My crop plots" list on [ProfileScreen].
class CropPlotTile extends StatelessWidget {
  const CropPlotTile({super.key, required this.plot, this.onEdit});

  final CropPlot plot;
  final ValueChanged<CropPlot>? onEdit;

  @override
  Widget build(BuildContext context) {
    final visual = _getCropVisuals(plot.cropType);
    final stageVisual = _getStageVisuals(plot.growthStage);
    final areaText = '${plot.area.toStringAsFixed(1)} ${plot.areaUnit}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: visual.backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(child: Icon(visual.icon, color: visual.iconColor, size: 22)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(text: '${plot.cropType} · ${plot.plotName}'),
                          if (plot.variety != null && plot.variety!.isNotEmpty)
                            TextSpan(
                              text: ' (${plot.variety})',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Planted: ${_formatDate(plot.plantedDate)}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Edit ${plot.plotName}',
                child: InkWell(
                  onTap: () => onEdit?.call(plot),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    child: Container(
                      alignment: Alignment.topRight,
                      child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: stageVisual.backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: stageVisual.textColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      plot.growthStage,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: stageVisual.textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (plot.bed != null && plot.bed!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    plot.bed!,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.outline.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                ),
                child: Text(
                  areaText,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  _CropVisualConfig _getCropVisuals(String cropType) {
    final lower = cropType.toLowerCase();
    if (lower.contains('tomato')) {
      return const _CropVisualConfig(icon: Icons.lens_outlined, iconColor: Color(0xFFE53935), backgroundColor: Color(0xFFFFEBEE));
    } else if (lower.contains('chilli') || lower.contains('chili')) {
      return const _CropVisualConfig(icon: Icons.spa_outlined, iconColor: Color(0xFF2E7D32), backgroundColor: Color(0xFFE8F5E9));
    } else if (lower.contains('brinjal') || lower.contains('eggplant')) {
      return const _CropVisualConfig(icon: Icons.egg_outlined, iconColor: Color(0xFF8E24AA), backgroundColor: Color(0xFFF3E5F5));
    }
    return const _CropVisualConfig(icon: Icons.grass_outlined, iconColor: Color(0xFFF57C00), backgroundColor: Color(0xFFFFF3E0));
  }

  _StageVisualConfig _getStageVisuals(String stage) {
    final lower = stage.toLowerCase();
    if (lower.contains('flowering') || lower.contains('vegetative')) {
      return const _StageVisualConfig(textColor: Color(0xFF2E7D32), backgroundColor: Color(0xFFE8F5E9));
    } else if (lower.contains('fruiting')) {
      return const _StageVisualConfig(textColor: Color(0xFF8E24AA), backgroundColor: Color(0xFFF3E5F5));
    } else if (lower.contains('seedling') || lower.contains('nursery')) {
      return const _StageVisualConfig(textColor: Color(0xFF00796B), backgroundColor: Color(0xFFE0F2F1));
    }
    return const _StageVisualConfig(textColor: Color(0xFF455A64), backgroundColor: Color(0xFFECEFF1));
  }
}

class _CropVisualConfig {
  const _CropVisualConfig({required this.icon, required this.iconColor, required this.backgroundColor});
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
}

class _StageVisualConfig {
  const _StageVisualConfig({required this.textColor, required this.backgroundColor});
  final Color textColor;
  final Color backgroundColor;
}
