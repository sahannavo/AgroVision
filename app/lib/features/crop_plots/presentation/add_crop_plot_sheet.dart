import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../domain/crop_plot.dart';
import '../domain/crop_plot_repository.dart';

/// Shows the modal bottom sheet for creating or editing a [CropPlot].
Future<void> showAddCropPlotSheet(BuildContext context, {CropPlot? plot}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddCropPlotSheet(plot: plot),
  );
}

class AddCropPlotSheet extends ConsumerStatefulWidget {
  const AddCropPlotSheet({super.key, this.plot});
  final CropPlot? plot;

  @override
  ConsumerState<AddCropPlotSheet> createState() => _AddCropPlotSheetState();
}

class _AddCropPlotSheetState extends ConsumerState<AddCropPlotSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _crop;
  late DateTime _date;
  late String _stage;
  late String _soil;
  late TextEditingController _areaCtrl;
  String? _dateErr;
  bool _saving = false;

  static const _crops = ['Tomato', 'Potato', 'Chili', 'Eggplant'];
  static const _stages = ['Seedling', 'Vegetative', 'Flowering', 'Fruiting', 'Harvesting', 'Nursery'];
  static const _soils = ['Loam (Reddish Brown)', 'Sandy Loam', 'Clay Loam', 'Reddish Brown Earth', 'Noncalcic Brown', 'Alluvial'];

  @override
  void initState() {
    super.initState();
    final p = widget.plot;
    _crop = p?.cropType ?? 'Tomato';
    _date = p?.plantedDate ?? DateTime.now();
    _stage = p?.growthStage ?? 'Seedling';
    _soil = p?.soilType ?? 'Loam (Reddish Brown)';
    _areaCtrl = TextEditingController(text: p != null ? p.area.toString() : '0.5');
  }

  @override
  void dispose() {
    _areaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) setState(() { _date = picked; _dateErr = null; });
  }

  Future<void> _save() async {
    if (_date.isAfter(DateTime.now())) {
      setState(() => _dateErr = 'Planted date cannot be in the future');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final areaVal = double.tryParse(_areaCtrl.text.trim());
    if (areaVal == null || areaVal <= 0) return;

    setState(() => _saving = true);
    final plotData = CropPlot(
      id: widget.plot?.id ?? 'plot_${DateTime.now().millisecondsSinceEpoch}',
      cropType: _crop,
      plotName: widget.plot?.plotName ?? 'Plot ${_crop.substring(0, 1)}',
      variety: widget.plot?.variety,
      plantedDate: _date,
      growthStage: _stage,
      bed: widget.plot?.bed,
      soilType: _soil,
      area: areaVal,
      areaUnit: 'acres',
      status: 'Active',
    );

    try {
      final dynamic repo = ref.read(cropPlotRepositoryProvider);
      widget.plot == null ? await repo.add(plotData) : await repo.update(plotData);
    } catch (_) {
      try {
        final dynamic notifier = (ref as dynamic).read(cropPlotRepositoryProvider.notifier);
        widget.plot == null ? await notifier.add(plotData) : await notifier.update(plotData);
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.plot != null;
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 4, vertical: AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44, height: 4,
                    decoration: BoxDecoration(color: AppColors.outline.withOpacity(0.7), borderRadius: BorderRadius.circular(AppRadius.full)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit crop plot' : 'Add crop plot', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('Maha Season 2024 · Kurunegala', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    Semantics(
                      button: true, label: 'Close',
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: AppColors.outline.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Crop type', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm, runSpacing: AppSpacing.xs,
                  children: _crops.map((c) {
                    final sel = _crop.toLowerCase() == c.toLowerCase();
                    return InkWell(
                      onTap: () => setState(() => _crop = c),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md - 2, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primaryContainer.withOpacity(0.4) : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: sel ? AppColors.primary : AppColors.outline.withOpacity(0.8), width: sel ? 1.5 : 1.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (sel) ...[
                              Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                            ],
                            Text(c, style: AppTextStyles.bodyMedium.copyWith(color: sel ? AppColors.primary : AppColors.textPrimary, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                            if (sel) ...[const SizedBox(width: 6), const Icon(Icons.check, size: 16, color: AppColors.primary)],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Planted date', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    height: 52, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: _dateErr != null ? AppColors.error : AppColors.outline.withOpacity(0.8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(_date), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                        const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                if (_dateErr != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_dateErr!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))),
                const SizedBox(height: AppSpacing.md),
                Text('Growth stage', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                _buildDropdown(_stage, _stages, (v) => setState(() => _stage = v!), isStage: true),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Soil type', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: AppSpacing.xs),
                          _buildDropdown(_soil, _soils, (v) => setState(() => _soil = v!)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Area', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _areaCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: AppColors.outline.withOpacity(0.8))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                              suffixIcon: Container(
                                margin: const EdgeInsets.all(AppSpacing.xs + 2),
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                decoration: BoxDecoration(color: AppColors.outline.withOpacity(0.25), borderRadius: BorderRadius.circular(AppRadius.xs)),
                                child: Text('acres', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                              ),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter area' : ((double.tryParse(val.trim()) ?? 0) <= 0 ? '> 0 required' : null),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    icon: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(isEdit ? Icons.check_circle_outline : Icons.add_circle_outline, size: 20),
                    label: Text(isEdit ? 'Save changes' : 'Save plot', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary, minimumSize: const Size(120, 48)),
                    child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged, {bool isStage = false}) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline.withOpacity(0.8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: isStage
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryContainer.withOpacity(0.4), borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.spa_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(item, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : Text(item, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
  }
}
