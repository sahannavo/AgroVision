import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../validators.dart';

/// Four-segment password strength indicator bar.
///
/// Score 0 = empty, 1 = weak (red), 2 = fair (orange), 3 = good (lime),
/// 4 = strong (primaryGreen).
class StrengthMeter extends StatelessWidget {
  const StrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final score = AuthValidators.passwordStrength(password);

    final (label, color) = switch (score) {
      0 => ('', AppColors.divider),
      1 => ('Weak', AppColors.danger),
      2 => ('Fair', AppColors.warning),
      3 => ('Good', AppColors.lime),
      _ => ('Strong', AppColors.primaryGreen),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < score;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? AppSpacing.xs : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: filled ? color : AppColors.divider,
                  borderRadius: AppRadius.borderFull,
                ),
              ),
            );
          }),
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ],
      ],
    );
  }
}

