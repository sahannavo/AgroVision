import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/providers.dart';
import '../domain/diagnosis.dart';
import '../domain/disease_class.dart';
import 'widgets/action_steps_card.dart';
import 'widgets/candidate_match_tile.dart';
import 'widgets/capture_tips_card.dart';
import 'widgets/healthy_tips_card.dart';
import 'widgets/prevention_card.dart';
import 'widgets/result_header_card.dart';

/// Threshold below which a scan is considered low confidence (70%).
const double kConfidenceThreshold = 0.70;

/// Screen presenting the results of leaf analysis with three dynamic variants:
/// 1. Disease found (confidence >= 70% and not healthy)
/// 2. Low confidence (confidence < 70%)
/// 3. Healthy (class is healthy)
class ResultScreen extends ConsumerStatefulWidget {
  final Diagnosis? diagnosis;

  const ResultScreen({
    super.key,
    this.diagnosis,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isSaved = false;
  bool _isSaving = false;

  Diagnosis _resolveDiagnosis() {
    if (widget.diagnosis != null) return widget.diagnosis!;

    // Fallback default sample diagnosis if none provided
    return Diagnosis(
      id: 'diag-fallback-001',
      userId: 'user-001',
      cropType: 'Tomato',
      imagePath: 'assets/images/placeholder_logo.png',
      predictedClass: DiseaseClass.earlyBlight,
      confidence: 0.92,
      topMatches: const [
        TopMatch(diseaseClass: DiseaseClass.earlyBlight, confidence: 0.92),
        TopMatch(diseaseClass: DiseaseClass.bacterialSpot, confidence: 0.08),
      ],
      diagnosedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }

  Future<void> _handleSaveToHistory(Diagnosis diagnosis) async {
    if (_isSaved || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(diagnosisRepositoryProvider).save(diagnosis);
      if (mounted) {
        setState(() {
          _isSaved = true;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to history'),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save to history'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _navigateToCapture() {
    context.go('/diagnose/capture');
  }

  @override
  Widget build(BuildContext context) {
    final diagnosis = _resolveDiagnosis();
    final isHealthy = diagnosis.predictedClass == DiseaseClass.healthy ||
        diagnosis.diseaseInfo.isHealthy;
    final isLowConfidence =
        !isHealthy && diagnosis.confidence < kConfidenceThreshold;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          tooltip: 'Back to capture',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              _navigateToCapture();
            }
          },
        ),
        title: const Text(
          'Diagnosis Result',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF2E7D32),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    // Sync Status pill banner
                    _buildSyncStatusBanner(diagnosis),
                    const SizedBox(height: AppSpacing.sm),

                    // Low Confidence Warning Card
                    if (isLowConfidence) ...[
                      _buildLowConfidenceWarning(),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Main Header Card (Photo, Name, Ring, Badges)
                    ResultHeaderCard(
                      diagnosis: diagnosis,
                      isLowConfidence: isLowConfidence,
                      isHealthy: isHealthy,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Body content according to the 3 variants
                    if (isLowConfidence)
                      ..._buildLowConfidenceContent(diagnosis)
                    else if (isHealthy)
                      ..._buildHealthyContent(diagnosis)
                    else
                      ..._buildDiseaseFoundContent(diagnosis),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            _buildBottomButtons(
              diagnosis: diagnosis,
              isLowConfidence: isLowConfidence,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusBanner(Diagnosis diagnosis) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mdSm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F4E7),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: Color(0xFF2D6A4F),
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          Expanded(
            child: Text(
              'Saved on this phone, will sync when online',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF1E3A2B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFD0EDD8),
              borderRadius: AppRadius.borderFull,
            ),
            child: const Text(
              'Offline',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D6A4F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowConfidenceWarning() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: const Color(0xFFFDE68A), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.mdSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Low Confidence Detection',
                  style: TextStyle(
                    fontFamily: AppTextStyles.headingFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Not sure about this one. Retake the photo in daylight with one leaf in focus.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFFB45309),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDiseaseFoundContent(Diagnosis diagnosis) {
    final info = diagnosis.diseaseInfo;
    return [
      // What it is card
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'What it is',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              info.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),

      // Recommended action card
      ActionStepsCard(steps: info.recommendedActionSteps),
      const SizedBox(height: AppSpacing.md),

      // Prevention card
      PreventionCard(preventionTips: info.preventionTips),
    ];
  }

  List<Widget> _buildLowConfidenceContent(Diagnosis diagnosis) {
    return [
      // Candidate matches container
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: const Icon(
                    Icons.dashboard_customize_outlined,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Candidate matches',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${diagnosis.topMatches.length} possibilities',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (int i = 0; i < diagnosis.topMatches.length; i++) ...[
              CandidateMatchTile(match: diagnosis.topMatches[i]),
              if (i < diagnosis.topMatches.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),

      // Tips for better capture
      const CaptureTipsCard(),
    ];
  }

  List<Widget> _buildHealthyContent(Diagnosis diagnosis) {
    return [
      // Looking good card
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: const Icon(
                    Icons.sentiment_very_satisfied_rounded,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Looking good',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your ${diagnosis.cropType.toLowerCase()} plant shows no signs of fungal or bacterial infection, with strong chlorophyll density and optimal leaf vigor.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),

      // Keep it healthy maintenance tips
      HealthyTipsCard(tips: diagnosis.diseaseInfo.preventionTips),
    ];
  }

  Widget _buildBottomButtons({
    required Diagnosis diagnosis,
    required bool isLowConfidence,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLowConfidence) ...[
            // Primary: Retake photo
            ElevatedButton.icon(
              onPressed: _navigateToCapture,
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              label: const Text(
                'Retake photo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6F24),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Secondary: Save anyway
            OutlinedButton.icon(
              onPressed: _isSaved ? null : () => _handleSaveToHistory(diagnosis),
              icon: Icon(
                _isSaved ? Icons.check : Icons.bookmark_border_rounded,
                color: _isSaved ? AppColors.textSecondary : AppColors.primaryGreen,
              ),
              label: Text(
                _isSaved ? 'Saved to history' : 'Save anyway',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _isSaved ? AppColors.textSecondary : AppColors.primaryGreen,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Color(0xFFD0EDD8), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
          ] else ...[
            // Primary: Save to history
            ElevatedButton.icon(
              onPressed: _isSaved ? null : () => _handleSaveToHistory(diagnosis),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _isSaved ? Icons.check_circle : Icons.bookmark_border_rounded,
                      color: Colors.white,
                    ),
              label: Text(
                _isSaved ? 'Saved to history' : 'Save to history',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved
                    ? AppColors.textSecondary
                    : const Color(0xFF1E6F24),
                disabledBackgroundColor: const Color(0xFF8E9B90),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Secondary: Scan another leaf
            OutlinedButton.icon(
              onPressed: _navigateToCapture,
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryGreen,
              ),
              label: const Text(
                'Scan another leaf',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Color(0xFFD0EDD8), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
