import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/outbreak_alert.dart';
import 'preventive_steps_panel.dart';

/// A single alert card in the list view.
///
/// Shows the severity stripe, disease/crop, risk chip, metadata row,
/// description, unread dot, and expandable preventive steps.
class AlertCard extends StatefulWidget {
  const AlertCard({
    super.key,
    required this.alert,
    required this.initiallyExpanded,
    required this.onTap,
  });

  final OutbreakAlert alert;
  final bool initiallyExpanded;
  final VoidCallback onTap;

  @override
  State<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  OutbreakAlert get _alert => widget.alert;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${_alert.diseaseName} alert, ${_alert.severity.label}',
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.lgAll,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SeverityStripe(severity: _alert.severity),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AlertHeader(alert: _alert),
        const SizedBox(height: AppSpacing.sm),
        _AlertMeta(alert: _alert),
        const SizedBox(height: AppSpacing.sm),
        Text(_alert.description, style: AppTextStyles.bodySmall),
        const SizedBox(height: AppSpacing.md),
        _buildStepsToggle(),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.md),
          PreventiveStepsPanel(steps: _alert.preventiveSteps),
        ],
      ],
    );
  }

  Widget _buildStepsToggle() {
    final label = _expanded
        ? 'Preventive Steps (Action Required)'
        : _alert.vectorInfo != null
            ? 'Vector control steps (${_alert.preventiveSteps.length} actions)'
            : _alert.severity == AlertSeverity.high
                ? 'Preventive Steps (Action Required)'
                : 'Preventive steps (${_alert.preventiveSteps.length} actions available)';

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            const Icon(Icons.verified_outlined,
                size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
            Icon(
              _expanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Severity stripe ──────────────────────────────────────────────

class _SeverityStripe extends StatelessWidget {
  const _SeverityStripe({required this.severity});
  final AlertSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: severity.color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}

// ── Header row ───────────────────────────────────────────────────

class _AlertHeader extends StatelessWidget {
  const _AlertHeader({required this.alert});
  final OutbreakAlert alert;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: alert.isRead
                  ? alert.severity.color
                  : AppColors.unreadDot,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: alert.diseaseName,
                style: AppTextStyles.titleLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: ' · ${alert.cropName}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ]),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: alert.severity.chipBg,
            borderRadius: AppRadius.smAll,
          ),
          child: Text(
            alert.severity.label,
            style:
                AppTextStyles.chip.copyWith(color: alert.severity.color),
          ),
        ),
      ],
    );
  }
}

// ── Metadata row ─────────────────────────────────────────────────

class _AlertMeta extends StatelessWidget {
  const _AlertMeta({required this.alert});
  final OutbreakAlert alert;

  String get _timeAgo {
    final d = DateTime.now().difference(alert.reportedAt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final parts = <String>['~${alert.distanceKm.toInt()} km'];
    if (alert.locationName != null) parts.add(alert.locationName!);
    if (alert.vectorInfo != null) {
      parts.add('Vector: ${alert.vectorInfo}');
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined,
                size: 14, color: alert.severity.color),
            const SizedBox(width: 2),
            Text(parts.join(' · '),
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const Text('·', style: AppTextStyles.labelSmall),
        if (alert.reportCount > 0)
          _ReportChip(
            text:
                '${alert.reportCount} ${alert.reportCount == 1 ? 'report' : 'farm reports'} in ${alert.reportWindowDays}d',
          ),
        if (alert.reportCount == 0)
          Text('${alert.reportCount} reports',
              style: AppTextStyles.labelSmall),
        const Text('·', style: AppTextStyles.labelSmall),
        Text(_timeAgo, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(text,
          style: AppTextStyles.chip.copyWith(color: AppColors.primary)),
    );
  }
}

// ── Extension for severity helpers ───────────────────────────────

extension AlertSeverityX on AlertSeverity {
  Color get color {
    switch (this) {
      case AlertSeverity.high:
        return AppColors.highRisk;
      case AlertSeverity.moderate:
        return AppColors.moderateRisk;
      case AlertSeverity.peripheral:
        return AppColors.peripheral;
    }
  }

  Color get chipBg {
    switch (this) {
      case AlertSeverity.high:
        return AppColors.highRiskBg;
      case AlertSeverity.moderate:
        return AppColors.moderateRiskBg;
      case AlertSeverity.peripheral:
        return AppColors.peripheralBg;
    }
  }

  String get label {
    switch (this) {
      case AlertSeverity.high:
        return 'High Risk';
      case AlertSeverity.moderate:
        return 'Moderate Risk';
      case AlertSeverity.peripheral:
        return 'Peripheral';
    }
  }
}
