import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Navigation bar item definition for [AppBottomNav].
class _BottomNavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _BottomNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

/// Bottom navigation bar for AgroVision.
///
/// Contains 4 main tabs (Home, Planner, History, Alerts) and a raised round
/// Scan button in the center. Active tabs display a small dot underneath.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onScanPressed,
  });

  /// The active index among the 4 tabs (0 = Home, 1 = Planner, 2 = History, 3 = Alerts).
  final int currentIndex;

  /// Callback when one of the 4 tabs is tapped.
  final ValueChanged<int> onTabSelected;

  /// Callback when the center Scan button is tapped.
  final VoidCallback onScanPressed;

  static const List<_BottomNavItem> _items = [
    _BottomNavItem(
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'Home',
    ),
    _BottomNavItem(
      activeIcon: Icons.calendar_month_rounded,
      inactiveIcon: Icons.calendar_month_outlined,
      label: 'Planner',
    ),
    _BottomNavItem(
      activeIcon: Icons.history_rounded,
      inactiveIcon: Icons.history_outlined,
      label: 'History',
    ),
    _BottomNavItem(
      activeIcon: Icons.notifications_rounded,
      inactiveIcon: Icons.notifications_none_outlined,
      label: 'Alerts',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: 64.0,
        child: Row(
          children: [
            // Left tabs: Home (0), Planner (1)
            Expanded(child: _buildTabItem(context, index: 0)),
            Expanded(child: _buildTabItem(context, index: 1)),

            // Center raised round Scan button
            _buildCenterScanButton(context),

            // Right tabs: History (2), Alerts (3)
            Expanded(child: _buildTabItem(context, index: 2)),
            Expanded(child: _buildTabItem(context, index: 3)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, {required int index}) {
    final item = _items[index];
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryGreen : AppColors.textSecondary;

    return Semantics(
      label: '${item.label} tab',
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () => onTabSelected(index),
        splashColor: AppColors.primaryGreen.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.inactiveIcon,
                size: 24.0,
                color: color,
              ),
              const SizedBox(height: AppSpacing.xxs),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              // Small dot under the active tab
              Container(
                width: 4.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterScanButton(BuildContext context) {
    return Semantics(
      label: 'Scan crop for diagnosis',
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: SizedBox(
          width: 56.0,
          height: 56.0,
          child: Center(
            child: Material(
              color: AppColors.primaryGreen,
              shape: const CircleBorder(),
              elevation: 3.0,
              shadowColor: AppColors.primaryGreen.withValues(alpha: 0.4),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onScanPressed,
                child: const SizedBox(
                  width: 52.0,
                  height: 52.0,
                  child: Center(
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 26.0,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
