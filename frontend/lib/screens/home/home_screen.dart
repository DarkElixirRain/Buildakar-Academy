import 'package:flutter/material.dart' hide SearchBar;
import 'package:google_fonts/google_fonts.dart';
import 'package:buildacad/screens/course/course_detail/course_detail_screen.dart';
import 'package:buildacad/screens/instructor/instructor_screen.dart';
import 'package:provider/provider.dart';
import 'package:buildacad/screens/live/live_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/home/continue_learning.dart';
import '../../widgets/home/featured_course.dart';
import '../../widgets/home/categories.dart';
import '../../widgets/home/recommended_courses.dart';
import '../../widgets/home/popular_courses.dart';
import '../../widgets/home/live_classes.dart';
import '../../widgets/home/top_instructors.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/bottom_navigation/bottom_nav_bar.dart';
import '../../theme/stitch_colors.dart';
import '../../theme/stitch_theme.dart';
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../category/category_detail_screen.dart';
import '../../models/live_class_model.dart';
import '../settings/settings_screen.dart';
import '../instructor-dashboard/instructor_dashboard_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  late List<Widget> _screens;
  late List<StitchNavItem> _navItems;
  bool _isInstructor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreens();
    });
  }

  void _initializeScreens() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final role = user?.role.toLowerCase();
    _isInstructor = role == 'instructor' || role == 'admin';

    if (_isInstructor) {
      _screens = [
        const HomeContent(),
        const ExploreScreen(),
        const LiveScreen(),
        const InstructorDashboardScreen(),
        const SettingsScreen(),
      ];
      _navItems = [
        const StitchNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
        const StitchNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore'),
        const StitchNavItem(icon: Icons.ondemand_video_outlined, activeIcon: Icons.ondemand_video_rounded, label: 'Live', showLiveIndicator: true),
        const StitchNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
        const StitchNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
      ];
    } else {
      _screens = [
        const HomeContent(),
        const ExploreScreen(),
        const LiveScreen(),
        const SettingsScreen(),
      ];
      _navItems = [
        const StitchNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
        const StitchNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore'),
        const StitchNavItem(icon: Icons.ondemand_video_outlined, activeIcon: Icons.ondemand_video_rounded, label: 'Live', showLiveIndicator: true),
        const StitchNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
      ];
    }
  }

  void _onTabTapped(int index) {
    setState(() { _currentTabIndex = index; });
  }

  void _handleSearch(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen(initialQuery: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeScreens();

    return MainLayout(
      currentIndex: _currentTabIndex,
      onTabChanged: _onTabTapped,
      onSearchSubmitted: _handleSearch,
      navItems: _navItems,
      child: _screens[_currentTabIndex],
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isRefreshing = false;
  String? _error;

  List<Map<String, dynamic>> _continueLearning = [];
  List<Map<String, dynamic>> _liveClasses = [];
  List<Map<String, dynamic>> _topInstructors = [];
  List<Map<String, dynamic>> _featuredCourses = [];
  List<Map<String, dynamic>> _recommendedCourses = [];
  List<Map<String, dynamic>> _popularCourses = [];

  final ApiService _apiService = ApiService();
  bool _isStudent = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      searchProvider.clearResults();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.user != null) {
      _isStudent = authProvider.user?.role.toLowerCase() == 'student';
    }
  }

  Future<void> _loadHomeData() async {
    if (!mounted) return;
    setState(() { _error = null; });

    try {
      final results = await Future.wait([
        _apiService.getTopInstructors(limit: 10),
        _apiService.getPopularCourses(limit: 10, page: 1, timeRange: 'week'),
        _apiService.getFeaturedCourses(limit: 5),
        _apiService.getRecommendedCourses(limit: 10),
        _apiService.getContinueLearning(limit: 5),
      ]);

      if (!mounted) return;

      final instructorResponse = results[0] as ApiResponse<List<Map<String, dynamic>>>;
      final popularResponse = results[1] as ApiResponse<Map<String, dynamic>>;
      final featuredResponse = results[2] as ApiResponse<List<Map<String, dynamic>>>;
      final recommendedResponse = results[3] as ApiResponse<List<Map<String, dynamic>>>;
      final continueLearningResponse = results[4] as ApiResponse<List<Map<String, dynamic>>>;

      if (instructorResponse.success && instructorResponse.data != null) {
        _topInstructors = instructorResponse.data!;
      }
      if (popularResponse.success && popularResponse.data != null) {
        final popularData = popularResponse.data!;
        _popularCourses = popularData['data'] is List
            ? List<Map<String, dynamic>>.from(popularData['data'])
            : [];
      }
      if (featuredResponse.success && featuredResponse.data != null) {
        _featuredCourses = featuredResponse.data!;
      }
      if (recommendedResponse.success && recommendedResponse.data != null) {
        _recommendedCourses = recommendedResponse.data!;
      }
      if (continueLearningResponse.success && continueLearningResponse.data != null) {
        _continueLearning = continueLearningResponse.data!;
      }

      final liveResponse = await _apiService.getAllStudentLiveClasses();
      if (liveResponse.success && liveResponse.data != null) {
        final liveData = liveResponse.data!;
        final liveList = (liveData['live'] as List<LiveClass>?) ?? [];
        final upcomingList = (liveData['upcoming'] as List<LiveClass>?) ?? [];
        final allList = [...liveList, ...upcomingList];
        _liveClasses = allList.map((lc) => _liveClassToWidgetMap(lc)).toList();
      }

      if (mounted) setState(() { _error = null; });
    } catch (e) {
      if (!mounted) return;
      _topInstructors = [];
      _popularCourses = [];
      _featuredCourses = [];
      _recommendedCourses = [];
      _continueLearning = [];
      _liveClasses = [];
      if (mounted) setState(() { _error = 'Failed to load some data.'; });
    }
  }

  Future<void> _refreshData() async {
    setState(() { _isRefreshing = true; });
    await _loadHomeData();
    if (mounted) setState(() { _isRefreshing = false; });
  }

  void _handleCoursePress(String courseId) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseId: courseId, isAuthenticated: _isStudent),
      ),
    );
  }

  void _navigateWithMinimalCourse(Map<String, dynamic> course) {
    final courseId = course['courseId'] ?? course['id'] ?? '';
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseId: courseId, isAuthenticated: _isStudent),
      ),
    );
  }

  void _handleCategoryPress(String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(
          categoryId: categoryId, categorySlug: categoryId, categoryName: 'Category',
        ),
      ),
    );
  }

  void _handleSeeAll(String section) {
    switch (section) {
      case 'continue-learning':
      case 'my-learning':
        Navigator.pushNamed(context, '/my-learning');
        break;
      case 'recommended':
      case 'popular':
      case 'featured':
        _switchToTab(1);
        break;
      case 'live':
        _switchToTab(2);
        break;
      case 'instructors':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const InstructorsScreen()));
        break;
      case 'categories':
        Navigator.pushNamed(context, '/categories');
        break;
      default:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Coming Soon!'),
            content: Text('The "$section" section will be available soon.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
    }
  }

  void _switchToTab(int index) {
    final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
    homeScreenState?._onTabTapped(index);
  }

  void _handleLiveClassJoin(String classId) {
    Navigator.pushNamed(context, '/live-class', arguments: {'classId': classId});
  }

  void _handleInstructorFollow(String instructorId) {
    setState(() {
      final index = _topInstructors.indexWhere(
        (e) => e['id'] == instructorId || e['instructorId'] == instructorId,
      );
      if (index != -1) {
        final currentStatus = _topInstructors[index]['isFollowing'] ?? false;
        _topInstructors[index]['isFollowing'] = !currentStatus;
      }
    });
  }

  void _handleInstructorPress(String instructorId) {
    Navigator.pushNamed(context, '/instructor', arguments: {'instructorId': instructorId});
  }

  Map<String, dynamic> _liveClassToWidgetMap(LiveClass lc) {
    return {
      'id': lc.id,
      'title': lc.title,
      'instructor': lc.instructor,
      'instructorId': lc.instructorId,
      'instructorAvatar': lc.instructorAvatar,
      'image': lc.thumbnail,
      'thumbnail': lc.thumbnail,
      'category': lc.category,
      'status': lc.status,
      'isLive': lc.status == 'live',
      'attendees': lc.participantsCount,
      'participantsCount': lc.participantsCount,
      'maxParticipants': lc.maxParticipants,
      'description': lc.description,
      'scheduledTime': lc.scheduledTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (_error != null && _topInstructors.isEmpty && _continueLearning.isEmpty) {
      return ErrorState(message: _error!, onRetry: () {
        setState(() => _error = null);
        _loadHomeData();
      });
    }

    return Container(
      color: StitchColors.surface(brightness),
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: StitchColors.primary(brightness),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              ContinueLearning(onCoursePress: _handleCoursePress, limit: 5),
              const SizedBox(height: 24),

              if (_featuredCourses.isNotEmpty) ...[
                FeaturedCourses(onCoursePress: _handleCoursePress, onSeeAll: () => _handleSeeAll('featured')),
                const SizedBox(height: 24),
              ],

              Categories(onCategoryPress: _handleCategoryPress, onSeeAll: () => _handleSeeAll('categories')),
              const SizedBox(height: 24),

              if (_recommendedCourses.isNotEmpty) ...[
                RecommendedCourses(onCoursePress: _handleCoursePress, onSeeAll: () => _handleSeeAll('recommended')),
                const SizedBox(height: 24),
              ],

              if (_popularCourses.isNotEmpty) ...[
                PopularCourses(onCoursePress: _handleCoursePress, onSeeAll: () => _handleSeeAll('popular'), limit: 10),
                const SizedBox(height: 24),
              ],

              if (_liveClasses.isNotEmpty) ...[
                LiveClasses(
                  classes: _liveClasses,
                  onJoinPress: _handleLiveClassJoin,
                  onSeeAll: () => _handleSeeAll('live'),
                  currentUserId: context.read<AuthProvider>().user?.id,
                  onEndPress: (classId) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('End Live Class'),
                        content: const Text('Are you sure you want to end this live class?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('End', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _apiService.endLiveClass(classId);
                      _loadHomeData();
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],

              if (_topInstructors.isNotEmpty) ...[
                TopInstructors(
                  instructors: _topInstructors,
                  onFollowPress: _handleInstructorFollow,
                  onInstructorPress: _handleInstructorPress,
                  onSeeAll: () => _handleSeeAll('instructors'),
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
