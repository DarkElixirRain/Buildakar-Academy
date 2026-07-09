// lib/widgets/live/live_widgets.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class LiveColors {
  static Color surface(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF1C1F26) : Colors.white;

  static Color background(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF121417) : const Color(0xFFF7F8FA);

  static Color border(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF2A2E37) : const Color(0xFFE7E9EC);

  static const Color live = Color(0xFFE11D48);
}

/// ---------------------------------------------------------------------
/// Search bar for live classes.
/// ---------------------------------------------------------------------
class LiveSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const LiveSearchBar({Key? key, required this.controller, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      height: isSmallScreen ? 44 : 52,
      decoration: BoxDecoration(
        color: LiveColors.surface(brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LiveColors.border(brightness)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: isSmallScreen ? 13 : 15,
          color: textColor,
        ),
        cursorColor: primaryColor,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: isSmallScreen ? 'Search...' : 'Search live classes, instructors...',
          hintStyle: GoogleFonts.inter(
            fontSize: isSmallScreen ? 13 : 15,
            color: textSecondaryColor,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: textSecondaryColor,
            size: isSmallScreen ? 18 : 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: textSecondaryColor,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 10 : 14,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Segmented tab selector: Live Now / Upcoming / Past, each with a count.
/// ---------------------------------------------------------------------
class LiveTabSelector extends StatelessWidget {
  final List<String> tabs;
  final Map<String, int> counts;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const LiveTabSelector({
    Key? key,
    required this.tabs,
    required this.counts,
    required this.selectedIndex,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LiveColors.background(brightness),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LiveColors.border(brightness)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = i == selectedIndex;
          final label = tabs[i];
          final count = counts[label] ?? 0;
          final isLiveTab = label == 'Live Now';
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 6 : 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? LiveColors.surface(brightness) : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLiveTab) ...[
                      Container(
                        width: isSmallScreen ? 5 : 7,
                        height: isSmallScreen ? 5 : 7,
                        decoration: const BoxDecoration(
                          color: LiveColors.live,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 5),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 10 : 12.5,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? (isLiveTab ? LiveColors.live : primaryColor)
                              : textSecondaryColor,
                        ),
                      ),
                    ),
                    if (count > 0) ...[
                      SizedBox(width: isSmallScreen ? 3 : 5),
                      Text(
                        '$count',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 9 : 11.5,
                          fontWeight: FontWeight.w700,
                          color: selected ? textColor : textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Small "LIVE" badge with a pulsing dot animation.
/// ---------------------------------------------------------------------
class PulsingLiveBadge extends StatefulWidget {
  final double fontSize;
  const PulsingLiveBadge({Key? key, this.fontSize = 11}) : super(key: key);

  @override
  State<PulsingLiveBadge> createState() => _PulsingLiveBadgeState();
}

class _PulsingLiveBadgeState extends State<PulsingLiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: LiveColors.live,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
            child: Container(
              width: isSmallScreen ? 4 : 6,
              height: isSmallScreen ? 4 : 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 3 : 5),
          Text(
            'LIVE',
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? widget.fontSize - 2 : widget.fontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Contextual call-to-action buttons.
/// ---------------------------------------------------------------------
class JoinButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool expand;
  const JoinButton({Key? key, this.onTap, this.expand = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: isSmallScreen ? 34 : 40,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          Icons.play_circle_fill_rounded,
          size: isSmallScreen ? 14 : 18,
        ),
        label: Text(
          'Join Now',
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 11 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: LiveColors.live,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 10 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class ReminderButton extends StatelessWidget {
  final bool isSet;
  final VoidCallback? onTap;
  final bool expand;
  const ReminderButton({
    Key? key,
    required this.isSet,
    this.onTap,
    this.expand = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: isSmallScreen ? 34 : 40,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          isSet ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
          size: isSmallScreen ? 14 : 17,
          color: isSet ? primaryColor : textColor,
        ),
        label: Text(
          isSet ? 'Reminder Set' : 'Set Reminder',
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 11 : 13,
            fontWeight: FontWeight.w700,
            color: isSet ? primaryColor : textColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isSet ? primaryColor : LiveColors.border(brightness)),
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class RecordingButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool expand;
  const RecordingButton({Key? key, this.onTap, this.expand = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final textColor = AppColors.getTextColor(brightness);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: isSmallScreen ? 34 : 40,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          Icons.replay_circle_filled_rounded,
          size: isSmallScreen ? 14 : 18,
          color: textColor,
        ),
        label: Text(
          'Watch Recording',
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 11 : 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: LiveColors.border(brightness)),
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}