import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/providers/auth_provider.dart';
import 'package:buildacad/widgets/home/home_header.dart';
import 'package:buildacad/widgets/home/continue_learning.dart';
import 'package:buildacad/widgets/home/categories.dart';
import 'package:buildacad/widgets/home/live_classes.dart';
import 'package:buildacad/widgets/home/popular_courses.dart';
import 'package:buildacad/widgets/home/top_instructors.dart';
import 'package:buildacad/screens/home/explore_screen.dart';
import 'package:buildacad/screens/home/search_screen.dart';
import 'package:buildacad/screens/settings/settings_screen.dart';
import 'package:buildacad/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final auth = context.watch<AuthProvider>();

    final tabs = [
      _HomeTab(userName: auth.displayName),
      const ExploreScreen(),
      const SearchScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String userName;
  const _HomeTab({required this.userName});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HomeHeader(userName: userName)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(child: _SearchBarWidget()),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
          sliver: SliverToBoxAdapter(child: ContinueLearning()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          sliver: SliverToBoxAdapter(child: CategoriesSection()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          sliver: SliverToBoxAdapter(child: LiveClassesSection()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          sliver: SliverToBoxAdapter(child: PopularCoursesSection()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
          sliver: SliverToBoxAdapter(child: TopInstructorsSection()),
        ),
      ],
    );
  }
}

class _SearchBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: () {
        // Navigate to search tab via the parent HomeScreen
        final homeState = context.findAncestorStateOfType<State>();
        if (homeState != null && homeState is HomeScreen) {
          // Can't directly access, so just navigate
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest(brightness),
          borderRadius: AppRadius.inputAll,
          border: Border.all(color: AppColors.border(brightness)),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.outline(brightness), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Search courses, instructors...',
                style: AppTypography.bodyMd.copyWith(color: AppColors.outline(brightness)),
              ),
            ),
            Icon(Icons.tune, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
