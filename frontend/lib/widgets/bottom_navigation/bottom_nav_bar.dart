import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stitch_colors.dart';
import '../../theme/stitch_theme.dart';

class StitchNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool showLiveIndicator;

  const StitchNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isActive = false,
    this.showLiveIndicator = false,
  });
}

class StitchBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<StitchNavItem> items;

  const StitchBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      height: StitchTheme.navBarHeight + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLowest(brightness),
        border: Border(
          top: BorderSide(
            color: StitchColors.border(brightness),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom > 0 ? 0 : 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(index);
                  },
                  child: Container(
                    height: StitchTheme.navBarHeight - 8,
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? StitchColors.primary(brightness).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(StitchTheme.radiusLg),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              size: 22,
                              color: isActive
                                  ? StitchColors.primary(brightness)
                                  : StitchColors.onSurfaceVariant(brightness),
                            ),
                            if (item.showLiveIndicator)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: StitchColors.livePulse,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? StitchColors.primary(brightness)
                                : StitchColors.onSurfaceVariant(brightness),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
