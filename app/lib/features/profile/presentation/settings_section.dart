import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Settings card on [ProfileScreen] showing notifications toggle,
/// language preference, and offline data sync status.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    this.notificationsEnabled = true,
    this.onNotificationsChanged,
    this.onLanguageTap,
    this.onOfflineDataTap,
  });

  final bool notificationsEnabled;
  final ValueChanged<bool>? onNotificationsChanged;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onOfflineDataTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section Header
        Text(
          'Settings',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Settings Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.outline.withOpacity(0.6),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Row 1: Notifications
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'District outbreak alerts',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      label: 'Toggle district outbreak notifications',
                      child: Switch.adaptive(
                        value: notificationsEnabled,
                        activeColor: AppColors.primary,
                        activeTrackColor: AppColors.primaryContainer,
                        onChanged: onNotificationsChanged,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: AppColors.outline.withOpacity(0.4),
                height: 1,
              ),
              // Row 2: Language
              InkWell(
                onTap: onLanguageTap,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.language_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Language',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'UI & Diagnostic advisory',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'English',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '(සිංහල / தமிழ்)',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: AppColors.outline.withOpacity(0.4),
                height: 1,
              ),
              // Row 3: Offline data
              InkWell(
                onTap: onOfflineDataTap,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F5FE),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.cloud_sync_outlined,
                          size: 18,
                          color: Color(0xFF0288D1),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offline data',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Synced 12m ago · 42 MB local model',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Ready',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

