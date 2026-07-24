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
  String? _error;

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

  // Helper method to format currency with Nepali Rupees (रू)
  String _formatCurrency(num amount) {
    final double amountDouble = amount.toDouble();
    if (amountDouble == amountDouble.roundToDouble()) {
      return amountDouble.toStringAsFixed(0);
    } else {
      return amountDouble.toStringAsFixed(2);
    }
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
        _error = null;
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
          _error = null;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load popular courses';
          _isLoading = false;
          _isRefreshing = false;
          _isLoadingMore = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isRefreshing = false;
        _isLoadingMore = false;
        _hasMore = false;
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

    // Get price with Nepali Rupees
    final price = _safeToDouble(course['price']);
    final discountPrice = _safeToDouble(course['discountPrice']);

    // Format price displays
    String priceDisplay;
    if (discountPrice > 0) {
      priceDisplay = 'रू ${_formatCurrency(discountPrice)}';
    } else if (price > 0) {
      priceDisplay = 'रू ${_formatCurrency(price)}';
    } else {
      priceDisplay = 'Free';
    }

    // Get thumbnail
    String thumbnail = '';
    if (course['thumbnail'] != null && course['thumbnail'].toString().isNotEmpty) {
      thumbnail = course['thumbnail'].toString();
    } else if (course['thumbnailUrl'] != null && course['thumbnailUrl'].toString().isNotEmpty) {
      thumbnail = course['thumbnailUrl'].toString();
    }

    // If no thumbnail, use placeholder
    if (thumbnail.isEmpty) {
      thumbnail = 'https://picsum.photos/400/200?random=${course['id'] ?? '1'}';
    }

    // Determine badge based on course stats
    String badge = '📚 Course';
    if (students > 10000) {
      badge = '🔥 Bestseller';
    } else if (rating >= 4.8 && students > 1000) {
      badge = '⭐ Top Rated';
    } else if (students > 5000) {
      badge = '📈 Popular';
    } else if (course['isNew'] == true) {
      badge = '✨ New';
    }

    // Get level
    String level = 'Beginner';
    if (course['level'] != null && course['level'].toString().isNotEmpty) {
      level = course['level'].toString();
    }

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
      'thumbnail': thumbnail,
      'rating': rating,
      'students': students,
      'price': price,
      'discountPrice': discountPrice,
      'priceDisplay': priceDisplay,
      'badge': badge,
      'level': level,
      'category': category,
      'description': course['description'] ?? '',
    };
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    await _fetchPopularCourses();
  }

  void _loadMore() {
    if (!_isLoadingMore && _hasMore && !_isLoading && !_isRefreshing && _error == null) {
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

    // Responsive sizing - matching Featured Courses
    double cardWidth;
    double cardHeight;
    double imageHeight;
    double fontSizeTitle;
    double fontSizeSubtitle;
    double fontSizeBadge;
    double paddingSize;
    
    if (screenWidth < 380) {
      cardWidth = screenWidth * 0.75;
      cardHeight = screenHeight * 0.32;
      imageHeight = cardHeight * 0.5;
      fontSizeTitle = 13;
      fontSizeSubtitle = 11;
      fontSizeBadge = 9;
      paddingSize = 8;
    } else if (screenWidth < 600) {
      cardWidth = screenWidth * 0.65;
      cardHeight = screenHeight * 0.34;
      imageHeight = cardHeight * 0.5;
      fontSizeTitle = 14;
      fontSizeSubtitle = 12;
      fontSizeBadge = 10;
      paddingSize = 10;
    } else if (screenWidth < 900) {
      cardWidth = screenWidth * 0.40;
      cardHeight = screenHeight * 0.36;
      imageHeight = cardHeight * 0.5;
      fontSizeTitle = 15;
      fontSizeSubtitle = 13;
      fontSizeBadge = 11;
      paddingSize = 12;
    } else {
      cardWidth = screenWidth * 0.28;
      cardHeight = screenHeight * 0.38;
      imageHeight = cardHeight * 0.5;
      fontSizeTitle = 16;
      fontSizeSubtitle = 14;
      fontSizeBadge = 12;
      paddingSize = 14;
    }

    cardWidth = cardWidth.clamp(180.0, 400.0);
    cardHeight = cardHeight.clamp(220.0, 380.0);
    imageHeight = imageHeight.clamp(100.0, 190.0);

    if (_isLoading) {
      return _buildSkeletonLoading(isDark, cardWidth, cardHeight, brightness);
    }

    if (_error != null || _courses.isEmpty) {
      return const SizedBox.shrink();
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
          height: cardHeight + 10,
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
                    paddingSize,
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
    double paddingSize,
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
    final rating = _safeToDouble(course['rating']);
    final students = _safeToInt(course['students']);
    final hasDiscount = course['discountPrice'] != null && _safeToDouble(course['discountPrice']) > 0;
    final price = _safeToDouble(course['price']);
    final discountPrice = _safeToDouble(course['discountPrice']);
    final instructor = course['instructor']?.toString() ?? 'Unknown Instructor';
    final badge = course['badge'] ?? '📚 Course';
    final level = course['level'] ?? 'Beginner';
    
    // Get price display
    String priceDisplay = course['priceDisplay'] ?? 'Free';

    return GestureDetector(
      onTap: () => _handleCoursePress(course),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(
          right: isLast ? 0 : 12,
        ),
        decoration: BoxDecoration(
          color: backgroundElementColor,
          borderRadius: BorderRadius.circular(14),
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
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: backgroundSelectedColor,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
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
                // Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeBadge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Price Badge - Bottom Right with रू symbol
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasDiscount)
                          Text(
                            'रू ${_formatCurrency(price)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: fontSizeBadge,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (hasDiscount) const SizedBox(width: 4),
                        Text(
                          priceDisplay,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeBadge + 1,
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
                      level,
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
                    // Instructor
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
                              fontSize: fontSizeSubtitle - 1,
                              color: textSecondaryColor,
                              fontWeight: FontWeight.w500,
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
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: fontSizeSubtitle,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${students.toString()} students',
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
      height: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: backgroundElementColor,
        borderRadius: BorderRadius.circular(14),
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
          height: cardHeight + 10,
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
                  borderRadius: BorderRadius.circular(14),
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
                      height: cardHeight * 0.5,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
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
                            const SizedBox(height: 4),
                            Container(
                              height: 10,
                              width: 80,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Container(
                                  height: 12,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 10,
                                  width: 60,
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

  Widget _buildErrorState(bool isDark, Brightness brightness) {
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final errorColor = AppColors.getErrorColor(brightness);
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
          padding: const EdgeInsets.all(20),
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
                Icons.error_outline,
                size: 40,
                color: errorColor,
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to Load Popular Courses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _error ?? 'Something went wrong. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
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