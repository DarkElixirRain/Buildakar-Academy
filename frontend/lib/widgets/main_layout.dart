// lib/widgets/main_layout.dart

import 'package:flutter/material.dart';
import 'package:buildacad/widgets/home/home_header.dart';
import '../constants/colors.dart';
import '../screens/notifications/notification_screen.dart';
import '../widgets/bottom_navigation/bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTabChanged;
  final VoidCallback? onNotificationPress;
  final Function(String)? onSearchSubmitted;
  final List<NavItem>? navItems;

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
  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      if (widget.onSearchSubmitted != null) {
        widget.onSearchSubmitted!(query);
      } else {
        // Default search handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Searching for: $query')),
        );
      }
    }
  }

  void _handleNotificationPress() {
    if (widget.onNotificationPress != null) {
      widget.onNotificationPress!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(brightness),
      body: SafeArea(
        child: Column(
          children: [
            // Header - notificationCount removed because HomeHeader fetches it internally
            HomeHeader(
              onNotificationPress: _handleNotificationPress,
              onSearchSubmitted: _handleSearch,
              onProfilePress: () {
                // Handle profile press
                // You can navigate to profile screen here
              },
            ),
            
            // Main Content
            Expanded(
              child: widget.child,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTabChanged,
        items: widget.navItems,
      ),
    );
  }
}