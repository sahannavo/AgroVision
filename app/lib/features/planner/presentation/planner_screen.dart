import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_header.dart';
import '../../crop_plots/presentation/add_crop_plot_sheet.dart';
import 'day_plan_card.dart';
import 'growth_stage_stepper.dart';
import 'planner_empty_state.dart';
import 'planner_summary_tiles.dart';
import 'planner_ui_models.dart';
import 'weather_strip.dart';

/// The Planner Screen for AgroVision.
///
/// Matches the designs in `docs/design/planner.png` and `docs/design/planner_empty.png`:
/// - Top App Bar: Brand logo/name, "Planner" screen title, and user profile avatar.
/// - Offline weather banner: "Using weather saved 3 hours ago · Offline".
/// - With plots:
///   - Region & season header with crop plot selector dropdown ("Tomato • Plot A-4").
///   - Phenology timeline stepper ([GrowthStageStepper]).
///   - 7-day weather forecast strip ([WeatherStrip]).
///   - Summary tiles ([PlannerSummaryTiles]).
///   - "This week's plan" section header with count badge ("7 ACTIONS") and daily cards ([DayPlanCard]).
///   - Bottom action card ("Automate Next Week" with "Auto-fill" button).
/// - Without plots:
///   - Displays the empty state layout ([PlannerEmptyState]).
class PlannerScreen extends StatefulWidget {
  /// Optional list of crop plots to display. If empty or null, renders [PlannerEmptyState].
  final List<CropPlotItem>? initialPlots;

  /// Optional forecast items to display in the weather strip.
  final List<DailyForecastItem>? initialForecast;

  /// Optional day plans to display.
  final List<IrrigationDayPlan>? initialPlans;

  const PlannerScreen({
    super.key,
    this.initialPlots,
    this.initialForecast,
    this.initialPlans,
  });

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late List<CropPlotItem> _plots;
  late int _selectedPlotIndex;
  late List<DailyForecastItem> _forecast;
  late int _selectedForecastDayIndex;
  late List<IrrigationDayPlan> _dayPlans;

  @override
  void initState() {
    super.initState();
    _plots = widget.initialPlots ?? _samplePlots;
    _selectedPlotIndex = 0;
    _forecast = widget.initialForecast ?? _sampleForecast;
    _selectedForecastDayIndex = 2; // Wednesday by default
    _dayPlans = widget.initialPlans ?? _sampleDayPlans;
  }

  CropPlotItem? get _currentPlot =>
      _plots.isNotEmpty && _selectedPlotIndex < _plots.length
          ? _plots[_selectedPlotIndex]
          : null;

  @override
  Widget build(BuildContext context) {
    final currentPlot = _currentPlot;
    final hasPlots = currentPlot != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Cached Weather / Offline Notice Banner
            _buildOfflineWeatherBanner(),

            // Content: Empty State vs. Populated Planner
            Expanded(
              child: hasPlots
                  ? _buildPopulatedPlanner(currentPlot)
                  : PlannerEmptyState(
                      onAddCropPlot: () => showAddCropPlotSheet(context),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top App Bar matching AgroVision mockups
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'AgroVision',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          Text(
            'Planner',
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Cached weather banner
  Widget _buildOfflineWeatherBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F0E5),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Using weather saved 3 hours ago',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Offline',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Populated Planner view
  Widget _buildPopulatedPlanner(CropPlotItem plot) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subtitle and Crop Selector Header
          _buildCropHeader(plot),
          const SizedBox(height: AppSpacing.md),

          // Phenology Stepper
          GrowthStageStepper(
            currentStage: plot.stage,
            stageDay: plot.stageDay,
          ),
          const SizedBox(height: AppSpacing.md),

          // 7-day Weather Forecast Strip
          WeatherStrip(
            forecast: _forecast,
            selectedIndex: _selectedForecastDayIndex,
            onDaySelected: (index) {
              setState(() {
                _selectedForecastDayIndex = index;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Summary Tiles (Water this week & Next fertilizer)
          const PlannerSummaryTiles(),
          const SizedBox(height: AppSpacing.md),

          // This week's plan Section Header
          SectionHeader(
            title: "This week's plan",
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '${_dayPlans.length} ACTIONS',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Daily Plan Cards
          ..._dayPlans.map(
            (dayPlan) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: DayPlanCard(plan: dayPlan),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Automate Next Week bottom card
          _buildAutomateNextWeekCard(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// Crop Header with region and dropdown selector
  Widget _buildCropHeader(CropPlotItem currentPlot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.eco_outlined,
                  size: 14,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  currentPlot.regionSubtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Crop Planner',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),

        // Plot selector pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedPlotIndex,
              isDense: false,
              itemHeight: 48,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              items: List.generate(_plots.length, (index) {
                final p = _plots[index];
                return DropdownMenuItem(
                  value: index,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.eco_outlined,
                          size: 14,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            p.cropName,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            p.plotName,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              onChanged: (newIndex) {
                if (newIndex != null) {
                  setState(() {
                    _selectedPlotIndex = newIndex;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Automate Next Week bottom card
  Widget _buildAutomateNextWeekCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3E8),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automate Next Week',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Syncs with local microclimate radar',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              textStyle: AppTextStyles.labelLarge.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Auto-fill'),
          ),
        ],
      ),
    );
  }
}

// Sample fake data matching the mockup in Planner.png
final List<CropPlotItem> _samplePlots = [
  const CropPlotItem(
    id: 'plot-a4',
    cropName: 'Tomato',
    plotName: 'Plot A-4',
    location: 'Kurunegala',
    season: 'Maha',
    stage: CropGrowthStage.flowering,
    stageDay: 48,
  ),
  const CropPlotItem(
    id: 'plot-b2',
    cropName: 'Chilli',
    plotName: 'Plot B-2',
    location: 'Kurunegala',
    season: 'Maha',
    stage: CropGrowthStage.vegetative,
    stageDay: 22,
  ),
];

final List<DailyForecastItem> _sampleForecast = [
  const DailyForecastItem(dayName: 'Mon', tempC: 31, rainPercentage: 0, iconCode: 'sunny'),
  const DailyForecastItem(dayName: 'Tue', tempC: 29, rainPercentage: 10, iconCode: 'sunny'),
  const DailyForecastItem(dayName: 'Wed', tempC: 26, rainPercentage: 85, iconCode: 'rain'),
  const DailyForecastItem(dayName: 'Thu', tempC: 30, rainPercentage: 20, iconCode: 'cloudy'),
  const DailyForecastItem(dayName: 'Fri', tempC: 32, rainPercentage: 5, iconCode: 'sunny'),
  const DailyForecastItem(dayName: 'Sat', tempC: 31, rainPercentage: 10, iconCode: 'sunny'),
  const DailyForecastItem(dayName: 'Sun', tempC: 28, rainPercentage: 60, iconCode: 'rain'),
];

final List<IrrigationDayPlan> _sampleDayPlans = [
  const IrrigationDayPlan(
    id: 'plan-1',
    dateLabel: 'Monday, 12 Oct',
    status: DayPlanStatus.completed,
    waterAmount: '4 L/m²',
    scheduleTime: 'Evening (6:00 PM)',
  ),
  const IrrigationDayPlan(
    id: 'plan-2',
    dateLabel: 'Tuesday, 13 Oct',
    status: DayPlanStatus.done,
    waterAmount: '4 L/m²',
    scheduleTime: 'Morning (6:30 AM)',
  ),
  const IrrigationDayPlan(
    id: 'plan-3',
    dateLabel: 'Wednesday, 14 Oct',
    status: DayPlanStatus.skipped,
    waterAmount: '0 L/m²',
    scheduleTime: 'Skipped',
    isSkipped: true,
    skipReason: 'Rain expected. Skip watering.',
    skipDetail:
        'Monsoon shower forecast (~18mm). Check tensiometer soil moisture sensor at noon before resuming drip schedule.',
  ),
  const IrrigationDayPlan(
    id: 'plan-4',
    dateLabel: 'Thursday, 15 Oct',
    status: DayPlanStatus.upcoming,
    waterAmount: '5 L/m²',
    scheduleTime: 'Evening (5:30 PM)',
  ),
  const IrrigationDayPlan(
    id: 'plan-5',
    dateLabel: 'Friday, 16 Oct',
    status: DayPlanStatus.upcoming,
    waterAmount: '5 L/m²',
    scheduleTime: 'Morning (6:00 AM)',
    fertilizerTitle: 'NPK 12–12–17 · 20 g / plant',
    fertilizerTag: 'Top-dress',
    fertilizerDetail:
        'Apply along drip perimeter circle (15cm from main stem) prior to scheduled irrigation cycle.',
  ),
  const IrrigationDayPlan(
    id: 'plan-6',
    dateLabel: 'Saturday, 17 Oct',
    status: DayPlanStatus.upcoming,
    waterAmount: '5 L/m²',
    scheduleTime: 'Evening (5:30 PM)',
  ),
  const IrrigationDayPlan(
    id: 'plan-7',
    dateLabel: 'Sunday, 18 Oct',
    status: DayPlanStatus.upcoming,
    waterAmount: '5 L/m²',
    scheduleTime: 'Morning (6:30 AM)',
  ),
];

