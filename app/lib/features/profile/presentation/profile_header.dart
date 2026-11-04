import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Header card for [ProfileScreen] showing farmer avatar, name, email,
/// specialization badge, season chip, and an Edit button.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.name = 'Nimal Perera',
    this.email = 'nimal.kurunegala@agrovision.lk',
    this.role = 'Nightshade Specialist',
    this.season = "Maha '24",
    this.avatarUrl,
    this.onEdit,
  });

  final String name;
  final String email;
  final String role;
  final String season;
  final String? avatarUrl;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular avatar with green border and active indicator dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer.withOpacity(0.35),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            avatarUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 38,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 38,
                          color: AppColors.primary,
                        ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // User info details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Edit profile',
                      child: InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 36,
                          ),
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xs,
                            ),
                            child: Text(
                              'Edit',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            role,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      season,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

