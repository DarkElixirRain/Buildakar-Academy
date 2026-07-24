import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/screens/instructor/dashboard/dashboard_home.dart';
import 'package:buildacad/screens/instructor/dashboard/instructor_courses_screen.dart';
import 'package:buildacad/screens/instructor/dashboard/instructor_analytics_screen.dart';
import 'package:buildacad/screens/instructor/dashboard/instructor_earnings_screen.dart';
import 'package:buildacad/screens/instructor/dashboard/instructor_settings_screen.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});
  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  int _currentIndex = 0;

  final _screens = [
    const DashboardHomeScreen(),
    const InstructorCoursesScreen(),
    const InstructorAnalyticsScreen(),
    const InstructorEarningsScreen(),
    const InstructorSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          border: Border(top: BorderSide(color: AppColors.border(brightness))),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.dashboard_rounded, label: 'Home', index: 0, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            _NavItem(icon: Icons.menu_book_rounded, label: 'Courses', index: 1, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            _NavItem(icon: Icons.analytics_rounded, label: 'Analytics', index: 2, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Earnings', index: 3, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            _NavItem(icon: Icons.settings_rounded, label: 'Settings', index: 4, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;

  const _NavItem({required this.icon, required this.label, required this.index,
    required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: active ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: AppRadius.chipAll,
            ),
            child: Icon(icon, size: 22, color: active ? AppColors.primary : AppColors.outline(Theme.of(context).brightness)),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.labelCaps.copyWith(
            color: active ? AppColors.primary : AppColors.outline(Theme.of(context).brightness),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          )),
        ],
      ),
    );
  }
}
