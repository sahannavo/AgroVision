import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/providers.dart';
import 'register_account_screen.dart';
import 'validators.dart';

// ── Static data ────────────────────────────────────────────────────────────

const _kDistricts = [
  'Colombo', 'Gampaha', 'Kalutara', 'Kandy', 'Matale', 'Nuwara Eliya',
  'Galle', 'Hambantota', 'Matara', 'Jaffna', 'Kilinochchi', 'Mannar',
  'Mullaitivu', 'Vavuniya', 'Batticaloa', 'Ampara', 'Trincomalee',
  'Kurunegala', 'Puttalam', 'Anuradhapura', 'Polonnaruwa', 'Badulla',
  'Monaragala', 'Ratnapura', 'Kegalle',
];

const _kSoilTypes = ['Clay', 'Loam', 'Sandy', 'Silt'];

const _kCrops = ['Tomato', 'Potato', 'Chilli', 'Eggplant'];

const _kCropSinhala = {
  'Tomato': 'Thakkali',
  'Potato': 'Ala',
  'Chilli': 'Miris',
  'Eggplant': 'Wambatu',
};

/// Registration Step 2 — farm details.
///
/// Receives [AccountRegistrationArgs] from GoRouter's `extra`.
/// Collects GPS/district, soil type, land area, and crops grown.
/// Calls [AuthRepository.register] then [AuthRepository.saveProfile].
class RegisterFarmScreen extends ConsumerStatefulWidget {
  const RegisterFarmScreen({super.key, this.args});

  /// Passed via GoRouter `extra`; null only during isolated widget tests.
  final AccountRegistrationArgs? args;

  @override
  ConsumerState<RegisterFarmScreen> createState() =>
      _RegisterFarmScreenState();
}

class _RegisterFarmScreenState extends ConsumerState<RegisterFarmScreen> {
  final _areaFormKey = GlobalKey<FormState>();
  final _areaCtrl = TextEditingController(text: '2.5');

  String? _selectedDistrict = 'Kurunegala';
  String _selectedSoil = 'Loam';
  final Set<String> _selectedCrops = {'Tomato', 'Chilli'};
  bool _inAcres = true;
  bool _loading = false;
  bool _locationLoading = false;
  String? _locationError;
  double? _lat;
  double? _lng;

  @override
  void dispose() {
    _areaCtrl.dispose();
    super.dispose();
  }

  /// Simulate GPS fetch; real impl via LocationService (see NOTES).
  Future<void> _useCurrentLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _locationLoading = false;
        _lat = 7.4863;
        _lng = 80.3623;
        _selectedDistrict = 'Kurunegala';
      });
    }
  }

  double get _landSizeAcres {
    final v = double.tryParse(_areaCtrl.text) ?? 0;
    return _inAcres ? v : v * 2.47105;
  }

  Future<void> _finishSetup() async {
    if (!_areaFormKey.currentState!.validate()) return;
    if (_selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one crop.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final args = widget.args;
      final region = _selectedDistrict ?? 'Sri Lanka';

      if (args != null) {
        final user = await authRepo.register(
          email: args.email,
          password: args.password,
          fullName: args.fullName,
          region: region,
          soilType: _selectedSoil,
          landSize: _landSizeAcres,
          latitude: _lat,
          longitude: _lng,
        );
        await authRepo.saveProfile(
          user.copyWith(region: '$region · ${_selectedCrops.join(', ')}'),
        );
      }

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Semantics(
                    label: 'Go back',
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () =>
                          context.canPop() ? context.pop() : null,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Step 2 of 2',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' · Farm Details',
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  _OfflineReadyBadge(),
                ],
              ),
            ),
            // Step bar — 100 %
            LinearProgressIndicator(
              value: 1.0,
              minHeight: 4,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
            // ── Scrollable content ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Form(
                  key: _areaFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'Tell us about your farm',
                        style: AppTextStyles.headingLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'We use this to tailor micro-weather, planting '
                        'calendars, and disease alerts.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Farm Location ──────────────────────────────────
                      _SectionCard(
                        title: 'Farm Location',
                        icon: Icons.my_location_rounded,
                        badge: _selectedDistrict != null ? 'Zone DL1' : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _locationLoading
                                  ? null
                                  : _useCurrentLocation,
                              icon: _locationLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryGreen,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.gps_fixed_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                _locationLoading
                                    ? 'Detecting location…'
                                    : 'Use my current GPS position',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryGreen,
                                side: const BorderSide(
                                    color: AppColors.primaryGreen),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.borderMd),
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.mdSm),
                              ),
                            ),
                            if (_locationError != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _locationError!,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.danger),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'District & Agro-Ecological Region',
                              style: AppTextStyles.labelMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDistrict,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon:
                                    const Icon(Icons.location_on_outlined),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.mdSm,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: const BorderSide(
                                      color: AppColors.divider),
                                ),
                              ),
                              items: _kDistricts
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(d,
                                          style: AppTextStyles.bodyMedium),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedDistrict = v),
                              validator: (v) =>
                                  v == null ? 'Select your district' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Soil Type ──────────────────────────────────────
                      _SectionCard(
                        title: 'Soil Type',
                        icon: Icons.landscape_outlined,
                        badge: 'Tap to pick',
                        child: _SoilChips(
                          selected: _selectedSoil,
                          onChanged: (v) =>
                              setState(() => _selectedSoil = v),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Total Cultivated Area ──────────────────────────
                      _SectionCard(
                        title: 'Total Cultivated Area',
                        icon: Icons.straighten_outlined,
                        child: _AreaInput(
                          controller: _areaCtrl,
                          inAcres: _inAcres,
                          onUnitToggle: (v) =>
                              setState(() => _inAcres = v),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Crops You Grow ─────────────────────────────────
                      _SectionCard(
                        title: 'Crops You Grow',
                        icon: Icons.eco_outlined,
                        badge: '${_selectedCrops.length} Selected',
                        subtitle: 'AgroVision AI\nNightshade models',
                        child: _CropGrid(
                          selected: _selectedCrops,
                          onToggle: (crop) {
                            setState(() {
                              if (_selectedCrops.contains(crop)) {
                                _selectedCrops.remove(crop);
                              } else {
                                _selectedCrops.add(crop);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Finish button ──────────────────────────────────
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _finishSetup,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnPrimary,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                          label: Text(
                            'Finish Setup',
                            style: AppTextStyles.button,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.textOnPrimary,
                            shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.borderMd),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Farm metadata cached on-device for instant offline diagnostics',
                              style: AppTextStyles.labelSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Offline ready badge ────────────────────────────────────────────────────

class _OfflineReadyBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_done_outlined,
            size: 14,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            'Offline Ready',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.badge,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? badge;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall),
                    if (subtitle != null)
                      Text(subtitle!, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

// ── Soil chips ─────────────────────────────────────────────────────────────

class _SoilChips extends StatelessWidget {
  const _SoilChips({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 3.2,
      children: _kSoilTypes.map((soil) {
        final isSelected = soil == selected;
        return InkWell(
          onTap: () => onChanged(soil),
          borderRadius: AppRadius.borderFull,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.divider.withValues(alpha: 0.5),
              borderRadius: AppRadius.borderFull,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  soil,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Area input ─────────────────────────────────────────────────────────────

class _AreaInput extends StatelessWidget {
  const _AreaInput({
    required this.controller,
    required this.inAcres,
    required this.onUnitToggle,
  });

  final TextEditingController controller;
  final bool inAcres;
  final ValueChanged<bool> onUnitToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: TextFormField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            textAlign: TextAlign.center,
            style: AppTextStyles.headingMedium,
            validator: AuthValidators.landSize,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide:
                    const BorderSide(color: AppColors.divider),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('Qty', style: AppTextStyles.bodySmall),
        const Spacer(),
        // Acres / Hectares toggle
        Container(
          decoration: BoxDecoration(
            color: AppColors.divider.withValues(alpha: 0.5),
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UnitBtn(
                label: 'Acres',
                selected: inAcres,
                onTap: () => onUnitToggle(true),
              ),
              _UnitBtn(
                label: 'Hectares',
                selected: !inAcres,
                onTap: () => onUnitToggle(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnitBtn extends StatelessWidget {
  const _UnitBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: AppRadius.borderSm,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: selected
                ? AppColors.textOnPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Crop multi-select grid ─────────────────────────────────────────────────

class _CropGrid extends StatelessWidget {
  const _CropGrid({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.8,
      children: _kCrops.map((crop) {
        final isSelected = selected.contains(crop);
        final sinhala = _kCropSinhala[crop] ?? '';
        return InkWell(
          onTap: () => onToggle(crop),
          borderRadius: AppRadius.borderMd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.eco_rounded,
                  size: 18,
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        crop,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        sinhala,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.textOnPrimary
                                  .withValues(alpha: 0.75)
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
