// lib/widgets/home/popular_courses.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../providers/theme_provider.dart';

class PopularCourses extends StatefulWidget {
  final Function(String)? onCoursePress;
  final VoidCallback? onSeeAll;
  final int limit;

  const PopularCourses({
    Key? key,
    this.onCoursePress,
    this.onSeeAll,
    this.limit = 10,
  }) : super(key: key);

  @override
  State<PopularCourses> createState() => _PopularCoursesState();
}

class _PopularCoursesState extends State<PopularCourses> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchPopularCourses();
  }

  // Helper method to extract instructor name from course data
  String _extractInstructorName(Map<String, dynamic> course) {
    String instructorName = 'Unknown Instructor';
    
    // Try to get instructor from nested object
    if (course['instructor'] != null) {
      if (course['instructor'] is Map<String, dynamic>) {
        final instructor = course['instructor'] as Map<String, dynamic>;
        // Try different field names
        if (instructor['fullName'] != null && instructor['fullName'].toString().isNotEmpty) {
          instructorName = instructor['fullName'].toString();
        } else if (instructor['name'] != null && instructor['name'].toString().isNotEmpty) {
          instructorName = instructor['name'].toString();
        } else if (instructor['firstName'] != null || instructor['lastName'] != null) {
          final firstName = instructor['firstName']?.toString() ?? '';
          final lastName = instructor['lastName']?.toString() ?? '';
          instructorName = '$firstName $lastName'.trim();
          if (instructorName.isEmpty) {
            instructorName = 'Unknown Instructor';
          }
        } else if (instructor['username'] != null && instructor['username'].toString().isNotEmpty) {
          instructorName = instructor['username'].toString();
        }
      } else if (course['instructor'] is String) {
        final inst = course['instructor'] as String;
        if (inst.isNotEmpty) {
          instructorName = inst;
        }
      }
    }
    
    // Try to get instructor from direct fields
    if (instructorName == 'Unknown Instructor' || instructorName.isEmpty) {
      if (course['instructorName'] != null && course['instructorName'].toString().isNotEmpty) {
        instructorName = course['instructorName'].toString();
      } else if (course['firstName'] != null || course['lastName'] != null) {
        final firstName = course['firstName']?.toString() ?? '';
        final lastName = course['lastName']?.toString() ?? '';
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          instructorName = '$firstName $lastName'.trim();
        }
      } else if (course['username'] != null && course['username'].toString().isNotEmpty) {
        instructorName = course['username'].toString();
      } else if (course['instructorId'] != null) {
        // Try to get from instructorId if available
        final instructorId = course['instructorId'].toString();
        if (instructorId.isNotEmpty && instructorId != 'null') {
          instructorName = 'Instructor ${instructorId.substring(0, instructorId.length > 4 ? 4 : instructorId.length)}';
        }
      }
    }

    // If still Unknown, try to get from email
    if (instructorName == 'Unknown Instructor' && course['email'] != null) {
      final email = course['email'].toString();
      if (email.contains('@')) {
        final parts = email.split('@');
        if (parts.isNotEmpty) {
          final nameParts = parts[0].split('.');
          if (nameParts.length >= 2) {
            instructorName = '${nameParts[0].capitalize()} ${nameParts[1].capitalize()}';
          } else if (nameParts.isNotEmpty) {
            instructorName = nameParts[0].capitalize();
          }
        }
      }
    }

    return instructorName;
  }

  // Safe conversion helpers
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    if (value is num) return value.toDouble();
    return 0.0;
  }

  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    if (value is num) return value.toInt();
    return 0;
  }

  Future<void> _fetchPopularCourses({bool isLoadMore = false}) async {
    if (isLoadMore && !_hasMore) return;

    if (!mounted) return;

    setState(() {
      if (isLoadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final currentPage = isLoadMore ? _page : 1;
      final limit = widget.limit;

      // Fetch popular courses from API
      final response = await _apiService.getPopularCourses(
        limit: limit,
        page: currentPage,
        timeRange: 'week',
      );

      if (!mounted) return;

      if (response.success) {
        final data = response.data;
        final List<dynamic> courses = (data?['data'] ?? []) as List<dynamic>;
        final pagination = data?['pagination'] ?? {};

        // Transform courses to match the expected format with proper instructor extraction
        final transformedCourses = courses.map((course) {
          return _transformCourseData(course);
        }).toList();

        setState(() {
          if (isLoadMore) {
            _courses = [..._courses, ...transformedCourses];
          } else {
            _courses = transformedCourses;
          }
          
          _page = currentPage + 1;
          _hasMore = pagination['hasMore'] ?? false;
          _isLoading = false;
          _isRefreshing = false;
          _isLoadingMore = false;
        });
      } else {
        // If API fails, use fallback data
        setState(() {
          if (isLoadMore) {
            _hasMore = false;
            _isLoadingMore = false;
          } else {
            _courses = _getFallbackCourses();
            _isLoading = false;
            _isRefreshing = false;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (isLoadMore) {
          _hasMore = false;
          _isLoadingMore = false;
        } else {
          _courses = _getFallbackCourses();
          _isLoading = false;
          _isRefreshing = false;
        }
      });
    }
  }

  Map<String, dynamic> _transformCourseData(Map<String, dynamic> course) {
    // Extract instructor name using the helper method
    final instructorName = _extractInstructorName(course);

    // Get rating
    final rating = _safeToDouble(course['rating']);

    // Get students count
    int students = 0;
    if (course['_count'] != null && course['_count']['enrollments'] != null) {
      students = _safeToInt(course['_count']['enrollments']);
    } else {
      students = _safeToInt(course['students']);
    }

    // Get price
    final price = _safeToDouble(course['price']);

    // Get discount price
    double? discountPrice;
    if (course['discountPrice'] != null) {
      discountPrice = _safeToDouble(course['discountPrice']);
    }

    // Get thumbnail
    String thumbnail = '';
    if (course['thumbnail'] != null && course['thumbnail'].toString().isNotEmpty) {
      thumbnail = course['thumbnail'].toString();
    } else if (course['thumbnailUrl'] != null && course['thumbnailUrl'].toString().isNotEmpty) {
      thumbnail = course['thumbnailUrl'].toString();
    }

    // Determine if trending (based on students count or rating)
    bool isTrending = students > 5000 || rating >= 4.8;

    // Get category
    String category = 'General';
    if (course['category'] != null) {
      if (course['category'] is Map<String, dynamic>) {
        category = course['category']['name'] ?? 'General';
      } else if (course['category'] is String) {
        category = course['category'] as String;
      }
    }

    return {
      'id': course['id'] ?? '',
      'title': course['title'] ?? 'Untitled Course',
      'instructor': instructorName,
      'thumbnail': thumbnail.isNotEmpty ? thumbnail : 'https://picsum.photos/400/200?random=${course['id'] ?? '1'}',
      'rating': rating,
      'students': students,
      'isTrending': isTrending,
      'price': price,
      'discountPrice': discountPrice,
      'level': course['level'] ?? 'Beginner',
      'category': category,
      'duration': course['duration']?.toString() ?? '2h 30m',
      'description': course['description'] ?? '',
    };
  }

  List<Map<String, dynamic>> _getFallbackCourses() {
    return [
      {
        'id': '1',
        'title': 'Python for Data Science and Machine Learning',
        'instructor': 'Jose Portilla',
        'thumbnail': 'https://picsum.photos/400/200?random=60',
        'rating': 4.9,
        'students': 15000,
        'isTrending': true,
        'price': 149.99,
        'discountPrice': 99.99,
        'level': 'Intermediate',
        'category': 'Data Science',
        'duration': '12h 30m',
      },
      {
        'id': '2',
        'title': 'JavaScript: The Advanced Concepts',
        'instructor': 'Andrei Neagoie',
        'thumbnail': 'https://picsum.photos/400/200?random=61',
        'rating': 4.8,
        'students': 12000,
        'isTrending': false,
        'price': 109.99,
        'discountPrice': null,
        'level': 'Advanced',
        'category': 'Programming',
        'duration': '8h 45m',
      },
      {
        'id': '3',
        'title': 'UI/UX Design with Figma',
        'instructor': 'Daniel Scott',
        'thumbnail': 'https://picsum.photos/400/200?random=62',
        'rating': 4.7,
        'students': 9800,
        'isTrending': true,
        'price': 89.99,
        'discountPrice': 69.99,
        'level': 'Beginner',
        'category': 'Design',
        'duration': '6h 20m',
      },
      {
        'id': '4',
        'title': 'The Complete SQL Bootcamp',
        'instructor': 'Jose Portilla',
        'thumbnail': 'https://picsum.photos/400/200?random=63',
        'rating': 4.6,
        'students': 8500,
        'isTrending': false,
        'price': 79.99,
        'discountPrice': null,
        'level': 'Beginner',
        'category': 'Database',
        'duration': '9h 15m',
      },
    ];
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
      _page = 1;
      _hasMore = true;
      _courses = [];
    });
    await _fetchPopularCourses();
  }

  void _loadMore() {
    if (!_isLoadingMore && _hasMore && !_isLoading && !_isRefreshing) {
      _fetchPopularCourses(isLoadMore: true);
    }
  }

  void _handleCoursePress(Map<String, dynamic> course) {
    if (widget.onCoursePress != null) {
      widget.onCoursePress!(course['id']);
    } else {
      Navigator.pushNamed(
        context,
        '/course',
        arguments: {'courseId': course['id']},
      );
    }
  }

  void _handleSeeAll() {
    if (widget.onSeeAll != null) {
      widget.onSeeAll!();
    } else {
      Navigator.pushNamed(context, '/browse');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get theme-aware colors
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    // Responsive sizing
    double cardWidth;
    double cardHeight;
    double imageHeight;
    double fontSizeTitle;
    double fontSizeSubtitle;
    double fontSizeBadge;
    double fontSizePrice;
    double paddingSize;
    double gap;

    if (screenWidth < 380) {
      cardWidth = screenWidth * 0.60;
      cardHeight = screenHeight * 0.30;
      imageHeight = cardHeight * 0.50;
      fontSizeTitle = 13;
      fontSizeSubtitle = 11;
      fontSizeBadge = 9;
      fontSizePrice = 13;
      paddingSize = 8;
      gap = 10;
    } else if (screenWidth < 600) {
      cardWidth = screenWidth * 0.50;
      cardHeight = screenHeight * 0.32;
      imageHeight = cardHeight * 0.50;
      fontSizeTitle = 14;
      fontSizeSubtitle = 12;
      fontSizeBadge = 10;
      fontSizePrice = 14;
      paddingSize = 10;
      gap = 12;
    } else if (screenWidth < 900) {
      cardWidth = screenWidth * 0.32;
      cardHeight = screenHeight * 0.34;
      imageHeight = cardHeight * 0.50;
      fontSizeTitle = 15;
      fontSizeSubtitle = 13;
      fontSizeBadge = 11;
      fontSizePrice = 15;
      paddingSize = 12;
      gap = 16;
    } else {
      cardWidth = screenWidth * 0.22;
      cardHeight = screenHeight * 0.36;
      imageHeight = cardHeight * 0.50;
      fontSizeTitle = 16;
      fontSizeSubtitle = 14;
      fontSizeBadge = 12;
      fontSizePrice = 16;
      paddingSize = 14;
      gap = 18;
    }

    cardWidth = cardWidth.clamp(140.0, 320.0);
    cardHeight = cardHeight.clamp(180.0, 360.0);
    imageHeight = imageHeight.clamp(80.0, 180.0);

    if (_isLoading) {
      return _buildSkeletonLoading(isDark, cardWidth, cardHeight, brightness);
    }

    if (_courses.isEmpty) {
      return _buildEmptyState(isDark, brightness);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: screenWidth < 380 ? 18 : 20,
                      color: const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Popular Courses',
                      style: TextStyle(
                        fontSize: screenWidth < 380 ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _handleSeeAll,
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: screenWidth < 380 ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Scroll
        SizedBox(
          height: cardHeight + 20,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: primaryColor,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification) {
                  final metrics = notification.metrics;
                  if (metrics.pixels >= metrics.maxScrollExtent - 100) {
                    _loadMore();
                  }
                }
                return false;
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _courses.length + (_hasMore ? 1 : 0),
                padding: const EdgeInsets.only(right: 16),
                itemBuilder: (context, index) {
                  if (index == _courses.length && _hasMore) {
                    return _buildLoadMoreIndicator(isDark, cardWidth, brightness);
                  }
                  final course = _courses[index];
                  return _buildCourseCard(
                    context,
                    course,
                    index,
                    cardWidth,
                    cardHeight,
                    imageHeight,
                    fontSizeTitle,
                    fontSizeSubtitle,
                    fontSizeBadge,
                    fontSizePrice,
                    paddingSize,
                    gap,
                    isDark,
                    brightness,
                    screenWidth,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    int index,
    double cardWidth,
    double cardHeight,
    double imageHeight,
    double fontSizeTitle,
    double fontSizeSubtitle,
    double fontSizeBadge,
    double fontSizePrice,
    double paddingSize,
    double gap,
    bool isDark,
    Brightness brightness,
    double screenWidth,
  ) {
    // Get theme-aware colors
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    final isLast = index == _courses.length - 1;
    final isTrending = course['isTrending'] ?? false;
    final rating = _safeToDouble(course['rating']);
    final students = _safeToInt(course['students']);
    final hasDiscount = course['discountPrice'] != null && _safeToDouble(course['discountPrice']) > 0;
    final price = _safeToDouble(course['price']);
    final discountPrice = _safeToDouble(course['discountPrice']);
    final instructor = course['instructor']?.toString() ?? 'Unknown Instructor';

    return GestureDetector(
      onTap: () => _handleCoursePress(course),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(
          right: isLast ? 0 : gap,
        ),
        decoration: BoxDecoration(
          color: backgroundElementColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: backgroundSelectedColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : const Color(0xFF0F172A).withValues(alpha: 0.06),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
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
                // Trending Badge
                if (isTrending)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade700,
                            Colors.orange.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: fontSizeBadge + 2,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Trending',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSizeBadge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Price Badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasDiscount)
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: fontSizeSubtitle,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (hasDiscount) const SizedBox(width: 6),
                        Text(
                          hasDiscount
                              ? '\$${discountPrice.toStringAsFixed(2)}'
                              : '\$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizePrice,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Level Badge - Bottom Left
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course['level'] ?? 'Beginner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeBadge,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(paddingSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      course['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Instructor - Now properly displayed with icon
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: fontSizeSubtitle - 2,
                          color: textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            instructor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: fontSizeSubtitle,
                              color: textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Rating and Students
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: fontSizeSubtitle + 2,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: fontSizeSubtitle,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '(${students.toString()})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: fontSizeSubtitle - 2,
                              color: textSecondaryColor,
                            ),
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
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isDark, double cardWidth, Brightness brightness) {
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return Container(
      width: cardWidth,
      height: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: backgroundElementColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: backgroundSelectedColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
            ),
            const SizedBox(height: 12),
            Text(
              'Loading more...',
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(bool isDark, double cardWidth, double cardHeight, Brightness brightness) {
    final screenWidth = MediaQuery.of(context).size.width;
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Skeleton
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: screenWidth < 380 ? 18 : 20,
                    width: screenWidth < 380 ? 18 : 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: screenWidth < 380 ? 20 : 24,
                    width: screenWidth < 380 ? 120 : 160,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              Container(
                height: screenWidth < 380 ? 14 : 18,
                width: screenWidth < 380 ? 50 : 60,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight + 20,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            padding: const EdgeInsets.only(right: 16),
            itemBuilder: (context, index) {
              return Container(
                width: cardWidth,
                height: cardHeight,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: backgroundElementColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: backgroundSelectedColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: cardHeight * 0.50,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 14,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 10,
                              width: 80,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  height: 10,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, Brightness brightness) {
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 20,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              Text(
                'Popular Courses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: backgroundElementColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: backgroundSelectedColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                size: 48,
                color: textSecondaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                'No popular courses available',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}