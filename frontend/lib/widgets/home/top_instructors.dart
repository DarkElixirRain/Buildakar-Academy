// lib/widgets/home/top_instructors.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';

class TopInstructors extends StatefulWidget {
  final List<Map<String, dynamic>> instructors;
  final Function(String) onFollowPress;
  final Function(String) onInstructorPress;
  final VoidCallback onSeeAll;

  const TopInstructors({
    Key? key,
    required this.instructors,
    required this.onFollowPress,
    required this.onInstructorPress,
    required this.onSeeAll,
  }) : super(key: key);

  @override
  State<TopInstructors> createState() => _TopInstructorsState();
}

class _TopInstructorsState extends State<TopInstructors> {
  late List<Map<String, dynamic>> _instructors;
  final ApiService _apiService = ApiService();
  final Map<String, bool> _followStatusMap = {};
  final Set<String> _loadingIds = {};
  
  // Keep track of the last widget instructors to detect changes
  List<Map<String, dynamic>>? _lastWidgetInstructors;

  @override
  void initState() {
    super.initState();
    _initializeInstructors();
    print('🔵 TopInstructors: initState called');
  }

  void _initializeInstructors() {
    print('🔵 TopInstructors: _initializeInstructors called');
    print('📊 Widget instructors count: ${widget.instructors.length}');
    
    _instructors = List.from(widget.instructors);
    
    // Only initialize the map if it's empty or if we have new instructors
    // This preserves the follow status across refreshes
    for (var instructor in _instructors) {
      final id = _getInstructorId(instructor);
      // Only add to map if not already present
      if (!_followStatusMap.containsKey(id)) {
        final isFollowing = instructor['isFollowing'] == true;
        _followStatusMap[id] = isFollowing;
        print('📊 New instructor: $id, isFollowing: $isFollowing');
      } else {
        // Keep the existing status from the map
        instructor['isFollowing'] = _followStatusMap[id] ?? false;
        print('📊 Existing instructor: $id, keeping status: ${_followStatusMap[id]}');
      }
    }
    
    // Remove instructors that are no longer in the list
    final currentIds = _instructors.map((e) => _getInstructorId(e)).toSet();
    _followStatusMap.keys.where((id) => !currentIds.contains(id)).toList().forEach((id) {
      _followStatusMap.remove(id);
      print('📊 Removed instructor $id from follow status map');
    });
    
    print('📊 Following count: ${_followStatusMap.values.where((v) => v).length}');
    _lastWidgetInstructors = List.from(widget.instructors);
  }

  @override
  void didUpdateWidget(TopInstructors oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('🔄 TopInstructors: didUpdateWidget called');
    
    // Check if the instructors list actually changed
    if (oldWidget.instructors != widget.instructors) {
      print('🔄 Instructors list changed, updating...');
      
      // Update the instructors list
      _instructors = List.from(widget.instructors);
      
      // For each instructor, keep the follow status from the map if it exists
      for (var instructor in _instructors) {
        final id = _getInstructorId(instructor);
        if (_followStatusMap.containsKey(id)) {
          // Use the status from our map
          instructor['isFollowing'] = _followStatusMap[id] ?? false;
          print('📊 Synced instructor $id to follow status: ${_followStatusMap[id]}');
        } else {
          // New instructor, add to map
          final isFollowing = instructor['isFollowing'] == true;
          _followStatusMap[id] = isFollowing;
          print('📊 Added new instructor $id to follow status map: $isFollowing');
        }
      }
      
      // Remove instructors that are no longer in the list
      final currentIds = _instructors.map((e) => _getInstructorId(e)).toSet();
      _followStatusMap.keys.where((id) => !currentIds.contains(id)).toList().forEach((id) {
        _followStatusMap.remove(id);
        print('📊 Removed instructor $id from follow status map');
      });
      
      _lastWidgetInstructors = List.from(widget.instructors);
    } else {
      print('🔄 Instructors list reference is the same, keeping current state');
    }
  }

  String _getInstructorName(Map<String, dynamic> instructor) {
    if (instructor['firstName'] != null && instructor['lastName'] != null) {
      return '${instructor['firstName']} ${instructor['lastName']}'.trim();
    }
    if (instructor['name'] != null && instructor['name'] is String) {
      return instructor['name'] as String;
    }
    if (instructor['fullName'] != null && instructor['fullName'] is String) {
      return instructor['fullName'] as String;
    }
    if (instructor['username'] != null && instructor['username'] is String) {
      return instructor['username'] as String;
    }
    return 'Instructor';
  }

  String _getInstructorId(Map<String, dynamic> instructor) {
    if (instructor['id'] != null && instructor['id'] is String) {
      return instructor['id'] as String;
    }
    if (instructor['instructorId'] != null && instructor['instructorId'] is String) {
      return instructor['instructorId'] as String;
    }
    if (instructor['userId'] != null && instructor['userId'] is String) {
      return instructor['userId'] as String;
    }
    return '';
  }

  String _getInstructorTitle(Map<String, dynamic> instructor) {
    if (instructor['title'] != null && instructor['title'] is String) {
      return instructor['title'] as String;
    }
    if (instructor['headline'] != null && instructor['headline'] is String) {
      return instructor['headline'] as String;
    }
    if (instructor['bio'] != null && instructor['bio'] is String) {
      final bio = instructor['bio'] as String;
      return bio.length > 30 ? '${bio.substring(0, 30)}...' : bio;
    }
    if (instructor['expertise'] != null && instructor['expertise'] is String) {
      return instructor['expertise'] as String;
    }
    return 'Instructor';
  }

  String _getImageUrl(Map<String, dynamic> instructor) {
    final imageFields = ['image', 'avatar', 'photo', 'profileImage', 'profilePicture', 'avatarUrl'];
    
    for (var field in imageFields) {
      if (instructor[field] != null && instructor[field] is String) {
        final value = instructor[field] as String;
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    
    final name = _getInstructorName(instructor);
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&size=150&background=4F46E5&color=fff';
  }

  double _getRating(Map<String, dynamic> instructor) {
    if (instructor['rating'] != null) {
      if (instructor['rating'] is double) return instructor['rating'] as double;
      if (instructor['rating'] is int) return (instructor['rating'] as int).toDouble();
      if (instructor['rating'] is String) {
        try {
          return double.parse(instructor['rating'] as String);
        } catch (_) {
          return 0.0;
        }
      }
    }
    if (instructor['averageRating'] != null) {
      if (instructor['averageRating'] is double) return instructor['averageRating'] as double;
      if (instructor['averageRating'] is int) return (instructor['averageRating'] as int).toDouble();
    }
    return 0.0;
  }

  int _getStudentsCount(Map<String, dynamic> instructor) {
    if (instructor['totalStudents'] != null) {
      if (instructor['totalStudents'] is int) return instructor['totalStudents'] as int;
      if (instructor['totalStudents'] is double) return (instructor['totalStudents'] as double).toInt();
    }
    if (instructor['studentsCount'] != null) {
      if (instructor['studentsCount'] is int) return instructor['studentsCount'] as int;
      if (instructor['studentsCount'] is double) return (instructor['studentsCount'] as double).toInt();
    }
    if (instructor['students'] != null) {
      if (instructor['students'] is int) return instructor['students'] as int;
      if (instructor['students'] is double) return (instructor['students'] as double).toInt();
    }
    return 0;
  }

  bool _isFollowing(Map<String, dynamic> instructor) {
    final id = _getInstructorId(instructor);
    // Use the follow status map as the source of truth
    final isFollowing = _followStatusMap[id] ?? false;
    return isFollowing;
  }

  bool _isLoading(String instructorId) {
    return _loadingIds.contains(instructorId);
  }

  Future<void> _handleFollowPress(String instructorId) async {
    print('🔄 _handleFollowPress called for instructor: $instructorId');
    
    if (_loadingIds.contains(instructorId)) {
      print('⏳ Already loading, ignoring click');
      return;
    }

    setState(() {
      _loadingIds.add(instructorId);
    });
    print('⏳ Loading started for: $instructorId');

    final bool wasFollowing = _followStatusMap[instructorId] ?? false;
    final bool newFollowState = !wasFollowing;
    
    print('📊 Current state: wasFollowing=$wasFollowing, newFollowState=$newFollowState');

    // Optimistically update UI
    setState(() {
      _followStatusMap[instructorId] = newFollowState;
      final index = _instructors.indexWhere((e) => _getInstructorId(e) == instructorId);
      if (index != -1) {
        _instructors[index]['isFollowing'] = newFollowState;
      }
      print('✅ Optimistically updated follow status for $instructorId to $newFollowState');
    });

    try {
      print('🌐 Calling API: toggleFollowInstructor for $instructorId');
      final response = await _apiService.toggleFollowInstructor(instructorId);
      
      print('📡 API Response:');
      print('   success: ${response.success}');
      print('   data: ${response.data}');
      print('   error: ${response.error}');
      print('   message: ${response.message}');

      if (!mounted) {
        print('❌ Widget not mounted after API call');
        setState(() {
          _loadingIds.remove(instructorId);
        });
        return;
      }

      if (response.success) {
        final isNowFollowing = response.data?['isFollowing'] ?? newFollowState;
        print('✅ API success: isNowFollowing=$isNowFollowing');
        
        setState(() {
          _followStatusMap[instructorId] = isNowFollowing;
          final index = _instructors.indexWhere((e) => _getInstructorId(e) == instructorId);
          if (index != -1) {
            _instructors[index]['isFollowing'] = isNowFollowing;
          }
          _loadingIds.remove(instructorId);
          print('✅ Updated follow status for $instructorId to $isNowFollowing');
        });

        // Call parent to update parent state
        widget.onFollowPress(instructorId);
        print('✅ Called parent onFollowPress for $instructorId');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowFollowing 
                  ? 'Now following this instructor' 
                  : 'Unfollowed instructor',
            ),
            backgroundColor: isNowFollowing ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        print('❌ API error: ${response.error}');
        setState(() {
          _followStatusMap[instructorId] = wasFollowing;
          final index = _instructors.indexWhere((e) => _getInstructorId(e) == instructorId);
          if (index != -1) {
            _instructors[index]['isFollowing'] = wasFollowing;
          }
          _loadingIds.remove(instructorId);
          print('↩️ Reverted follow status for $instructorId to $wasFollowing');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to update follow status'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Exception in _handleFollowPress:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      
      setState(() {
        _followStatusMap[instructorId] = wasFollowing;
        final index = _instructors.indexWhere((e) => _getInstructorId(e) == instructorId);
        if (index != -1) {
          _instructors[index]['isFollowing'] = wasFollowing;
        }
        _loadingIds.remove(instructorId);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔵 TopInstructors: build called, instructors count: ${_instructors.length}');
    print('📊 Follow status map: $_followStatusMap');
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final screenWidth = MediaQuery.of(context).size.width;
    
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 480;
    final cardWidth = isSmallScreen ? 140.0 : (isMediumScreen ? 155.0 : 170.0);
    final cardHeight = isSmallScreen ? 195.0 : (isMediumScreen ? 210.0 : 230.0);
    final imageSize = isSmallScreen ? 50.0 : (isMediumScreen ? 58.0 : 65.0);
    final fontSize = isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0);
    final titleFontSize = isSmallScreen ? 9.0 : (isMediumScreen ? 10.0 : 11.0);
    final buttonWidth = isSmallScreen ? 90.0 : (isMediumScreen ? 100.0 : 110.0);
    final ratingFontSize = isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0);
    final studentFontSize = isSmallScreen ? 8.0 : (isMediumScreen ? 9.0 : 10.0);
    final iconSize = isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final seeAllFontSize = isSmallScreen ? 12.0 : 14.0;
    final titleSize = isSmallScreen ? 16.0 : 18.0;
    final buttonTextSize = isSmallScreen ? 10.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Instructors',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: widget.onSeeAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: seeAllFontSize,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: _instructors.isEmpty
              ? Center(
                  child: Text(
                    'No instructors available',
                    style: TextStyle(
                      color: textSecondaryColor,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: _instructors.length,
                  itemBuilder: (context, index) {
                    final instructor = _instructors[index];
                    return _buildInstructorCard(
                      context, 
                      instructor,
                      cardWidth: cardWidth,
                      imageSize: imageSize,
                      fontSize: fontSize,
                      titleFontSize: titleFontSize,
                      buttonWidth: buttonWidth,
                      ratingFontSize: ratingFontSize,
                      studentFontSize: studentFontSize,
                      iconSize: iconSize,
                      buttonTextSize: buttonTextSize,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInstructorCard(
    BuildContext context, 
    Map<String, dynamic> instructor, {
    required double cardWidth,
    required double imageSize,
    required double fontSize,
    required double titleFontSize,
    required double buttonWidth,
    required double ratingFontSize,
    required double studentFontSize,
    required double iconSize,
    required double buttonTextSize,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);
    
    final name = _getInstructorName(instructor);
    final instructorId = _getInstructorId(instructor);
    final imageUrl = _getImageUrl(instructor);
    final title = _getInstructorTitle(instructor);
    final rating = _getRating(instructor);
    final students = _getStudentsCount(instructor);
    final isFollowing = _isFollowing(instructor);
    final isLoading = _isLoading(instructorId);

    final avatarTextSize = imageSize * 0.4;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          if (instructorId.isNotEmpty) {
            widget.onInstructorPress(instructorId);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: backgroundElementColor,
            borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Image
              ClipOval(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: imageSize,
                            height: imageSize,
                            color: primaryColor.withValues(alpha: 0.2),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: avatarTextSize,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: imageSize,
                            height: imageSize,
                            color: backgroundSelectedColor,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: imageSize,
                        height: imageSize,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: avatarTextSize,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              
              // Name
              Text(
                name,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: textSecondaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              
              // Rating and Students
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star, 
                    color: Colors.amber, 
                    size: iconSize,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: ratingFontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$students',
                    style: TextStyle(
                      fontSize: studentFontSize,
                      color: textSecondaryColor,
                    ),
                  ),
                  Icon(
                    Icons.person_outline,
                    size: iconSize - 2.0,
                    color: textSecondaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Follow Button with loading state
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    if (instructorId.isNotEmpty) {
                      _handleFollowPress(instructorId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing 
                        ? backgroundSelectedColor
                        : primaryColor,
                    foregroundColor: isFollowing 
                        ? textColor
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    disabledBackgroundColor: backgroundSelectedColor,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isFollowing ? textColor : Colors.white,
                          ),
                        )
                      : Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: TextStyle(
                            fontSize: buttonTextSize,
                            fontWeight: FontWeight.w600,
                            color: isFollowing 
                                ? textColor
                                : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}