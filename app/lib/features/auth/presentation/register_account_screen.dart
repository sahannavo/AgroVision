import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'validators.dart';
import 'widgets/password_field.dart';
import 'widgets/strength_meter.dart';

/// Data passed from RegisterAccountScreen to RegisterFarmScreen.
class AccountRegistrationArgs {
  const AccountRegistrationArgs({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final String password;
}

/// Registration Step 1 — personal details.
///
/// Collects full name, email, password, confirm password and a terms checkbox.
/// On "Continue" pushes /register/farm with [AccountRegistrationArgs] as extra.
class RegisterAccountScreen extends ConsumerStatefulWidget {
  const RegisterAccountScreen({super.key});

  @override
  ConsumerState<RegisterAccountScreen> createState() =>
      _RegisterAccountScreenState();
}

class _RegisterAccountScreenState
    extends ConsumerState<RegisterAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _termsAccepted = false;
  String _passwordValue = '';

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(
      () => setState(() => _passwordValue = _passwordCtrl.text),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions to continue.'),
        ),
      );
      return;
    }
    context.push(
      '/register/farm',
      extra: AccountRegistrationArgs(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
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
                  const Expanded(
                    child: Text(
                      'Create Account',
                      style: AppTextStyles.headingSmall,
                    ),
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
            ),
            // ── Step progress bar ────────────────────────────────────────
            _StepProgressBar(step: 1),
            // ── Scrollable form ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Text(
                          '1. Account & Identity',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '2. Farm & Nightshades',
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Create Farmer Account',
                      style: AppTextStyles.headingLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Empower your harvest with localized disease alerts, '
                      'zero-data AI plant diagnosis, and Sri Lankan '
                      'agro-climatic advisories.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full Name
                          TextFormField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            validator: AuthValidators.fullName,
                            style: AppTextStyles.bodyMedium,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.badge_outlined),
                              hintText: 'Nimal Perera',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            validator: AuthValidators.email,
                            style: AppTextStyles.bodyMedium,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Password
                          PasswordField(
                            controller: _passwordCtrl,
                            label: 'Password',
                            validator: AuthValidators.password,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          StrengthMeter(password: _passwordValue),
                          const SizedBox(height: AppSpacing.md),
                          // Confirm password
                          PasswordField(
                            controller: _confirmCtrl,
                            label: 'Confirm Password',
                            validator: (v) => AuthValidators.confirmPassword(
                              v,
                              _passwordCtrl.text,
                            ),
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Terms checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _termsAccepted,
                                  activeColor: AppColors.primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.borderXs,
                                  ),
                                  onChanged: (v) => setState(
                                    () => _termsAccepted = v ?? false,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'I agree to Agricultural Extension Data '
                                  'sharing under the Department of Agriculture '
                                  '(DOA) Sri Lanka guidelines for '
                                  'epidemiological disease tracking.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Continue button
                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _onContinue,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(
                                'Continue to Step 2: Farm Details',
                                style: AppTextStyles.button,
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: AppColors.textOnPrimary,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.borderMd,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Already registered
                          Center(
                            child: GestureDetector(
                              onTap: () => context.go('/login'),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Already registered? ',
                                    ),
                                    TextSpan(
                                      text: 'Log in',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            AppColors.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step progress bar widget ───────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pct = step == 1 ? 0.5 : 1.0;
    final label = step == 1 ? 'Account Info' : 'Farm Details';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  'Step $step of 2: $label',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).toInt()}% Complete',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: pct,
          minHeight: 4,
          backgroundColor: AppColors.divider,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
        ),
      ],
    );
  }
}
