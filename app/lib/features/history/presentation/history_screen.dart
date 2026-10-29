import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../diagnosis/data/providers.dart';
import '../../diagnosis/domain/diagnosis.dart';
import '../data/providers.dart';
import '../domain/decision_log_entry.dart';
import '../domain/history_stats.dart';
import 'widgets/decision_timeline.dart';
import 'widgets/diagnoses_bar_chart.dart';
import 'widgets/disease_donut_chart.dart';
import 'widgets/history_filter_bar.dart';
import 'widgets/history_summary_tiles.dart';
import 'widgets/record_tile.dart';

/// Main screen displaying crop diagnosis history, farm decisions, and trends analytics.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  HistorySeason _selectedSeason = HistorySeason.all;
  HistoryCrop _selectedCrop = HistoryCrop.all;
  HistorySort _selectedSort = HistorySort.newest;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _matchesSeason(DateTime date) {
    if (_selectedSeason == HistorySeason.all) return true;
    final month = date.month;
    if (_selectedSeason == HistorySeason.yala) {
      return month >= 5 && month <= 8;
    } else {
      return month >= 9 || month <= 3;
    }
  }

  List<Diagnosis> _filterDiagnoses(List<Diagnosis> list) {
    var filtered = list.where((d) {
      final cropMatch = _selectedCrop == HistoryCrop.all ||
          d.cropType.toLowerCase() == _selectedCrop.name.toLowerCase();
      final seasonMatch = _matchesSeason(d.diagnosedAt);
      return cropMatch && seasonMatch;
    }).toList();

    if (_selectedSort == HistorySort.confidence) {
      filtered.sort((a, b) => b.confidence.compareTo(a.confidence));
    } else if (_selectedSort == HistorySort.severity) {
      filtered.sort((a, b) {
        final aSeverity = a.predictedClass.isHealthy ? 0 : 1;
        final bSeverity = b.predictedClass.isHealthy ? 0 : 1;
        return bSeverity.compareTo(aSeverity);
      });
    } else {
      filtered.sort((a, b) => b.diagnosedAt.compareTo(a.diagnosedAt));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(connectivityProvider);
    final historyRepo = ref.watch(historyRepositoryProvider);
    final diagnosisRepo = ref.watch(diagnosisRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'History & Analytics',
                                  style: AppTextStyles.headingMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  'Track past crop scans and farm decisions',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isOnline) const OfflinePill(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      HistoryFilterBar(
                        selectedSeason: _selectedSeason,
                        selectedCrop: _selectedCrop,
                        selectedSort: _selectedSort,
                        onSeasonChanged: (s) =>
                            setState(() => _selectedSeason = s),
                        onCropChanged: (c) =>
                            setState(() => _selectedCrop = c),
                        onSortChanged: (s) =>
                            setState(() => _selectedSort = s),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarHeaderDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primaryGreen,
                    indicatorWeight: 3.0,
                    labelColor: AppColors.primaryGreen,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Diagnoses'),
                      Tab(text: 'Decisions'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDiagnosesTab(diagnosisRepo, historyRepo),
              _buildDecisionsTab(historyRepo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosesTab(diagnosisRepo, HistoryRepository historyRepo) {
    return FutureBuilder<HistoryStats>(
      future: historyRepo.getStats(),
      builder: (context, statsSnapshot) {
        return StreamBuilder<List<Diagnosis>>(
          stream: diagnosisRepo.watchHistory(),
          builder: (context, recordsSnapshot) {
            if (statsSnapshot.connectionState == ConnectionState.waiting &&
                recordsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (recordsSnapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load diagnoses history',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              );
            }

            final allDiagnoses = recordsSnapshot.data ?? [];
            final filteredDiagnoses = _filterDiagnoses(allDiagnoses);

            final stats = statsSnapshot.data ??
                HistoryStats(
                  totalScans: allDiagnoses.length,
                  healthyPercent: allDiagnoses.isEmpty
                      ? 100
                      : ((allDiagnoses.where((d) => d.predictedClass.isHealthy).length /
                                  allDiagnoses.length) *
                              100)
                          .round(),
                  topIssue: allDiagnoses.isEmpty ? 'None' : 'Late Blight',
                  weeklyScans: const {'W1': 2, 'W2': 4, 'W3': 3, 'W4': 5, 'W5': 6, 'W6': 7, 'W7': 5, 'W8': 8},
                  diseaseBreakdown: const {'Late Blight': 12, 'Early Blight': 8, 'Healthy': 16},
                );

            if (allDiagnoses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 56,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No scans yet. Scan your first leaf',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                HistorySummaryTiles.diagnoses(
                  totalScans: stats.totalScans,
                  healthyPercent: stats.healthyPercent,
                  topIssue: stats.topIssue,
                ),
                const SizedBox(height: AppSpacing.md),
                DiagnosesBarChart(weeklyScans: stats.weeklyScans),
                const SizedBox(height: AppSpacing.md),
                DiseaseDonutChart(diseaseBreakdown: stats.diseaseBreakdown),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'Recent records (${filteredDiagnoses.length})',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final diagnosis in filteredDiagnoses) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: RecordTile(diagnosis: diagnosis),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDecisionsTab(HistoryRepository historyRepo) {
    return FutureBuilder<List<DecisionLogEntry>>(
      future: historyRepo.getDecisions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        final decisions = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            HistorySummaryTiles.decisions(
              totalDecisions: decisions.length,
              impact: decisions.isEmpty ? 'Normal' : 'High Impact',
              topAction: decisions.isEmpty ? 'None' : 'Fungicide Spray',
            ),
            const SizedBox(height: AppSpacing.lg),
            DecisionTimeline(entries: decisions),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarHeaderDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
