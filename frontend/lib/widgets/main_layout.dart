import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buildacad/screens/notifications/notification_screen.dart';
import '../providers/auth_provider.dart';
import '../theme/stitch_colors.dart';
import '../theme/stitch_theme.dart';
import 'bottom_navigation/bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTabChanged;
  final VoidCallback? onNotificationPress;
  final Function(String)? onSearchSubmitted;
  final List<StitchNavItem>? navItems;

  const MainLayout({
    Key? key,
    required this.child,
    required this.currentIndex,
    required this.onTabChanged,
    this.onNotificationPress,
    this.onSearchSubmitted,
    this.navItems,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final TextEditingController _searchController = TextEditingController();

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty && widget.onSearchSubmitted != null) {
      widget.onSearchSubmitted!(query);
    }
  }

  void _handleNotificationPress() {
    if (widget.onNotificationPress != null) {
      widget.onNotificationPress!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.displayName;

    return Scaffold(
      backgroundColor: StitchColors.surface(brightness),
      body: SafeArea(
        child: Column(
          children: [
            // Stitch Header
            _buildHeader(context, brightness, userName),
            // Search Bar
            _buildSearchBar(context, brightness),
            // Main Content
            Expanded(
              child: widget.child,
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.navItems != null
          ? StitchBottomNav(
              currentIndex: widget.currentIndex,
              onTap: widget.onTabChanged,
              items: widget.navItems!,
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, Brightness brightness, String userName) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: StitchColors.primary(brightness),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: authProvider.profileImage != null
                  ? Image.network(authProvider.profileImage!, fit: BoxFit.cover)
                  : Container(
                      color: StitchColors.primary(brightness).withValues(alpha: 0.1),
                      child: Center(
                        child: Text(
                          authProvider.initials,
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: StitchColors.primary(brightness),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Welcome text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: StitchColors.onSurfaceVariant(brightness),
                  ),
                ),
                Text(
                  userName,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: StitchColors.onSurface(brightness),
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: _handleNotificationPress,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: StitchColors.surfaceContainerLow(brightness),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 22,
                color: StitchColors.onSurface(brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: StitchColors.surfaceContainerLowest(brightness),
          borderRadius: BorderRadius.circular(StitchTheme.radiusMd),
          border: Border.all(
            color: StitchColors.border(brightness),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _handleSearch,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: StitchColors.onSurface(brightness),
          ),
          decoration: InputDecoration(
            hintText: 'Search courses, instructors...',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: StitchColors.onSurfaceVariant(brightness),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 22,
              color: StitchColors.onSurfaceVariant(brightness),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
