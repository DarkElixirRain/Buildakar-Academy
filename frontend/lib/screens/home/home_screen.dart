// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart' hide SearchBar;
import 'package:google_fonts/google_fonts.dart';
import 'package:buildacad/screens/course/course_detail/course_detail_screen.dart';
import 'package:buildacad/screens/instructor/instructor_screen.dart';
import 'package:provider/provider.dart';
import 'package:buildacad/screens/live/live_screen.dart';
import '../../constants/colors.dart';
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
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../category/category_detail_screen.dart';
import '../../models/live_class_model.dart';
// Import the SettingsScreen
import '../settings/settings_screen.dart';
// Import the Instructor Dashboard
import '../instructor-dashboard/instructor_dashboard_screens.dart';
// Import NavItem
import '../../widgets/bottom_navigation/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  late List<Widget> _screens;
  late List<NavItem> _navItems;
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
        NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', isActive: _currentTabIndex == 0),
        NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore', isActive: _currentTabIndex == 1),
        NavItem(icon: Icons.ondemand_video_outlined, activeIcon: Icons.ondemand_video_rounded, label: 'Live', isActive: _currentTabIndex == 2, showLiveIndicator: true),
        NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard', isActive: _currentTabIndex == 3),
        NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings', isActive: _currentTabIndex == 4),
      ];
    } else {
      _screens = [
        const HomeContent(),
        const ExploreScreen(),
        const LiveScreen(),
        const SettingsScreen(),
      ];
      _navItems = [
        NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', isActive: _currentTabIndex == 0),
        NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore', isActive: _currentTabIndex == 1),
        NavItem(icon: Icons.ondemand_video_outlined, activeIcon: Icons.ondemand_video_rounded, label: 'Live', isActive: _currentTabIndex == 2, showLiveIndicator: true),
        NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings', isActive: _currentTabIndex == 3),
      ];
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _handleSearch(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(initialQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    // Get theme-aware background color
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    
    // Re-initialize screens when user changes
    _initializeScreens();
    
    return Container(
      color: backgroundColor,
      child: MainLayout(
        currentIndex: _currentTabIndex,
        onTabChanged: _onTabTapped,
        onSearchSubmitted: _handleSearch,
        navItems: _navItems,
        child: _screens[_currentTabIndex],
      ),
    );
  }
}

// ============================================
// HOME CONTENT
// ============================================

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

    setState(() {
      _error = null;
    });

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
        print('✅ Loaded ${_topInstructors.length} instructors from API');
      } else {
        _topInstructors = <Map<String, dynamic>>[];
        if (instructorResponse.error != null) {
          print('⚠️ Failed to load instructors: ${instructorResponse.error}');
        }
      }

      if (popularResponse.success && popularResponse.data != null) {
        final popularData = popularResponse.data!;
        if (popularData['data'] is List) {
          _popularCourses = List<Map<String, dynamic>>.from(popularData['data'] ?? []);
        } else {
          _popularCourses = [];
        }
        print('✅ Loaded ${_popularCourses.length} popular courses from API');
      } else {
        _popularCourses = <Map<String, dynamic>>[];
        if (popularResponse.error != null) {
          print('⚠️ Failed to load popular courses: ${popularResponse.error}');
        }
      }

      if (featuredResponse.success && featuredResponse.data != null) {
        _featuredCourses = featuredResponse.data!;
        print('✅ Loaded ${_featuredCourses.length} featured courses from API');
      } else {
        _featuredCourses = <Map<String, dynamic>>[];
        if (featuredResponse.error != null) {
          print('⚠️ Failed to load featured courses: ${featuredResponse.error}');
        }
      }

      if (recommendedResponse.success && recommendedResponse.data != null) {
        _recommendedCourses = recommendedResponse.data!;
        print('✅ Loaded ${_recommendedCourses.length} recommended courses from API');
      } else {
        _recommendedCourses = <Map<String, dynamic>>[];
        if (recommendedResponse.error != null) {
          print('⚠️ Failed to load recommended courses: ${recommendedResponse.error}');
        }
      }

      if (continueLearningResponse.success && continueLearningResponse.data != null) {
        _continueLearning = continueLearningResponse.data!;
        print('✅ Loaded ${_continueLearning.length} continue learning courses from API');
      } else {
        _continueLearning = <Map<String, dynamic>>[];
        if (continueLearningResponse.error != null) {
          print('⚠️ Failed to load continue learning: ${continueLearningResponse.error}');
        }
      }

      final liveResponse = await _apiService.getAllStudentLiveClasses();
      if (liveResponse.success && liveResponse.data != null) {
        final liveData = liveResponse.data!;
        final liveList = (liveData['live'] as List<LiveClass>?) ?? [];
        final upcomingList = (liveData['upcoming'] as List<LiveClass>?) ?? [];
        final allList = [...liveList, ...upcomingList];
        _liveClasses = allList.map((lc) => _liveClassToWidgetMap(lc)).toList();
        print('✅ Loaded ${_liveClasses.length} live classes from API');
      } else {
        _liveClasses = <Map<String, dynamic>>[];
        if (liveResponse.error != null) {
          print('⚠️ Failed to load live classes: ${liveResponse.error}');
        }
      }

      setState(() {
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      
      _topInstructors = <Map<String, dynamic>>[];
      _popularCourses = <Map<String, dynamic>>[];
      _featuredCourses = <Map<String, dynamic>>[];
      _recommendedCourses = <Map<String, dynamic>>[];
      _continueLearning = <Map<String, dynamic>>[];
      _liveClasses = <Map<String, dynamic>>[];
      
      setState(() {
        _error = 'Failed to load some data. Showing cached content.';
      });
      print('❌ Error loading home data: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadHomeData();
    
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _handleCoursePress(String courseId) {
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          courseId: courseId,
          isAuthenticated: _isStudent,
        ),
      ),
    );
  }

  void _navigateWithMinimalCourse(Map<String, dynamic> course) {
    final courseId = course['courseId'] ?? course['id'] ?? '';
    
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          courseId: courseId,
          isAuthenticated: _isStudent,
        ),
      ),
    );
  }

  void _handleCategoryPress(String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(
          categoryId: categoryId,
          categorySlug: categoryId,
          categoryName: 'Category',
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
        _switchToTab(1);
        break;
      case 'popular':
        _switchToTab(1);
        break;
      case 'featured':
        _switchToTab(1);
        break;
      case 'live':
        _switchToTab(2);
        break;
      case 'instructors':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InstructorsScreen(),
          ),
        );
        break;
      case 'categories':
        Navigator.pushNamed(context, '/categories');
        break;
      default:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Coming Soon!'),
            content: Text(
              'The "$section" section will be available soon.\nStay tuned for updates!',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    }
  }

  void _switchToTab(int index) {
    final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeScreenState != null) {
      homeScreenState._onTabTapped(index);
    }
  }

  void _handleLiveClassJoin(String classId) {
    Navigator.pushNamed(
      context,
      '/live-class',
      arguments: {'classId': classId},
    );
  }

  // FIXED: Properly defined method with currentStatus variable
 // lib/screens/home/home_screen.dart

// FIXED: Properly defined method with currentStatus variable
void _handleInstructorFollow(String instructorId) {
  print('🔄 HomeContent: _handleInstructorFollow called for $instructorId');
  
  // Update the local instructors list
  setState(() {
    final index = _topInstructors.indexWhere((e) => e['id'] == instructorId || e['instructorId'] == instructorId);
    if (index != -1) {
      // Get the current status from the instructor object
      final bool currentStatus = _topInstructors[index]['isFollowing'] ?? false;
      // Toggle it
      _topInstructors[index]['isFollowing'] = !currentStatus;
      print('✅ Updated _topInstructors at index $index to ${!currentStatus}');
    } else {
      print('⚠️ Instructor not found in _topInstructors list');
    }
  });
}

  void _handleInstructorPress(String instructorId) {
    Navigator.pushNamed(
      context,
      '/instructor',
      arguments: {'instructorId': instructorId},
    );
  }

  Map<String, dynamic> _liveClassToWidgetMap(LiveClass lc) {
    final isLive = lc.status == 'live';
    final scheduled = lc.scheduledTime;
    return {
      'id': lc.id,
      'title': lc.title,
      'instructor': lc.instructor,
      'image': lc.thumbnail,
      'category': lc.category,
      'isLive': isLive,
      'attendees': lc.participantsCount,
      'date': '${scheduled.month}/${scheduled.day}/${scheduled.year}',
      'time': '${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}',
    };
  }

  bool _hasContinueLearningData() {
    return _continueLearning.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    // Get theme-aware colors
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final errorColor = AppColors.getErrorColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);

    if (_error != null && _topInstructors.isEmpty && _continueLearning.isEmpty) {
      return ErrorState(
        message: _error!,
        onRetry: () {
          setState(() => _error = null);
          _loadHomeData();
        },
      );
    }

    return Container(
      color: backgroundColor,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              if (_error != null && (_topInstructors.isNotEmpty || _continueLearning.isNotEmpty))
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _error = null);
                          _loadHomeData();
                        },
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_hasContinueLearningData())
                Column(
                  children: [
                    ContinueLearning(
                      onCoursePress: _handleCoursePress,
                      limit: 5,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              FeaturedCourses(
                onCoursePress: _handleCoursePress,
                onSeeAll: () => _handleSeeAll('featured'),
              ),
              const SizedBox(height: 24),

              Categories(
                onCategoryPress: _handleCategoryPress,
                onSeeAll: () => _handleSeeAll('categories'),
              ),
              const SizedBox(height: 24),

              RecommendedCourses(
                onCoursePress: _handleCoursePress,
                onSeeAll: () => _handleSeeAll('recommended'),
              ),
              const SizedBox(height: 24),

              PopularCourses(
                onCoursePress: _handleCoursePress,
                onSeeAll: () => _handleSeeAll('popular'),
                limit: 10,
              ),
              const SizedBox(height: 24),

              if (_liveClasses.isNotEmpty)
                LiveClasses(
                  classes: _liveClasses,
                  onJoinPress: _handleLiveClassJoin,
                  onSeeAll: () => _handleSeeAll('live'),
                ),
              if (_liveClasses.isNotEmpty) 
                const SizedBox(height: 24),

              if (_topInstructors.isNotEmpty)
                Column(
                  children: [
                    TopInstructors(
                      instructors: _topInstructors,
                      onFollowPress: _handleInstructorFollow,
                      onInstructorPress: _handleInstructorPress,
                      onSeeAll: () => _handleSeeAll('instructors'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// PROFILE CONTENT (Student - Coming Soon)
// ============================================

class ProfileContent extends StatelessWidget {
  const ProfileContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    // Get theme-aware colors
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_rounded,
              size: 80,
              color: textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Profile',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon!',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your profile and learning progress\nwill appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}