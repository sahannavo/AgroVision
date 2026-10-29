import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/alerts_providers.dart';
import '../domain/outbreak_alert.dart';
import 'widgets/alert_card.dart';
import 'widgets/alerts_bottom_nav_bar.dart';
import 'widgets/list_map_toggle.dart';
import 'widgets/outbreak_map_view.dart';
import 'widgets/season_header_card.dart';

/// Main alerts screen with List / Map toggle.
///
/// Tab screen with the bottom bar, Alerts active.
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  bool _isMapView = false;

  /// Simulated offline state – in production read from connectivity.
  final bool _isOffline = true;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            if (_isOffline) _buildOfflineBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: _buildHeader(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: alertsAsync.when(
                data: (data) => _isMapView
                    ? OutbreakMapView(
                        alerts: data.alerts,
                        userPlot: data.userPlot,
                        isOffline: _isOffline,
                      )
                    : _buildListView(data),
                loading: () => _buildLoading(),
                error: (error, _) => _buildError(error),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AlertsBottomNavBar(),
    );
  }

  // ── Offline banner ──────────────────────────────────────────────

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.offlineBanner,
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Offline mode',
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Disease Alerts',
                style: AppTextStyles.headlineMedium,
              ),
            ),
            Semantics(
              label: 'Filter alerts',
              child: IconButton(
                icon: const Icon(Icons.tune, size: 22),
                onPressed: () {},
                color: AppColors.textPrimary,
              ),
            ),
            Semantics(
              label: 'Alert analytics',
              child: IconButton(
                icon: const Icon(Icons.bar_chart, size: 22),
                onPressed: () {},
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Surveillance Active · Nightshade Plots',
                style: AppTextStyles.bodySmall,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ListMapToggle(
              isMapView: _isMapView,
              onChanged: (v) => setState(() => _isMapView = v),
            ),
          ],
        ),
      ],
    );
  }

  // ── List view ───────────────────────────────────────────────────

  Widget _buildListView(AlertsData data) {
    if (data.alerts.isEmpty) return _buildEmpty();

    final mins = DateTime.now().difference(data.lastUpdated).inMinutes;
    final updatedLabel = mins < 60
        ? 'Updated ${mins}m ago'
        : 'Updated ${mins ~/ 60}h ago';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        SeasonHeaderCard(summary: data.seasonSummary),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionTitle(updatedLabel),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Ranked by proximity and immediate danger level',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        ...data.alerts.asMap().entries.map((e) {
          return AlertCard(
            alert: e.value,
            initiallyExpanded: e.key == 0,
            onTap: () {
              ref.read(alertsRepositoryProvider).markRead(e.value.id);
            },
          );
        }),
        const SizedBox(height: AppSpacing.md),
        _buildPrivacyNote(),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildSectionTitle(String updatedLabel) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Active Outbreak Cluster',
            style: AppTextStyles.headlineSmall,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: AppRadius.smAll,
          ),
          child: Text(
            updatedLabel,
            style: AppTextStyles.chip.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // ── Privacy note ────────────────────────────────────────────────

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: const [
                  TextSpan(
                    text: 'Community Crop Protection: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text:
                        'Alerts disclose only confirmed pathogen types '
                        'and approximate radii. Individual farmer '
                        'identities, land plots, and coordinates remain '
                        'private.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 64,
              color: AppColors.primaryLight.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No outbreaks near you',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your area is currently clear of reported nightshade '
              'crop diseases.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading state ───────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  // ── Error state ─────────────────────────────────────────────────

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Unable to load alerts',
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(alertsDataProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
