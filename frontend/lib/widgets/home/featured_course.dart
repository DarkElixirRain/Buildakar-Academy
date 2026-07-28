// lib/widgets/home/featured_course.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../providers/theme_provider.dart';

class FeaturedCourses extends StatefulWidget {
  final Function(String) onCoursePress;
  final VoidCallback onSeeAll;

  const FeaturedCourses({
    Key? key,
    required this.onCoursePress,
    required this.onSeeAll,
  }) : super(key: key);

  @override
  State<FeaturedCourses> createState() => _FeaturedCoursesState();
}

class _FeaturedCoursesState extends State<FeaturedCourses> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchFeaturedCourses();
  }

  Future<void> _fetchFeaturedCourses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch public courses and display them as featured
      final response = await _apiService.getPublicCourses(
        limit: 10,
        sortBy: 'popular', // Sort by popularity
      );

      if (!mounted) return;

      if (response.success) {
        final data = response.data;
        final List<dynamic> courses = data?['data'] ?? [];
        
        // Transform courses to match the expected format
        _courses = courses.map((course) {
          return _transformCourseData(course);
        }).toList();
        
        setState(() {
          _isLoading = false;
          _error = null;
        });
        print('✅ Loaded ${_courses.length} featured courses');
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load featured courses';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('❌ Error loading featured courses: $e');
    }
  }

  Map<String, dynamic> _transformCourseData(Map<String, dynamic> course) {
    // --- FIX: Better instructor extraction ---
    String instructorName = 'Unknown Instructor';
    String instructorId = '';
    
    // Try to get instructor from nested object
    if (course['instructor'] != null) {
      if (course['instructor'] is Map<String, dynamic>) {
        final instructor = course['instructor'] as Map<String, dynamic>;
        // Try different field names
        instructorName = instructor['fullName'] ?? 
                        instructor['name'] ?? 
                        instructor['firstName'] != null && instructor['lastName'] != null
                            ? '${instructor['firstName']} ${instructor['lastName']}'
                            : instructor['username'] ?? 
                            'Unknown Instructor';
        instructorId = instructor['id'] ?? '';
      } else if (course['instructor'] is String) {
        instructorName = course['instructor'] as String;
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
        instructorId = course['instructorId'].toString();
        instructorName = 'Instructor ${instructorId.substring(0, 4)}';
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

    // --- Get rating ---
    double rating = 0.0;
    if (course['rating'] != null) {
      if (course['rating'] is double) {
        rating = course['rating'];
      } else if (course['rating'] is int) {
        rating = (course['rating'] as int).toDouble();
      } else if (course['rating'] is num) {
        rating = (course['rating'] as num).toDouble();
      } else if (course['rating'] is String) {
        try {
          rating = double.parse(course['rating'] as String);
        } catch (_) {
          rating = 0.0;
        }
      }
    }

    // --- Get students count ---
    int students = 0;
    if (course['_count'] != null && course['_count']['enrollments'] != null) {
      students = course['_count']['enrollments'];
    } else if (course['studentsCount'] != null) {
      if (course['studentsCount'] is int) {
        students = course['studentsCount'];
      } else if (course['studentsCount'] is num) {
        students = (course['studentsCount'] as num).toInt();
      }
    } else if (course['students'] != null) {
      if (course['students'] is int) {
        students = course['students'];
      } else if (course['students'] is num) {
        students = (course['students'] as num).toInt();
      }
    }

    // --- Get price with Nepali Rupees (रू) ---
    String price = 'Free';
    if (course['price'] != null) {
      if (course['price'] is num) {
        final priceNum = course['price'] as num;
        if (priceNum > 0) {
          // Format as NPR with रू symbol
          price = 'रू ${_formatCurrency(priceNum)}';
        }
      } else if (course['price'] is String) {
        final priceStr = course['price'] as String;
        if (priceStr.isNotEmpty && priceStr != '0' && priceStr != '0.0') {
          try {
            final priceNum = double.parse(priceStr);
            if (priceNum > 0) {
              price = 'रू ${_formatCurrency(priceNum)}';
            }
          } catch (_) {
            price = priceStr;
          }
        }
      }
    }

    // --- Get thumbnail ---
    String thumbnail = '';
    if (course['thumbnail'] != null && course['thumbnail'].toString().isNotEmpty) {
      thumbnail = course['thumbnail'].toString();
    } else if (course['thumbnailUrl'] != null && course['thumbnailUrl'].toString().isNotEmpty) {
      thumbnail = course['thumbnailUrl'].toString();
    } else if (course['image'] != null && course['image'].toString().isNotEmpty) {
      thumbnail = course['image'].toString();
    }

    // If no thumbnail, use placeholder
    if (thumbnail.isEmpty) {
      thumbnail = 'https://picsum.photos/400/200?random=${course['id'] ?? '1'}';
    }

    // --- Determine badge based on course stats ---
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

    // --- Get level ---
    String level = 'Beginner';
    if (course['level'] != null && course['level'].toString().isNotEmpty) {
      level = course['level'].toString();
    }

    // --- Get category ---
    String category = 'General';
    if (course['category'] != null) {
      if (course['category'] is Map<String, dynamic>) {
        category = course['category']['name'] ?? 'General';
      } else if (course['category'] is String) {
        category = course['category'] as String;
      }
    }

    print('📝 Course: ${course['title']} - Instructor: $instructorName');

    return {
      'id': course['id'] ?? '',
      'title': course['title'] ?? 'Untitled Course',
      'image': thumbnail,
      'rating': rating,
      'students': students,
      'price': price,
      'badge': badge,
      'instructor': instructorName,
      'instructorId': instructorId,
      'level': level,
      'category': category,
      'description': course['description'] ?? '',
    };
  }

  // Helper method to format currency with proper spacing
  String _formatCurrency(num amount) {
    // Convert to double for formatting
    final double amountDouble = amount.toDouble();
    
    // Format with 2 decimal places if needed
    if (amountDouble == amountDouble.roundToDouble()) {
      // Whole number - no decimals
      return amountDouble.toStringAsFixed(0);
    } else {
      // Has decimals - show 2 decimal places
      return amountDouble.toStringAsFixed(2);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _fetchFeaturedCourses();
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _handleCoursePress(String courseId) {
    if (courseId.isNotEmpty) {
      widget.onCoursePress(courseId);
    }
  }

  void _handleSeeAll() {
    widget.onSeeAll();
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

    // Show loading state
    if (_isLoading) {
      return _buildSkeletonLoading(
        isDark, 
        cardWidth, 
        cardHeight, 
        imageHeight, 
        screenWidth,
        brightness,
      );
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
                child: Text(
                  'Featured Courses',
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
          height: cardHeight + 10,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: primaryColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _courses.length,
              padding: const EdgeInsets.only(right: 16),
              itemBuilder: (context, index) {
                final course = _courses[index];
                return _buildFeaturedCard(
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
      ],
    );
  }

  Widget _buildFeaturedCard(
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

    return GestureDetector(
      onTap: () => _handleCoursePress(course['id']),
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
            // Image Section with Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: course['image'] != null && course['image'].toString().isNotEmpty
                      ? Image.network(
                          course['image'],
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
                      course['badge'] ?? '📚 Course',
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
                    child: Text(
                      course['price'] ?? 'Free',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeBadge + 1,
                        fontWeight: FontWeight.bold,
                      ),
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
                    // Instructor - FIXED: Display properly
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
                            course['instructor'] ?? 'Unknown Instructor',
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
                          course['rating']?.toStringAsFixed(1) ?? '0.0',
                          style: TextStyle(
                            fontSize: fontSizeSubtitle,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${course['students'] ?? 0} students',
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

  Widget _buildSkeletonLoading(
    bool isDark,
    double cardWidth,
    double cardHeight,
    double imageHeight,
    double screenWidth,
    Brightness brightness,
  ) {
    final textColor = AppColors.getTextColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: screenWidth < 380 ? 20 : 24,
                width: screenWidth < 380 ? 120 : 160,
                decoration: BoxDecoration(
                  color: backgroundSelectedColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: screenWidth < 380 ? 14 : 18,
                width: screenWidth < 380 ? 50 : 60,
                decoration: BoxDecoration(
                  color: backgroundSelectedColor,
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
                      height: imageHeight,
                      decoration: BoxDecoration(
                        color: backgroundSelectedColor,
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
                                color: backgroundSelectedColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 10,
                              width: 100,
                              decoration: BoxDecoration(
                                color: backgroundSelectedColor,
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
                                    color: backgroundSelectedColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 10,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: backgroundSelectedColor,
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
          child: Text(
            'Featured Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
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
                'Unable to Load Courses',
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
                onPressed: _fetchFeaturedCourses,
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