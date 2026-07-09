// lib/screens/instructor/instructors_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/common/error_state.dart';

class InstructorsScreen extends StatefulWidget {
  const InstructorsScreen({Key? key}) : super(key: key);

  @override
  State<InstructorsScreen> createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _instructors = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  Future<void> _loadInstructors() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getTopInstructors(limit: 50);
      
      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _instructors = response.data!;
          _isLoading = false;
        });
        print('✅ Loaded ${_instructors.length} instructors');
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load instructors';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
      print('❌ Error loading instructors: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadInstructors();
    
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _handleInstructorPress(String instructorId) {
    Navigator.pushNamed(
      context,
      '/instructor',
      arguments: {'instructorId': instructorId},
    );
  }

  Future<void> _handleFollowPress(String instructorId) async {
    try {
      final response = await _apiService.toggleFollowInstructor(instructorId);
      
      if (response.success) {
        // Update local state
        setState(() {
          final index = _instructors.indexWhere((e) => _getId(e) == instructorId);
          if (index != -1) {
            final currentStatus = _instructors[index]['isFollowing'] ?? false;
            _instructors[index]['isFollowing'] = !currentStatus;
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Follow status updated'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to update follow status'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getId(Map<String, dynamic> instructor) {
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

  String _getName(Map<String, dynamic> instructor) {
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

  String _getTitle(Map<String, dynamic> instructor) {
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
    
    final name = _getName(instructor);
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
    return 0.0;
  }

  int _getStudentsCount(Map<String, dynamic> instructor) {
    if (instructor['studentsCount'] != null) {
      if (instructor['studentsCount'] is int) return instructor['studentsCount'] as int;
      if (instructor['studentsCount'] is double) return (instructor['studentsCount'] as double).toInt();
      if (instructor['studentsCount'] is String) {
        try {
          return int.parse(instructor['studentsCount'] as String);
        } catch (_) {
          return 0;
        }
      }
    }
    if (instructor['students'] != null) {
      if (instructor['students'] is int) return instructor['students'] as int;
      if (instructor['students'] is double) return (instructor['students'] as double).toInt();
      if (instructor['students'] is String) {
        try {
          return int.parse(instructor['students'] as String);
        } catch (_) {
          return 0;
        }
      }
    }
    return 0;
  }

  bool _isFollowing(Map<String, dynamic> instructor) {
    return instructor['isFollowing'] == true;
  }

  List<Map<String, dynamic>> get _filteredInstructors {
    if (_searchQuery.isEmpty) return _instructors;
    return _instructors.where((instructor) {
      final name = _getName(instructor).toLowerCase();
      final title = _getTitle(instructor).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || title.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate responsive crossAxisCount
    int crossAxisCount = 2;
    if (screenWidth >= 600) {
      crossAxisCount = 3;
    }
    if (screenWidth >= 900) {
      crossAxisCount = 4;
    }
    if (screenWidth >= 1200) {
      crossAxisCount = 5;
    }

    // Show skeleton loading
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(context, isDark),
        body: _buildSkeletonLoading(context, isDark, crossAxisCount),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: _buildAppBar(context, isDark),
        body: ErrorState(
          message: _error!,
          onRetry: _loadInstructors,
        ),
      );
    }

    final filteredInstructors = _filteredInstructors;

    return Scaffold(
      appBar: _buildAppBar(context, isDark),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.getPrimaryColor(brightness),
        child: Column(
          children: [
            // Search Bar - Responsive padding
            _buildSearchBar(context, isDark),
            
            // Results count
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 24 : 16, 
                vertical: 8
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredInstructors.length} ${filteredInstructors.length == 1 ? 'Instructor' : 'Instructors'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondaryColor(brightness),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.getPrimaryColor(brightness),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Grid of instructors - Responsive
            Expanded(
              child: filteredInstructors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_rounded,
                            size: 64,
                            color: AppColors.getTextSecondaryColor(brightness),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No instructors found for "$_searchQuery"'
                                : 'No instructors available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getTextSecondaryColor(brightness),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Text(
                                'Clear search',
                                style: TextStyle(
                                  color: AppColors.getPrimaryColor(brightness),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(screenWidth > 600 ? 24 : 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: screenWidth > 600 ? 16 : 12,
                        mainAxisSpacing: screenWidth > 600 ? 16 : 12,
                      ),
                      itemCount: filteredInstructors.length,
                      itemBuilder: (context, index) {
                        final instructor = filteredInstructors[index];
                        return _buildInstructorCard(context, instructor, isDark, screenWidth);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(BuildContext context, bool isDark, int crossAxisCount) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        // Search bar skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 24 : 16, vertical: 8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundElementColor(brightness),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search_rounded,
                  color: AppColors.getTextSecondaryColor(brightness),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 16,
                    color: AppColors.getBackgroundSelectedColor(brightness),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
        
        // Results count skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 24 : 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                height: 16,
                color: AppColors.getBackgroundSelectedColor(brightness),
              ),
            ],
          ),
        ),
        
        // Grid skeleton
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(screenWidth > 600 ? 24 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: screenWidth > 600 ? 16 : 12,
              mainAxisSpacing: screenWidth > 600 ? 16 : 12,
            ),
            itemCount: 6, // Show 6 skeleton items
            itemBuilder: (context, index) {
              return _buildSkeletonCard(context, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard(BuildContext context, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundElementColor(brightness),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getBackgroundSelectedColor(brightness),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar skeleton
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSelectedColor(brightness),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          
          // Name skeleton
          Container(
            width: 80,
            height: 14,
            color: AppColors.getBackgroundSelectedColor(brightness),
          ),
          const SizedBox(height: 4),
          
          // Title skeleton
          Container(
            width: 60,
            height: 11,
            color: AppColors.getBackgroundSelectedColor(brightness),
          ),
          const SizedBox(height: 8),
          
          // Rating skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 12,
                color: AppColors.getBackgroundSelectedColor(brightness),
              ),
              const SizedBox(width: 8),
              Container(
                width: 50,
                height: 10,
                color: AppColors.getBackgroundSelectedColor(brightness),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Button skeleton
          Container(
            width: 100,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSelectedColor(brightness),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    return AppBar(
      title: Text(
        'Instructors',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.getTextColor(brightness),
        ),
      ),
      backgroundColor: AppColors.getBackgroundColor(brightness),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: AppColors.getTextColor(brightness),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? 24 : 16, 
        vertical: 8
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getBackgroundElementColor(brightness),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.getBackgroundSelectedColor(brightness),
            width: 1,
          ),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search instructors...',
            hintStyle: TextStyle(
              color: AppColors.getTextSecondaryColor(brightness),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.getTextSecondaryColor(brightness),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppColors.getTextSecondaryColor(brightness),
                    ),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
          style: TextStyle(
            color: AppColors.getTextColor(brightness),
            fontSize: 16,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildInstructorCard(
    BuildContext context,
    Map<String, dynamic> instructor,
    bool isDark,
    double screenWidth,
  ) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    // Get all values safely
    final id = _getId(instructor);
    final name = _getName(instructor);
    final imageUrl = _getImageUrl(instructor);
    final title = _getTitle(instructor);
    final rating = _getRating(instructor);
    final students = _getStudentsCount(instructor);
    final isFollowing = _isFollowing(instructor);

    // Responsive sizes
    final avatarSize = screenWidth > 600 ? 80.0 : 70.0;
    final fontSizeName = screenWidth > 600 ? 16.0 : 14.0;
    final fontSizeTitle = screenWidth > 600 ? 12.0 : 11.0;
    final fontSizeRating = screenWidth > 600 ? 13.0 : 12.0;
    final buttonWidth = screenWidth > 600 ? 120.0 : 100.0;

    return GestureDetector(
      onTap: () {
        if (id.isNotEmpty) {
          _handleInstructorPress(id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getBackgroundElementColor(brightness),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.getBackgroundSelectedColor(brightness),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Image
            ClipOval(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: avatarSize,
                      height: avatarSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: avatarSize,
                          height: avatarSize,
                          color: AppColors.getPrimaryColor(brightness).withValues(alpha: 0.2),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontSize: avatarSize * 0.4,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getPrimaryColor(brightness),
                              ),
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: avatarSize,
                          height: avatarSize,
                          color: AppColors.getBackgroundSelectedColor(brightness),
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
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(brightness).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: avatarSize * 0.4,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getPrimaryColor(brightness),
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
                fontSize: fontSizeName,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(brightness),
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
                fontSize: fontSizeTitle,
                color: AppColors.getTextSecondaryColor(brightness),
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
                  size: fontSizeRating,
                ),
                const SizedBox(width: 2),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: fontSizeRating,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(brightness),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$students ${students == 1 ? 'student' : 'students'}',
                  style: TextStyle(
                    fontSize: fontSizeRating - 2,
                    color: AppColors.getTextSecondaryColor(brightness),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Follow Button
            SizedBox(
              width: buttonWidth,
              height: 32,
              child: ElevatedButton(
                onPressed: () {
                  if (id.isNotEmpty) {
                    _handleFollowPress(id);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing 
                      ? AppColors.getBackgroundSelectedColor(brightness)
                      : AppColors.getPrimaryColor(brightness),
                  foregroundColor: isFollowing 
                      ? AppColors.getTextColor(brightness)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    color: isFollowing 
                        ? AppColors.getTextColor(brightness)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}