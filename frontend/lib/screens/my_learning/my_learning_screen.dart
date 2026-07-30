// lib/screens/my_learning/my_learning_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/error_state.dart';
import '../course/course_learning/course_learning.dart';
import '../../models/course_model.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({Key? key}) : super(key: key);

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _filteredCourses = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;
  final ApiService _apiService = ApiService();

  // Filter state
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'In Progress', 'Completed', 'Not Started'];

  // Search state
  String _searchQuery = '';
  bool _isSearching = false;

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses({bool isLoadMore = false}) async {
    if (isLoadMore && !_hasMore) return;
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _courses = [];
        _filteredCourses = [];
        _error = null;
      });
      return;
    }

    setState(() {
      if (isLoadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _error = null;
      }
    });

    try {
      final response = await _apiService.getContinueLearning(
        limit: 20,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        final courses = response.data!;
        
        // Process and enrich courses
        final processedCourses = await _enrichCourses(courses);

        setState(() {
          if (isLoadMore) {
            _courses = [..._courses, ...processedCourses];
          } else {
            _courses = processedCourses;
          }
          _applyFilters();
          _isLoading = false;
          _isRefreshing = false;
          _isLoadingMore = false;
          _hasMore = processedCourses.length >= 20;
          _error = null;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load courses';
          _isLoading = false;
          _isRefreshing = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isRefreshing = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _enrichCourses(
    List<Map<String, dynamic>> courses,
  ) async {
    final enriched = <Map<String, dynamic>>[];

    for (var course in courses) {
      final processed = Map<String, dynamic>.from(course);

      // Extract course data if nested
      if (course['course'] != null && course['course'] is Map<String, dynamic>) {
        final courseData = course['course'] as Map<String, dynamic>;
        processed.addAll(courseData);
      }

      // Ensure progress is a double
      double progress = 0.0;
      if (processed['progress'] != null) {
        if (processed['progress'] is double) {
          progress = processed['progress'] as double;
        } else if (processed['progress'] is int) {
          progress = (processed['progress'] as int).toDouble();
        } else if (processed['progress'] is String) {
          try {
            progress = double.parse(processed['progress'] as String);
          } catch (_) {
            progress = 0.0;
          }
        }
      }
      processed['progress'] = progress.clamp(0.0, 100.0);
      processed['isCompleted'] = processed['isCompleted'] ?? progress >= 100;

      // Get instructor name
      String instructorName = 'Unknown Instructor';
      if (processed['instructor'] != null) {
        if (processed['instructor'] is Map<String, dynamic>) {
          final inst = processed['instructor'] as Map<String, dynamic>;
          final firstName = inst['firstName']?.toString() ?? '';
          final lastName = inst['lastName']?.toString() ?? '';
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            instructorName = '$firstName $lastName'.trim();
          } else if (inst['name'] != null) {
            instructorName = inst['name'].toString();
          }
        } else if (processed['instructor'] is String) {
          instructorName = processed['instructor'] as String;
        }
      } else if (processed['instructorName'] != null) {
        instructorName = processed['instructorName'].toString();
      }
      processed['instructor'] = instructorName;

      // Get thumbnail
      String thumbnail = '';
      if (processed['thumbnail'] != null &&
          processed['thumbnail'].toString().isNotEmpty) {
        thumbnail = processed['thumbnail'].toString();
      } else if (processed['thumbnailUrl'] != null &&
          processed['thumbnailUrl'].toString().isNotEmpty) {
        thumbnail = processed['thumbnailUrl'].toString();
      } else if (processed['image'] != null &&
          processed['image'].toString().isNotEmpty) {
        thumbnail = processed['image'].toString();
      }
      processed['thumbnail'] = thumbnail;

      // Get category
      String category = 'General';
      if (processed['category'] != null) {
        if (processed['category'] is Map<String, dynamic>) {
          final cat = processed['category'] as Map<String, dynamic>;
          if (cat['name'] != null) category = cat['name'].toString();
        } else if (processed['category'] is String) {
          category = processed['category'] as String;
        }
      }
      processed['category'] = category;

      // Get level
      String level = 'Beginner';
      if (processed['level'] != null && processed['level'] is String) {
        level = processed['level'] as String;
      }
      processed['level'] = level;

      // Calculate remaining time message
      processed['remainingTime'] = _calculateRemainingTime(
        progress,
        processed['isCompleted'] ?? false,
      );

      enriched.add(processed);
    }

    return enriched;
  }

  String _calculateRemainingTime(double progress, bool isCompleted) {
    if (isCompleted || progress >= 100) {
      return 'Completed ✅';
    } else if (progress >= 80) {
      return 'Almost done';
    } else if (progress >= 60) {
      return 'Over halfway';
    } else if (progress >= 40) {
      return 'Halfway there';
    } else if (progress >= 20) {
      return 'Getting started';
    } else {
      return 'Just started';
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          final title = course['title']?.toString().toLowerCase() ?? '';
          final instructor = course['instructor']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          if (!title.contains(query) && !instructor.contains(query)) {
            return false;
          }
        }

        // Apply status filter
        switch (_selectedFilter) {
          case 'In Progress':
            return !(course['isCompleted'] ?? false) &&
                   (course['progress'] ?? 0) > 0;
          case 'Completed':
            return course['isCompleted'] ?? false;
          case 'Not Started':
            return (course['progress'] ?? 0) == 0;
          default:
            return true;
        }
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
      _page = 1;
      _hasMore = true;
    });
    await _loadCourses();
  }

  void _handleCoursePress(Map<String, dynamic> course) {
    final courseId = course['courseId'] ?? course['id'];
    
    try {
      final courseObj = _createCourseFromMap(course);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseLearningPage(
            courseId: courseId,
            course: courseObj,
          ),
        ),
      );
    } catch (e) {
      final minimalCourse = _createMinimalCourse(course);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseLearningPage(
            courseId: courseId,
            course: minimalCourse,
          ),
        ),
      );
    }
  }

  /// Tapping the card itself opens the course detail page — same as tapping
  /// a card in the "Continue Learning" widget on the home screen.
  void _handleCourseCardPress(Map<String, dynamic> course) {
    final courseId = course['courseId'] ?? course['id'];
    Navigator.pushNamed(context, '/course', arguments: {'courseId': courseId});
  }

  Course _createMinimalCourse(Map<String, dynamic> data) {
    final instructor = Instructor(
      id: data['instructorId'] ?? '',
      firstName: data['instructor']?.split(' ').first ?? 'Instructor',
      lastName: data['instructor']?.split(' ').sublist(1).join(' ') ?? '',
      email: '',
      photo: data['instructorAvatar'],
      bio: '',
      rating: 0,
      studentsCount: 0,
      coursesCount: 0,
    );

    final category = CourseCategory(
      id: 'cat_1',
      name: data['category'] ?? 'General',
      slug: data['category']?.toLowerCase().replaceAll(' ', '-') ?? 'general',
    );

    return Course(
      id: data['courseId'] ?? data['id'] ?? '',
      title: data['title'] ?? 'Course',
      description: data['description'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (data['reviewsCount'] as num?)?.toInt() ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      level: data['level'] ?? 'Beginner',
      language: data['language'] ?? 'English',
      studentsCount: (data['studentsCount'] as num?)?.toInt() ?? 0,
      sections: [],
      instructor: instructor,
      category: category,
      whatYouWillLearn: [],
      requirements: [],
      studyMaterials: [],
      reviews: [],
      learningObjectives: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      instructorId: data['instructorId'] ?? '',
      categoryId: 'cat_1',
    );
  }

  Course _createCourseFromMap(Map<String, dynamic> data) {
    return _createMinimalCourse(data);
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _applyFilters();
      }
    });
  }

  /// Card width/height using the exact same breakpoints, percentages, and
  /// clamps as widgets/home/continue_learning.dart, so a course card looks
  /// identical whether it's on the Home tab or here on My Learning.
  ({double width, double height}) _computeCardSize(double screenWidth, double screenHeight) {
    double cardWidth;
    double cardHeight;

    if (screenWidth < 380) {
      cardWidth = screenWidth * 0.75;
      cardHeight = screenHeight * 0.30;
    } else if (screenWidth < 600) {
      cardWidth = screenWidth * 0.65;
      cardHeight = screenHeight * 0.32;
    } else if (screenWidth < 900) {
      cardWidth = screenWidth * 0.40;
      cardHeight = screenHeight * 0.34;
    } else {
      cardWidth = screenWidth * 0.28;
      cardHeight = screenHeight * 0.36;
    }

    cardWidth = cardWidth.clamp(180.0, 380.0);
    cardHeight = cardHeight.clamp(200.0, 360.0);

    return (width: cardWidth, height: cardHeight);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    if (!authProvider.isAuthenticated) {
      return _buildNotAuthenticated(isDark);
    }

    if (_isLoading) {
      return _buildSkeletonLoading(isDark, screenWidth, screenHeight);
    }

    if (_error != null && _courses.isEmpty) {
      return ErrorState(
        message: _error!,
        onRetry: _loadCourses,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(brightness),
      appBar: _buildAppBar(isDark, isDesktop),
      body: Column(
        children: [
          _buildFilterBar(isDark, screenWidth),
          Expanded(
            child: _courses.isEmpty
                ? _buildEmptyState(isDark)
                : _buildCourseGrid(isDark, isTablet, isDesktop, screenWidth, screenHeight),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SKELETON LOADING
  // ============================================

  Widget _buildSkeletonLoading(bool isDark, double screenWidth, double screenHeight) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final cardSize = _computeCardSize(screenWidth, screenHeight);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark ? Brightness.dark : Brightness.light),
      appBar: AppBar(
        backgroundColor: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
        elevation: 0,
        title: Container(
          height: 24,
          width: 150,
          decoration: BoxDecoration(
            color: AppColors.getBackgroundSelectedColor(brightness),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        actions: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSelectedColor(brightness),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSelectedColor(brightness),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter chips skeleton
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 80,
                    height: 32,
                  );
                }),
              ),
            ),
          ),
          // Course grid skeleton
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: cardSize.width,
                  mainAxisExtent: cardSize.height,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildSkeletonCard(isDark, cardSize.height);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard(bool isDark, double cardHeight) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final imageHeight = (cardHeight * 0.40).clamp(80.0, 160.0);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thumbnail skeleton
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSelectedColor(brightness),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),
          // Content skeleton
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title skeleton
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Second title line
                  Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Instructor name skeleton
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Category skeleton
                  Container(
                    height: 8,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Same overflow-safe flexible gap used by the real card.
                  const Flexible(child: SizedBox(height: 8)),
                  // Progress bar skeleton
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Resume/Review button skeleton
                  Container(
                    height: 28,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // EXISTING BUILD METHODS (unchanged)
  // ============================================

  PreferredSizeWidget _buildAppBar(bool isDark, bool isDesktop) {
    return AppBar(
      backgroundColor: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
      elevation: 0,
      title: _isSearching
          ? _buildSearchField(isDark)
          : Text(
              'My Learning',
              style: GoogleFonts.inter(
                color: AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 24 : 20,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
          ),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
          ),
          onPressed: () {
            _showFilterDialog(isDark);
          },
        ),
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        autofocus: true,
        onChanged: _handleSearch,
        style: TextStyle(
          color: AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
        ),
        decoration: InputDecoration(
          hintText: 'Search your courses...',
          hintStyle: TextStyle(
            color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildFilterBar(bool isDark, double screenWidth) {
    final isSmallScreen = screenWidth < 380;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 16,
        vertical: 8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
              child: FilterChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                    _applyFilters();
                  });
                },
                backgroundColor: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
                selectedColor: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light)
                        : AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCourseGrid(
    bool isDark,
    bool isTablet,
    bool isDesktop,
    double screenWidth,
    double screenHeight,
  ) {
    final cardSize = _computeCardSize(screenWidth, screenHeight);

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          // Fixed box size (not an aspect ratio) so every card is exactly
          // the same width/height as the "Continue Learning" cards.
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: cardSize.width,
            mainAxisExtent: cardSize.height,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredCourses.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _filteredCourses.length && _hasMore) {
              return _buildLoadMoreCard(isDark);
            }
            return _buildCourseCard(
              context,
              _filteredCourses[index],
              isDark,
              screenWidth,
              cardSize.height,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    bool isDark,
    double screenWidth,
    double cardHeight,
  ) {
    final brightness = isDark ? Brightness.dark : Brightness.light;

    // Theme-aware colors (same accessor pattern used across the app,
    // e.g. widgets/home/continue_learning.dart)
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final successColor = AppColors.getSuccessColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    final progress = (course['progress'] as num?)?.toDouble() ?? 0.0;
    final isCompleted = course['isCompleted'] ?? false;
    final progressColor = isCompleted ? successColor : primaryColor;
    final progressValue = (progress / 100).clamp(0.0, 1.0);

    // Responsive sizing — exact same breakpoints, proportions, and clamps
    // as widgets/home/continue_learning.dart's card, so both surfaces
    // render identical-looking, identical-sized cards.
    double fontSizeTitle;
    double fontSizeSubtitle;
    double fontSizeBadge;
    double paddingSize;
    double buttonHeight;
    double progressBarHeight;

    if (screenWidth < 380) {
      fontSizeTitle = 12;
      fontSizeSubtitle = 10;
      fontSizeBadge = 8;
      paddingSize = 6;
      buttonHeight = 28;
      progressBarHeight = 3;
    } else if (screenWidth < 600) {
      fontSizeTitle = 13;
      fontSizeSubtitle = 11;
      fontSizeBadge = 9;
      paddingSize = 8;
      buttonHeight = 30;
      progressBarHeight = 4;
    } else if (screenWidth < 900) {
      fontSizeTitle = 14;
      fontSizeSubtitle = 12;
      fontSizeBadge = 10;
      paddingSize = 10;
      buttonHeight = 34;
      progressBarHeight = 4;
    } else {
      fontSizeTitle = 15;
      fontSizeSubtitle = 13;
      fontSizeBadge = 11;
      paddingSize = 12;
      buttonHeight = 36;
      progressBarHeight = 5;
    }

    final imageHeight = (cardHeight * 0.40).clamp(80.0, 160.0);

    return GestureDetector(
      onTap: () => _handleCourseCardPress(course),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundElementColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: backgroundSelectedColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section with corner badges (percent, completed, level,
            // remaining time) — same layout as the Continue Learning card.
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: course['thumbnail'] != null && course['thumbnail'].toString().isNotEmpty
                      ? Image.network(
                          course['thumbnail'],
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: primaryColor.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.image_outlined,
                                size: 30,
                                color: textSecondaryColor,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: imageHeight,
                          width: double.infinity,
                          color: primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.school_outlined,
                            size: 30,
                            color: textSecondaryColor,
                          ),
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${progress.round()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeBadge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: successColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: fontSizeBadge + 2,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSizeBadge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (course['level'] != null)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        course['level'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeBadge,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: fontSizeBadge + 2,
                        ),
                        const SizedBox(width: 2),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 90),
                          child: Text(
                            course['remainingTime'] ?? 'In progress',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSizeBadge,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(paddingSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: fontSizeTitle * 2.4,
                      child: Text(
                        course['title'] ?? 'Untitled',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSizeTitle,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: paddingSize * 0.5),
                    SizedBox(
                      height: fontSizeSubtitle + 2,
                      child: Text(
                        course['instructor'] ?? 'Unknown Instructor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSizeSubtitle,
                          color: textSecondaryColor,
                        ),
                      ),
                    ),
                    if (course['category'] != null)
                      SizedBox(
                        height: fontSizeSubtitle,
                        child: Text(
                          course['category'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: fontSizeSubtitle - 2,
                            color: textSecondaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    // Flexible spacer keeps the progress bar + button pinned
                    // to the bottom without risking an overflow: since it
                    // lives inside a bounded Expanded, any leftover space
                    // (which can be zero) is absorbed here safely.
                    Flexible(child: SizedBox(height: paddingSize * 0.5)),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingSize * 0.5),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: backgroundSelectedColor.withValues(alpha: 0.5),
                                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                minHeight: progressBarHeight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.round()}%',
                            style: TextStyle(
                              fontSize: fontSizeSubtitle - 1,
                              fontWeight: FontWeight.w600,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => _handleCoursePress(course),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted ? successColor : primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          isCompleted ? 'Review' : 'Resume',
                          style: TextStyle(
                            fontSize: fontSizeSubtitle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 8),
            Text(
              'Loading more...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No courses found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No courses match your search criteria'
                  : 'Start learning today! Enroll in a course to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light),
              ),
            ),
            const SizedBox(height: 24),
            if (_searchQuery.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _applyFilters();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Clear Search',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/browse');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Browse Courses',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAuthenticated(bool isDark) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark ? Brightness.dark : Brightness.light),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.login_outlined,
                size: 80,
                color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light).withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Login to Continue Learning',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to track your progress and continue where you left off.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Courses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
                ),
              ),
              const SizedBox(height: 16),
              ..._filters.map((filter) {
                return RadioListTile<String>(
                  title: Text(
                    filter,
                    style: TextStyle(
                      color: AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
                    ),
                  ),
                  value: filter,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFilter = value;
                        _applyFilters();
                      });
                      Navigator.pop(context);
                    }
                  },
                  activeColor: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light),
                );
              }).toList(),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'All';
                    _applyFilters();
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Clear Filter',
                  style: TextStyle(
                    color: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}