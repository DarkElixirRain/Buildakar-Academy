// lib/widgets/bottom_navigation/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem>? items;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme state from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenWidth < 400;

    // Responsive sizing
    final double iconSize = isSmallScreen ? 20 : (isTablet ? 24 : 22);
    final double fontSize = isSmallScreen ? 9 : (isTablet ? 11 : 10);
    final double bottomPadding = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom
        : 8;
    final double navHeight = isSmallScreen ? 50 : (isTablet ? 60 : 54);

    // Navigation items (use provided or defaults)
    final List<NavItem> navItems = widget.items ?? [
      NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        isActive: widget.currentIndex == 0,
      ),
      NavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: 'Explore',
        isActive: widget.currentIndex == 1,
      ),
      NavItem(
        icon: Icons.ondemand_video_outlined,
        activeIcon: Icons.ondemand_video_rounded,
        label: 'Live',
        isActive: widget.currentIndex == 2,
        showLiveIndicator: true,
      ),
      NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
        isActive: widget.currentIndex == 3,
      ),
      NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'Settings',
        isActive: widget.currentIndex == 4,
      ),
    ];

    // Get colors based on theme
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: isDark 
                ? AppColors.darkBackgroundElement 
                : AppColors.lightBackgroundElement,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.08),
            offset: const Offset(0, -3),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: navHeight + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildNavItem(
                context,
                item,
                index,
                iconSize,
                fontSize,
                isDark,
                brightness,
                isTablet,
                isSmallScreen,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    int index,
    double iconSize,
    double fontSize,
    bool isDark,
    Brightness brightness,
    bool isTablet,
    bool isSmallScreen,
  ) {
    final isActive = item.isActive;
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final inactiveColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap(index);
          _animationController.forward(from: 0.0);
        },
        child: SizedBox(
          height: isSmallScreen ? 48 : (isTablet ? 56 : 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animated background
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(isActive ? (isSmallScreen ? 4 : 6) : 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main Icon with animation
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        key: ValueKey(isActive),
                        size: iconSize,
                        color: isActive ? primaryColor : inactiveColor,
                      ),
                    ),
                    // Live indicator dot on the icon
                    if (item.showLiveIndicator)
                      Positioned(
                        top: -2,
                        right: -4,
                        child: Container(
                          width: isSmallScreen ? 6 : 8,
                          height: isSmallScreen ? 6 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                            border: Border.all(
                              color: backgroundColor,
                              width: 1.5,
                            ),
                          ),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1500),
                            builder: (context, value, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withValues(
                                    alpha: 0.3 * (1 - value),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(
                                        alpha: 0.2 * (1 - value),
                                      ),
                                      spreadRadius: 2 * value,
                                      blurRadius: 4 * value,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? primaryColor : inactiveColor,
                  letterSpacing: isActive ? 0.3 : 0.0,
                ),
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool showLiveIndicator;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isActive = false,
    this.showLiveIndicator = false,
  });
}