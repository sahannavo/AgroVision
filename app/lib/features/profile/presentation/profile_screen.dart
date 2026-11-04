import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../auth/domain/auth_repository.dart';
import '../../crop_plots/domain/crop_plot.dart';
import '../../crop_plots/domain/crop_plot_repository.dart';
import '../../crop_plots/presentation/add_crop_plot_sheet.dart';
import 'widgets/crop_plot_tile.dart';
import 'widgets/farm_info_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';

/// Profile screen displaying farmer details, farm information,
/// crop plots list with add/edit actions, settings, and logout.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;

  static final List<CropPlot> _defaultPlots = [
    CropPlot(
      id: 'plot_1', cropType: 'Tomato', plotName: 'Plot A', variety: 'Thilina var.',
      plantedDate: DateTime(2024, 10, 12), growthStage: 'Flowering', bed: 'Bed #2',
      soilType: 'Loam (Reddish Brown)', area: 1.0, areaUnit: 'acre', status: 'Active',
    ),
    CropPlot(
      id: 'plot_2', cropType: 'Green Chilli', plotName: 'Plot B', variety: 'MICH 1',
      plantedDate: DateTime(2024, 10, 28), growthStage: 'Vegetative', bed: 'East Terraces',
      soilType: 'Loam (Reddish Brown)', area: 0.8, areaUnit: 'acre', status: 'Active',
    ),
    CropPlot(
      id: 'plot_3', cropType: 'Brinjal', plotName: 'Plot C', variety: 'Padagoda',
      plantedDate: DateTime(2024, 9, 15), growthStage: 'Fruiting', bed: 'South Garden',
      soilType: 'Loam (Reddish Brown)', area: 0.7, areaUnit: 'acre', status: 'Active',
    ),
  ];

  Future<void> _handleSignOut() async {
    try {
      final dynamic authRepo = ref.read(authRepositoryProvider);
      await authRepo.signOut();
    } catch (_) {}
    if (mounted) context.go('/login');
  }

  void _openAddSheet([CropPlot? plot]) => showAddCropPlotSheet(context, plot: plot);

  @override
  Widget build(BuildContext context) {
    final dynamic providerData = ref.watch(cropPlotRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: AppSpacing.md),
              ProfileHeader(
                name: 'Nimal Perera',
                email: 'nimal.kurunegala@agrovision.lk',
                role: 'Nightshade Specialist',
                season: "Maha '24",
                onEdit: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit profile is coming soon')),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const FarmInfoCard(
                district: 'Kurunegala District', location: 'Kurunegala',
                province: 'NW Province', soilType: 'Loam (Reddish Brown)', landSize: '2.5 acres',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildCropPlotsSection(providerData),
              const SizedBox(height: AppSpacing.md),
              SettingsSection(
                notificationsEnabled: _notificationsEnabled,
                onNotificationsChanged: (val) => setState(() => _notificationsEnabled = val),
                onLanguageTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language settings')),
                ),
                onOfflineDataTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Offline data is synchronized')),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _handleSignOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    backgroundColor: AppColors.surface,
                  ),
                  icon: const Icon(Icons.logout, size: 20, color: AppColors.error),
                  label: Text('Log out', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.error)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(
                  'AgroVision v2.4 (Maha Edition) · DOA Peradeniya Guidelines',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Back',
          child: InkWell(
            onTap: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : context.go('/home'),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outline.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        Text('Profile', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.outline.withOpacity(0.8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Offline mode',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCropPlotsSection(dynamic providerData) {
    if (providerData is AsyncValue<List<CropPlot>>) {
      return providerData.when(
        data: (plots) => _buildPlotsList(plots),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (_, __) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.error),
          ),
          child: Column(
            children: [
              Text('Failed to load crop plots', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
              const SizedBox(height: AppSpacing.xs),
              TextButton(onPressed: () => setState(() {}), child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (providerData is List<CropPlot>) return _buildPlotsList(providerData);
    return _buildPlotsList(_defaultPlots);
  }

  Widget _buildPlotsList(List<CropPlot> plots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('My crop plots', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${plots.length} Active',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 11),
              ),
            ),
            const Spacer(),
            Text('Season Maha 2024', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (plots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.outline.withOpacity(0.6)),
            ),
            child: Center(
              child: Text(
                'No crop plots added yet. Tap below to add your first plot.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...plots.map((plot) => CropPlotTile(plot: plot, onEdit: (p) => _openAddSheet(p))),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _openAddSheet(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              backgroundColor: AppColors.surface,
            ),
            icon: const Icon(Icons.add, size: 20, color: AppColors.primary),
            label: Text('Add crop plot', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}
