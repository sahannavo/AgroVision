import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/outbreak_alert.dart';

/// Bottom sheet shown when a zone is tapped on the map.
///
/// Displays disease name, risk chip, radius, report count, plot advice
/// and a "View Preventive Steps" button.
class ZoneBottomSheet extends StatelessWidget {
  const ZoneBottomSheet({
    super.key,
    required this.alert,
    required this.onViewPreventiveSteps,
  });

  final OutbreakAlert alert;
  final VoidCallback onViewPreventiveSteps;

  Color get _dotColor {
    switch (alert.severity) {
      case AlertSeverity.high:
        return AppColors.highRisk;
      case AlertSeverity.moderate:
        return AppColors.moderateRisk;
      case AlertSeverity.peripheral:
        return AppColors.peripheral;
    }
  }

  Color get _chipBgColor {
    switch (alert.severity) {
      case AlertSeverity.high:
        return AppColors.highRiskBg;
      case AlertSeverity.moderate:
        return AppColors.moderateRiskBg;
      case AlertSeverity.peripheral:
        return AppColors.peripheralBg;
    }
  }

  Color get _chipTextColor {
    switch (alert.severity) {
      case AlertSeverity.high:
        return AppColors.highRisk;
      case AlertSeverity.moderate:
        return AppColors.moderateRisk;
      case AlertSeverity.peripheral:
        return AppColors.textSecondary;
    }
  }

  String get _severityLabel {
    switch (alert.severity) {
      case AlertSeverity.high:
        return 'HIGH RISK';
      case AlertSeverity.moderate:
        return 'MODERATE RISK';
      case AlertSeverity.peripheral:
        return 'PERIPHERAL';
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(alert.reportedAt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),
            // Disease header row
            _buildHeader(),
            const SizedBox(height: AppSpacing.sm),
            // Metadata row
            _buildMetaRow(),
            const SizedBox(height: AppSpacing.md),
            // Plot advice
            if (alert.plotAdvice != null) ...[
              _buildAdviceBox(),
              const SizedBox(height: AppSpacing.lg),
            ],
            // CTA button
            _buildCtaButton(),
            const SizedBox(height: AppSpacing.md),
            // Helper text
            Center(
              child: Text(
                'Tap zones on map to inspect other alerts',
                style: AppTextStyles.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: alert.diseaseName,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' · ${alert.cropName}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _chipBgColor,
            borderRadius: AppRadius.smAll,
          ),
          child: Text(
            _severityLabel,
            style: AppTextStyles.chip.copyWith(
              color: _chipTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '~${alert.radiusKm.toInt()} km radius',
          style: AppTextStyles.bodySmall.copyWith(
            color: _dotColor,
          ),
        ),
        const Text('·', style: AppTextStyles.bodySmall),
        if (alert.reportCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              '${alert.reportCount} farm reports in ${alert.reportWindowDays}d',
              style: AppTextStyles.chip.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        const Text('·', style: AppTextStyles.bodySmall),
        Text(
          _timeAgo,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildAdviceBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              alert.plotAdvice!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onViewPreventiveSteps,
        icon: const Icon(Icons.verified_outlined, size: 20),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('View Preventive Steps'),
            SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right, size: 20),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

