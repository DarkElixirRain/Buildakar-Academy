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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    if (!authProvider.isAuthenticated) {
      return _buildNotAuthenticated(isDark);
    }

    if (_isLoading) {
      return _buildSkeletonLoading(isDark, screenWidth);
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
                : _buildCourseGrid(isDark, isTablet, isDesktop, screenWidth),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SKELETON LOADING
  // ============================================

  Widget _buildSkeletonLoading(bool isDark, double screenWidth) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    int crossAxisCount;
    double aspectRatio;

    if (screenWidth < 400) {
      crossAxisCount = 1;
      aspectRatio = 1.15;
    } else if (screenWidth < 600) {
      crossAxisCount = 2;
      aspectRatio = 1.05;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
      aspectRatio = 1.0;
    } else if (screenWidth < 1200) {
      crossAxisCount = 4;
      aspectRatio = 0.95;
    } else {
      crossAxisCount = 5;
      aspectRatio = 0.9;
    }

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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildSkeletonCard(isDark);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail skeleton
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSelectedColor(brightness),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
                  const SizedBox(height: 8),
                  // Level and category skeleton
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundSelectedColor(brightness),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 16,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundSelectedColor(brightness),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Progress bar skeleton
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress text skeleton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 8,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundSelectedColor(brightness),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 8,
                        width: 30,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundSelectedColor(brightness),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
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

  Widget _buildCourseGrid(bool isDark, bool isTablet, bool isDesktop, double screenWidth) {
    int crossAxisCount;
    double aspectRatio;

    if (screenWidth < 400) {
      crossAxisCount = 1;
      aspectRatio = 1.15;
    } else if (screenWidth < 600) {
      crossAxisCount = 2;
      aspectRatio = 1.05;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
      aspectRatio = 1.0;
    } else if (screenWidth < 1200) {
      crossAxisCount = 4;
      aspectRatio = 0.95;
    } else {
      crossAxisCount = 5;
      aspectRatio = 0.9;
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
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
  ) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final progress = (course['progress'] as num?)?.toDouble() ?? 0.0;
    final isCompleted = course['isCompleted'] ?? false;
    final progressColor = isCompleted
        ? AppColors.getSuccessColor(brightness)
        : AppColors.getPrimaryColor(brightness);
    final progressValue = (progress / 100).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _handleCoursePress(course),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : AppColors.getTextColor(brightness).withValues(alpha: 0.06),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  course['thumbnail'] != null && course['thumbnail'].toString().isNotEmpty
                      ? Image.network(
                          course['thumbnail'],
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 110,
                              width: double.infinity,
                              color: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light).withValues(alpha: 0.1),
                              child: Icon(
                                Icons.school_outlined,
                                size: 40,
                                color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 110,
                          width: double.infinity,
                          color: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light).withValues(alpha: 0.1),
                          child: Icon(
                            Icons.school_outlined,
                            size: 40,
                            color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light),
                          ),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${progress.round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.getSuccessColor(brightness),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scrollable-safe title/instructor/badges block: guarantees
                    // this section can never throw a RenderFlex overflow error,
                    // even with long titles, large text-scale factors, or very
                    // short cards — it degrades to a soft clip instead of
                    // painting the yellow/black overflow stripes.
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              course['title'] ?? 'Untitled',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenWidth < 400 ? 12 : 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              course['instructor'] ?? 'Unknown Instructor',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenWidth < 400 ? 10 : 12,
                                color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      course['level'] ?? 'Beginner',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: screenWidth < 400 ? 8 : 10,
                                        color: AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    course['category'] ?? 'General',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: screenWidth < 400 ? 8 : 10,
                                      color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Progress bar (always pinned to the bottom of the card)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.getBackgroundSelectedColor(brightness),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressValue,
                            child: Container(
                              decoration: BoxDecoration(
                                color: progressColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                isCompleted ? 'Completed' : (course['remainingTime'] ?? 'In progress'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: screenWidth < 400 ? 8 : 10,
                                  color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${progress.round()}%',
                              style: TextStyle(
                                fontSize: screenWidth < 400 ? 8 : 10,
                                fontWeight: FontWeight.w600,
                                color: progressColor,
                              ),
                            ),
                          ],
                        ),
                      ],
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