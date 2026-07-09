// lib/widgets/home/recommended_courses.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../providers/theme_provider.dart';

class RecommendedCourses extends StatefulWidget {
  final Function(String)? onCoursePress;
  final VoidCallback? onSeeAll;
  final int limit;

  const RecommendedCourses({
    Key? key,
    this.onCoursePress,
    this.onSeeAll,
    this.limit = 10,
  }) : super(key: key);

  @override
  State<RecommendedCourses> createState() => _RecommendedCoursesState();
}

class _RecommendedCoursesState extends State<RecommendedCourses> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final Set<String> _savedCourses = {};
  final ApiService _apiService = ApiService();
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedCourses();
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

  // Helper method to transform course data
  Map<String, dynamic> _transformCourseData(Map<String, dynamic> course) {
    final transformed = Map<String, dynamic>.from(course);
    
    // Extract and set instructor name
    transformed['instructor'] = _extractInstructorName(course);
    
    // Safely convert numeric values
    transformed['price'] = _safeToDouble(course['price']);
    transformed['discountPrice'] = _safeToDouble(course['discountPrice']);
    transformed['rating'] = _safeToDouble(course['rating']);
    transformed['students'] = _safeToInt(course['students']);
    
    return transformed;
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

  Future<void> _fetchRecommendedCourses({bool isLoadMore = false}) async {
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

      // Fetch recommended courses from API
      final response = await _apiService.getRecommendedCourses(
        limit: limit,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        final List<Map<String, dynamic>> courses = response.data!;
        
        // Transform each course to extract instructor name
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
          _hasMore = courses.length >= limit;
          _isLoading = false;
          _isRefreshing = false;
          _isLoadingMore = false;
          _error = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isLoadingMore = false;
          _error = response.error ?? 'Failed to load recommended courses';
        });
        print('⚠️ Failed to load recommended courses: ${response.error}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _isLoadingMore = false;
        _error = e.toString();
      });
      print('❌ Error loading recommended courses: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    await _fetchRecommendedCourses();
  }

  void _loadMore() {
    if (!_isLoadingMore && _hasMore && !_isLoading && !_isRefreshing && _error == null) {
      _fetchRecommendedCourses(isLoadMore: true);
    }
  }

  void _toggleSave(String courseId) {
    setState(() {
      if (_savedCourses.contains(courseId)) {
        _savedCourses.remove(courseId);
      } else {
        _savedCourses.add(courseId);
      }
    });
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
    final backgroundColor = AppColors.getBackgroundColor(brightness);
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
      cardWidth = screenWidth * 0.70;
      cardHeight = screenHeight * 0.35;
      imageHeight = cardHeight * 0.45;
      fontSizeTitle = 13;
      fontSizeSubtitle = 11;
      fontSizeBadge = 9;
      fontSizePrice = 14;
      paddingSize = 8;
      gap = 10;
    } else if (screenWidth < 600) {
      cardWidth = screenWidth * 0.55;
      cardHeight = screenHeight * 0.37;
      imageHeight = cardHeight * 0.45;
      fontSizeTitle = 14;
      fontSizeSubtitle = 12;
      fontSizeBadge = 10;
      fontSizePrice = 15;
      paddingSize = 10;
      gap = 12;
    } else if (screenWidth < 900) {
      cardWidth = screenWidth * 0.35;
      cardHeight = screenHeight * 0.38;
      imageHeight = cardHeight * 0.45;
      fontSizeTitle = 15;
      fontSizeSubtitle = 13;
      fontSizeBadge = 11;
      fontSizePrice = 16;
      paddingSize = 12;
      gap = 16;
    } else {
      cardWidth = screenWidth * 0.25;
      cardHeight = screenHeight * 0.40;
      imageHeight = cardHeight * 0.45;
      fontSizeTitle = 16;
      fontSizeSubtitle = 14;
      fontSizeBadge = 12;
      fontSizePrice = 17;
      paddingSize = 14;
      gap = 18;
    }

    // Clamp values
    cardWidth = cardWidth.clamp(160.0, 350.0);
    cardHeight = cardHeight.clamp(200.0, 380.0);
    imageHeight = imageHeight.clamp(80.0, 170.0);

    if (_isLoading) {
      return _buildSkeletonLoading(isDark, cardWidth, cardHeight, brightness);
    }

    if (_error != null) {
      return _buildErrorState(isDark, brightness);
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
                child: Text(
                  'Recommended For You',
                  style: TextStyle(
                    fontSize: screenWidth < 380 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
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
                  final isSaved = _savedCourses.contains(course['id']);
                  return _buildCourseCard(
                    context,
                    course,
                    index,
                    isSaved,
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
    bool isSaved,
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
    
    // Safely extract data with null handling
    final hasDiscount = course['discountPrice'] != null && course['discountPrice'] > 0;
    final isBestseller = course['isBestseller'] ?? false;
    final price = _safeToDouble(course['price']);
    final discountPrice = _safeToDouble(course['discountPrice']);
    final rating = _safeToDouble(course['rating']);
    final students = _safeToInt(course['students']);
    final duration = course['duration']?.toString() ?? '2h 30m';
    final title = course['title']?.toString() ?? 'Untitled Course';
    final instructor = course['instructor']?.toString() ?? 'Unknown Instructor';
    final thumbnail = course['thumbnail']?.toString() ?? '';

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
                  child: thumbnail.isNotEmpty
                      ? Image.network(
                          thumbnail,
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
                // Bestseller Badge
                if (isBestseller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Bestseller',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeBadge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Save Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleSave(course['id']),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        size: 18,
                        color: isSaved ? primaryColor : textSecondaryColor,
                      ),
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
                      title,
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
                    // Instructor - Now properly displayed
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
                    // Rating and Duration
                    const SizedBox(height: 4),
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
                        Text(
                          '(${students.toString()})',
                          style: TextStyle(
                            fontSize: fontSizeSubtitle - 2,
                            color: textSecondaryColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          size: fontSizeSubtitle,
                          color: textSecondaryColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: fontSizeSubtitle - 2,
                            color: textSecondaryColor,
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
              Container(
                height: screenWidth < 380 ? 20 : 24,
                width: screenWidth < 380 ? 120 : 160,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
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
                    // Image Skeleton
                    Container(
                      height: cardHeight * 0.45,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    // Content Skeleton
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

  Widget _buildErrorState(bool isDark, Brightness brightness) {
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Recommended For You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: backgroundElementColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _error ?? 'Unknown error occurred',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
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
          child: Text(
            'Recommended For You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
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
                Icons.recommend_outlined,
                size: 48,
                color: textSecondaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                'No recommended courses available',
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