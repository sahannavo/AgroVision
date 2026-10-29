import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Predefined supported crops in the AgroVision nightshade family.
enum AgroCropType {
  tomato(name: 'Tomato', scientificName: 'Solanum lycopersicum'),
  chilli(name: 'Chilli', scientificName: 'Capsicum annuum'),
  eggplant(name: 'Eggplant', scientificName: 'Solanum melongena'),
  potato(name: 'Potato', scientificName: 'Solanum tuberosum');

  const AgroCropType({required this.name, required this.scientificName});

  final String name;
  final String scientificName;

  IconData get icon {
    switch (this) {
      case AgroCropType.tomato:
        return Icons.eco_rounded;
      case AgroCropType.chilli:
        return Icons.local_fire_department_rounded;
      case AgroCropType.eggplant:
        return Icons.spa_rounded;
      case AgroCropType.potato:
        return Icons.grain_rounded;
    }
  }

  static AgroCropType? fromString(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('tomato')) return AgroCropType.tomato;
    if (lower.contains('chilli') || lower.contains('chili')) {
      return AgroCropType.chilli;
    }
    if (lower.contains('eggplant') || lower.contains('brinjal')) {
      return AgroCropType.eggplant;
    }
    if (lower.contains('potato')) return AgroCropType.potato;
    return null;
  }
}

/// A specialized chip selector for nightshade crops (Tomato, Potato, Chilli, Eggplant).
///
/// Supports:
/// - Single and multi-select modes via [isMultiSelect].
/// - Selected state with tick indicator as shown in Figma designs.
/// - Responsive wrapping for screen widths 360dp to 430dp.
/// - Minimum tap target height of 48dp with accessible semantics.
///
/// Example:
/// ```dart
/// // Single select
/// CropChipSelector(
///   selectedCrop: 'Tomato',
///   onCropSelected: (crop) => print('Selected $crop'),
/// )
///
/// // Multi select
/// CropChipSelector(
///   isMultiSelect: true,
///   selectedCrops: {'Tomato', 'Chilli'},
///   onCropsChanged: (crops) => print('Active crops: $crops'),
/// )
/// ```
class CropChipSelector extends StatelessWidget {
  /// The list of crop names to display. Defaults to all 4 supported nightshade crops.
  final List<String> crops;

  /// The currently selected crop name in single-select mode.
  final String? selectedCrop;

  /// The set of selected crop names in multi-select mode.
  final Set<String> selectedCrops;

  /// Whether multiple crops can be selected simultaneously.
  final bool isMultiSelect;

  /// Callback when a single crop is selected or deselected.
  final ValueChanged<String?>? onCropSelected;

  /// Callback when the set of selected crops changes in multi-select mode.
  final ValueChanged<Set<String>>? onCropsChanged;

  /// Whether the chips are interactive.
  final bool enabled;

  const CropChipSelector({
    super.key,
    this.crops = const ['Tomato', 'Chilli', 'Eggplant', 'Potato'],
    this.selectedCrop,
    this.selectedCrops = const {},
    this.isMultiSelect = false,
    this.onCropSelected,
    this.onCropsChanged,
    this.enabled = true,
  });

  bool _isSelected(String crop) {
    if (isMultiSelect) {
      return selectedCrops.contains(crop);
    }
    return selectedCrop == crop;
  }

  void _handleTap(String crop) {
    if (!enabled) return;

    if (isMultiSelect) {
      final updated = Set<String>.from(selectedCrops);
      if (updated.contains(crop)) {
        updated.remove(crop);
      } else {
        updated.add(crop);
      }
      onCropsChanged?.call(updated);
    } else {
      final newSelection = selectedCrop == crop ? null : crop;
      onCropSelected?.call(newSelection);
    }
  }

  IconData _getIconForCrop(String crop) {
    final type = AgroCropType.fromString(crop);
    return type?.icon ?? Icons.eco_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: crops.map((crop) {
        final isSelected = _isSelected(crop);
        final icon = _getIconForCrop(crop);

        return _SelectableChip(
          label: crop,
          icon: isSelected ? Icons.check_rounded : icon,
          isSelected: isSelected,
          enabled: enabled,
          onTap: () => _handleTap(crop),
        );
      }).toList(),
    );
  }
}

/// A generic chip selector for single or multi-choice options such as
/// Soil Type (Clay, Loam, Sandy, Silt) and Cultivation Season (Maha, Yala).
///
/// Example:
/// ```dart
/// OptionChips<String>(
///   options: const ['Clay', 'Loam', 'Sandy', 'Silt'],
///   selectedOption: 'Loam',
///   onOptionSelected: (soil) => setState(() => _selectedSoil = soil),
/// )
/// ```
class OptionChips<T> extends StatelessWidget {
  /// All available options.
  final List<T> options;

  /// Currently selected option for single-select mode.
  final T? selectedOption;

  /// Set of selected options for multi-select mode.
  final Set<T> selectedOptions;

  /// Whether multiple options can be chosen.
  final bool isMultiSelect;

  /// Builds a human-readable string label for each option.
  final String Function(T option)? labelBuilder;

  /// Optional icon builder for each option.
  final IconData? Function(T option)? iconBuilder;

  /// Callback when a single option is chosen.
  final ValueChanged<T?>? onOptionSelected;

  /// Callback when options change in multi-select mode.
  final ValueChanged<Set<T>>? onOptionsChanged;

  /// Whether interactions are enabled.
  final bool enabled;

  const OptionChips({
    super.key,
    required this.options,
    this.selectedOption,
    this.selectedOptions = const {},
    this.isMultiSelect = false,
    this.labelBuilder,
    this.iconBuilder,
    this.onOptionSelected,
    this.onOptionsChanged,
    this.enabled = true,
  });

  bool _isSelected(T option) {
    if (isMultiSelect) {
      return selectedOptions.contains(option);
    }
    return selectedOption == option;
  }

  void _handleTap(T option) {
    if (!enabled) return;

    if (isMultiSelect) {
      final updated = Set<T>.from(selectedOptions);
      if (updated.contains(option)) {
        updated.remove(option);
      } else {
        updated.add(option);
      }
      onOptionsChanged?.call(updated);
    } else {
      final newSelection = selectedOption == option ? null : option;
      onOptionSelected?.call(newSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = _isSelected(option);
        final label = labelBuilder != null
            ? labelBuilder!(option)
            : option.toString();
        final customIcon = iconBuilder?.call(option);
        final displayIcon = isSelected ? Icons.check_rounded : customIcon;

        return _SelectableChip(
          label: label,
          icon: displayIcon,
          isSelected: isSelected,
          enabled: enabled,
          onTap: () => _handleTap(option),
        );
      }).toList(),
    );
  }
}

/// Internal reusable selectable chip item maintaining visual consistency
/// with the AgroVision design system.
class _SelectableChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.primaryGreen
        : AppColors.primaryGreen.withValues(alpha: 0.08);

    final fgColor = isSelected
        ? AppColors.textOnPrimary
        : AppColors.textPrimary;

    final borderColor = isSelected
        ? AppColors.primaryGreen
        : Colors.transparent;

    return Semantics(
      label: '$label chip',
      selected: isSelected,
      enabled: enabled,
      button: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0),
        child: Center(
          widthFactor: 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? bgColor
                      : AppColors.divider.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: enabled ? borderColor : AppColors.divider,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16.0,
                        color: enabled
                            ? (isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.primaryGreen)
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: enabled ? fgColor : AppColors.textTertiary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
