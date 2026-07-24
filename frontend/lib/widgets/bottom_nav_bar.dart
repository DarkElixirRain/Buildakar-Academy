import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore'),
      _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search, label: 'Search'),
      _NavItem(icon: Icons.person_outlined, activeIcon: Icons.person, label: 'Profile'),
    ];

    return Container(
      height: AppSpacing.navBarHeight,
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        border: Border(
          top: BorderSide(color: AppColors.border(brightness), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final active = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: active
                    ? BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.mdAll,
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      active ? items[i].activeIcon : items[i].icon,
                      size: 24,
                      color: active
                          ? AppColors.onPrimaryContainer
                          : AppColors.outline(brightness),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].label,
                      style: AppTypography.labelCaps.copyWith(
                        color: active
                            ? AppColors.onPrimaryContainer
                            : AppColors.outline(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}
