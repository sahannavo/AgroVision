import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/data/providers.dart';

/// Splash screen shown at app launch.
///
/// Displays the AgroVision logo, wordmark, and tagline with a thin animated
/// progress bar. After 2.2 s it checks [authStateProvider] and routes to
/// /home (signed in) or /login (signed out).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    Future.delayed(const Duration(milliseconds: 2200), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    final hasUser = authState.valueOrNull != null;
    if (hasUser) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // ── Logo mark ───────────────────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: AppRadius.borderLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.energy_savings_leaf_rounded,
                  color: AppColors.textOnPrimary,
                  size: 48,
                  semanticLabel: 'AgroVision leaf logo',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Wordmark ────────────────────────────────────────────────
              Text(
                'AgroVision',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // ── Tagline ─────────────────────────────────────────────────
              Text(
                'Smart Crop Care for Sri Lankan Farmers',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              // ── Thin progress bar ────────────────────────────────────────
              AnimatedBuilder(
                animation: _progressCtrl,
                builder: (context, _) {
                  return ClipRRect(
                    borderRadius: AppRadius.borderFull,
                    child: LinearProgressIndicator(
                      value: _progressCtrl.value,
                      minHeight: 3,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'SRI LANKA · SE205.3',
                style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
