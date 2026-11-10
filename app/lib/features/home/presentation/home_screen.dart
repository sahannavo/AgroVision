import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../alerts/data/providers.dart';
import '../../alerts/domain/outbreak_alert.dart';
import '../../crop_plots/data/providers.dart';
import '../../crop_plots/domain/crop_plot.dart';
import '../../diagnosis/data/providers.dart';
import '../../diagnosis/domain/diagnosis.dart';
import '../../weather/data/providers.dart';
import '../../weather/domain/weather_forecast.dart';
import 'widgets/home_crop_progress_card.dart';
import 'widgets/home_offline_notice.dart';
import 'widgets/home_outbreak_banner.dart';
import 'widgets/home_quick_action_grid.dart';
import 'widgets/home_recent_diagnosis_tile.dart';
import 'widgets/home_weather_card.dart';

final _homeWeatherProvider = FutureProvider.autoDispose<WeatherForecast>(
  (ref) => ref.watch(weatherRepositoryProvider).getForecast(),
);

final _homePlotsProvider = FutureProvider.autoDispose<List<CropPlot>>(
  (ref) => ref.watch(cropPlotRepositoryProvider).getPlots(),
);

final _homeAlertsProvider = FutureProvider.autoDispose<List<OutbreakAlert>>(
  (ref) => ref.watch(alertsRepositoryProvider).getNearby(radiusKm: 8),
);

final _homeDiagnosesProvider = FutureProvider.autoDispose<List<Diagnosis>>(
  (ref) => ref.watch(diagnosisRepositoryProvider).getHistory(),
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _go(BuildContext context, String location) => context.go(location);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(_homeWeatherProvider);
    final plots = ref.watch(_homePlotsProvider);
    final alerts = ref.watch(_homeAlertsProvider);
    final diagnoses = ref.watch(_homeDiagnosesProvider);
    final isOnline = ref.watch(connectivityProvider);
    final isOffline = !isOnline || weather.valueOrNull?.isCached == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _GreetingRow(onAvatarTap: () => _go(context, '/profile')),
                  if (isOffline) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const HomeOfflineNotice(),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _AsyncSection<WeatherForecast>(
                    value: weather,
                    loading: const HomeLoadingCard(),
                    error: const HomeErrorCard(label: 'Weather unavailable'),
                    empty: const HomeErrorCard(label: 'No weather saved'),
                    builder: (forecast) => HomeWeatherCard(
                      forecast: forecast,
                      isOffline: isOffline,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (isOffline)
                    const HomeOfflineAlertsCard()
                  else
                    _AsyncSection<List<OutbreakAlert>>(
                      value: alerts,
                      loading: const HomeLoadingCard(),
                      error: const HomeErrorCard(label: 'Alerts unavailable'),
                      empty: const HomeErrorCard(label: 'No nearby alerts'),
                      builder: (items) => HomeOutbreakBanner(
                        alert: items.first,
                        onViewSteps: () => _go(context, '/alerts'),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionHeader(
                    title: 'My crops',
                    action: 'Manage',
                    onTap: () => _go(context, '/profile'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 160,
                    child: _AsyncSection<List<CropPlot>>(
                      value: plots,
                      loading: const HomeLoadingCard(),
                      error: const HomeErrorCard(label: 'Crops unavailable'),
                      empty: const HomeErrorCard(label: 'No crops added'),
                      builder: (items) => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (_, index) =>
                            HomeCropProgressCard(plot: items[index]),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _SectionHeader(title: 'Quick actions'),
                  const SizedBox(height: AppSpacing.sm),
                  HomeQuickActionGrid(
                    onScan: () => _go(context, '/diagnose/capture'),
                    onAdvisor: () => _go(context, '/advisor'),
                    onPlanner: () => _go(context, '/planner'),
                    onHistory: () => _go(context, '/history'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionHeader(
                    title: 'Recent diagnosis',
                    action: 'View all',
                    onTap: () => _go(context, '/history'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _AsyncSection<List<Diagnosis>>(
                    value: diagnoses,
                    loading: const HomeLoadingCard(),
                    error: const HomeErrorCard(label: 'History unavailable'),
                    empty: const HomeErrorCard(label: 'No diagnoses yet'),
                    builder: (items) =>
                        HomeRecentDiagnosisTile(diagnosis: items.first),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.onAvatarTap});

  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning, Nimal', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: AppColors.healthy,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Kurunegala', style: AppTextStyles.bodySmall),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Text('•'),
                  ),
                  Text(
                    'NORTH WESTERN',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.healthy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'Open profile',
          child: InkWell(
            onTap: onAvatarTap,
            borderRadius: AppRadius.borderFull,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, color: AppColors.primaryGreen),
                ),
                Positioned(
                  right: 0,
                  bottom: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.headingSmall)),
        if (action != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            ),
            child: Text(
              '$action ›',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryGreen,
              ),
            ),
          ),
      ],
    );
  }
}

class _AsyncSection<T> extends StatelessWidget {
  const _AsyncSection({
    required this.value,
    required this.builder,
    required this.loading,
    required this.error,
    required this.empty,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) builder;
  final Widget loading;
  final Widget error;
  final Widget empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) {
        if (data is Iterable && data.isEmpty) return empty;
        return builder(data);
      },
      loading: () => loading,
      error: (_, _) => error,
    );
  }
}

class HomeLoadingCard extends StatelessWidget {
  const HomeLoadingCard({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 100,
    child: Center(child: CircularProgressIndicator()),
  );
}

class HomeErrorCard extends StatelessWidget {
  const HomeErrorCard({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.borderLg,
      border: Border.all(color: AppColors.divider),
    ),
    child: Text(label, style: AppTextStyles.bodyMedium),
  );
}
