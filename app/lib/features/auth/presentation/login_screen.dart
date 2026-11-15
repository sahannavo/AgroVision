import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/providers.dart';
import 'validators.dart';
import 'widgets/auth_header.dart';
import 'widgets/offline_login_banner.dart';
import 'widgets/password_field.dart';

/// Login screen — email + password authentication.
///
/// Shows an [OfflineLoginBanner] when the device is offline.
/// Inline validation and an error container on failed sign-in.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  // Will be driven by ConnectivityService provider once wired by SDL (see NOTES).
  static const bool _isOffline = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection. Login requires connectivity.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              'Incorrect email or password. Please try again.',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              // ── Top bar ─────────────────────────────────────────────────
              Row(
                children: [
                  Semantics(
                    label: 'Go back',
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : null,
                    ),
                  ),
                  const Expanded(
                    child: Text('Login', style: AppTextStyles.headingSmall),
                  ),
                  Semantics(
                    label: 'Profile',
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.textOnPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const AuthHeader(),
              const SizedBox(height: AppSpacing.lg),
              const Text('Welcome back', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Log in to check your crops.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (_isOffline) ...[
                const SizedBox(height: AppSpacing.md),
                const OfflineLoginBanner(),
              ],
              const SizedBox(height: AppSpacing.lg),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    // Email
                    Text(
                      'Email address',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      validator: AuthValidators.email,
                      style: AppTextStyles.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'nimal.perera@agrovision.lk',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Password
                    Text(
                      'Password',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    PasswordField(
                      controller: _passwordCtrl,
                      label: '',
                      validator: AuthValidators.password,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password reset — available in phase 3.',
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Log in button
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _submit,
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
                        label: Text('Log in', style: AppTextStyles.button),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.textOnPrimary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.borderMd,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── OR divider ───────────────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text('OR', style: AppTextStyles.labelSmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // ── Create account link ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to AgroVision? ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      'Create account',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
