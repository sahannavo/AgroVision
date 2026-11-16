import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/diagnosis.dart';

/// Tile displaying candidate matches with progress bars for low-confidence scans.
class CandidateMatchTile extends StatelessWidget {
  final TopMatch match;

  const CandidateMatchTile({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (match.confidence * 100).round();
    final isTop = match.confidence >= 0.40;
    final progressColor = isTop ? AppColors.warning : AppColors.primaryGreen;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.mdSm),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: const Color(0xFFE5EDE5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: match.diseaseClass.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: ' (${match.diseaseClass.scientificName})',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$percentage%',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadius.borderFull,
            child: LinearProgressIndicator(
              value: match.confidence.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFE0E5E0),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
