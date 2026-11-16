import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/providers.dart';
import '../../weather/data/providers.dart';
import '../domain/planting_recommendation.dart';
import 'widgets/advisor_empty_state.dart';
import 'widgets/advisor_input_card.dart';
import 'widgets/crop_match_card.dart';

/// The primary screen for the Planting Advisor feature in AgroVision.
///
/// Implements two dynamic views:
/// 1. Before search: An empty state introducing nightshade crops.
/// 2. Results: A ranked list of crop recommendations with match scores,
///    suitability progress bars, reason chips, and harvest estimates.
///
/// Does not show a bottom navigation bar, and features a back arrow button.
class AdvisorScreen extends ConsumerStatefulWidget {
  /// Optional initial soil type filter.
  final String initialSoil;

  /// Optional initial cultivation season filter.
  final String initialSeason;

  /// Optional initial field location.
  final String initialLocation;

  /// Whether to automatically fetch recommendations on initial build.
  final bool autoFetch;

  const AdvisorScreen({
    super.key,
    this.initialSoil = 'Loam',
    this.initialSeason = AdvisorInputCard.yalaSeason,
    this.initialLocation = 'Kurunegala, NW',
    this.autoFetch = false,
  });

  @override
  ConsumerState<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends ConsumerState<AdvisorScreen> {
  late String _location;
  late String _selectedSoil;
  late String _selectedSeason;

  bool _hasSearched = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<PlantingRecommendation> _results = [];

  @override
  void initState() {
    super.initState();
    _location = widget.initialLocation;
    _selectedSoil = widget.initialSoil;
    _selectedSeason = widget.initialSeason;

    if (widget.autoFetch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchRecommendations();
      });
    }
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(advisorRepositoryProvider);
      final seasonKey = _selectedSeason.toLowerCase().contains('yala')
          ? 'Yala'
          : 'Maha';

      final recommendations = await repository.recommend(
        soil: _selectedSoil,
        season: seasonKey,
        location: _location,
      );

      if (mounted) {
        setState(() {
          _results = recommendations;
          _hasSearched = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to generate crop recommendations. Please check connection and retry.';
          _isLoading = false;
        });
      }
    }
  }

  void _handleDetectLocation() {
    setState(() {
      _location = 'Kurunegala, NW';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Field location detected: Kurunegala, NW'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Formats [fetchedAt] as a human-readable relative time string.
  ///
  /// Returns strings like "just now", "5 min ago", "2 hrs ago", "1 day ago".
  String _formatCacheDuration(DateTime fetchedAt) {
    final diff = DateTime.now().difference(fetchedAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hr' : 'hrs'} ago';
    }
    final d = diff.inDays;
    return '$d ${d == 1 ? 'day' : 'days'} ago';
  }

  @override
  Widget build(BuildContext context) {
    // Watch the real weather forecast so the cached-weather banner is live.
    // The FutureProvider returns AsyncValue<WeatherForecast?> — null means
    // no data available (offline with no cache). When kUseFakes is true,
    // FakeWeatherRepository returns a static forecast so the banner still shows.
    final weatherAsync = ref.watch(weatherForecastProvider);
    final forecast = weatherAsync.valueOrNull;
    final isWeatherCached = forecast?.isCached ?? false;
    final weatherCachedText = (forecast != null && isWeatherCached)
        ? _formatCacheDuration(forecast.fetchedAt)
        : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Semantics(
          label: 'Navigate back',
          button: true,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.spa_rounded,
                  size: 14.0,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'Planting Advisor',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Semantics(
              label: 'User profile',
              button: true,
              child: Container(
                width: 38.0,
                height: 38.0,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Input Parameter Card — real weather cache values wired in
              AdvisorInputCard(
                location: _location,
                selectedSoil: _selectedSoil,
                selectedSeason: _selectedSeason,
                isWeatherCached: isWeatherCached,
                weatherCachedDurationText: weatherCachedText,
                isLoading: _isLoading,
                onDetectLocation: _handleDetectLocation,
                onSoilChanged: (soil) {
                  setState(() => _selectedSoil = soil);
                },
                onSeasonChanged: (season) {
                  setState(() => _selectedSeason = season);
                },
                onGetRecommendations: _fetchRecommendations,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Dynamic content area: Loading, Error, Empty, or Results
              if (_isLoading)
                const _AdvisorLoadingSkeleton()
              else if (_errorMessage != null)
                _buildErrorCard()
              else if (!_hasSearched)
                const AdvisorEmptyState()
              else
                _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 44.0,
            color: AppColors.danger,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Recommendation Error',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _fetchRecommendations,
            icon: const Icon(Icons.refresh_rounded, size: 18.0),
            label: const Text('Retry Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final seasonDisplay = _selectedSeason.toLowerCase().contains('yala')
        ? 'Yala'
        : 'Maha';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best crops for you',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${_results.length} nightshade crops analyzed for $seasonDisplay',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 20.0,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Ranked Recommendation Cards
        ...List.generate(_results.length, (index) {
          final rec = _results[index];
          return CropMatchCard(
            recommendation: rec,
            rank: index + 1,
            onTapPlan: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening planting plan for ${rec.crop}...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

/// Shimmer loading skeleton widget for [AdvisorScreen].
class _AdvisorLoadingSkeleton extends StatelessWidget {
  const _AdvisorLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: AppColors.divider.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.mdSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.0,
                          height: 16.0,
                          decoration: BoxDecoration(
                            color: AppColors.divider.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Container(
                          width: 80.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            color: AppColors.divider.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      color: AppColors.divider.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.mdSm),
              Container(
                width: double.infinity,
                height: 6.0,
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: AppSpacing.mdSm),
              Container(
                width: 160.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
