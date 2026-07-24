import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/instructor_service.dart';
import '../../services/course_service.dart';
import '../../services/api_service.dart';
import '../../models/course_model.dart';
import '../../widgets/explore/course_card.dart';
import '../../widgets/course/course_reviews.dart';
import '../../widgets/common/error_state.dart';

class InstructorProfileScreen extends StatefulWidget {
  final String instructorId;

  const InstructorProfileScreen({
    Key? key,
    required this.instructorId,
  }) : super(key: key);

  @override
  State<InstructorProfileScreen> createState() => _InstructorProfileScreenState();
}

class _InstructorProfileScreenState extends State<InstructorProfileScreen>
    with TickerProviderStateMixin {
  final InstructorApiService _instructorService = InstructorApiService();
  final CourseApiService _courseService = CourseApiService();

  Map<String, dynamic>? _instructorData;
  List<dynamic> _instructorCourses = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  // Instructor reviews
  List<Map<String, dynamic>> _instructorReviews = [];
  bool _isLoadingReviews = false;
  int _totalReviews = 0;
  double _instructorAvgRating = 0.0;

  final ApiService _apiService = ApiService();

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    print('🔍 InstructorProfileScreen: initState called');
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _loadInstructorData();
  }

  void _onTabChanged() {
    if (_tabController.index == 2 && _instructorReviews.isEmpty && !_isLoadingReviews) {
      _loadInstructorReviews();
    }
  }

  String _getInstructorId(Map<String, dynamic> instructor) {
    if (instructor['id'] != null && instructor['id'] is String) {
      return instructor['id'] as String;
    }
    if (instructor['instructorId'] != null &&
        instructor['instructorId'] is String) {
      return instructor['instructorId'] as String;
    }
    if (instructor['userId'] != null &&
        instructor['userId'] is String) {
      return instructor['userId'] as String;
    }
    return '';
  }

  Future<void> _loadInstructorData() async {
    if (!mounted) return;

    print('🔍 InstructorProfileScreen: Loading instructor data for ID: ${widget.instructorId}');

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      // Fetch instructor details
      print('🔍 InstructorProfileScreen: Calling getInstructorById');
      final instructorResponse =
          await _instructorService.getInstructorById(widget.instructorId);
      print('🔍 InstructorProfileScreen: getInstructorById response: success=${instructorResponse.success}, data=${instructorResponse.data != null ? 'present' : 'null'}');
      if (!mounted) return;

      if (instructorResponse.success && instructorResponse.data != null) {
        print('🔍 InstructorProfileScreen: Setting instructor data');
        setState(() {
          _instructorData = instructorResponse.data as Map<String, dynamic>;
          // Extract courses from instructor data if available
          final courses = _instructorData?['courses'] as List<dynamic>?;
          if (courses != null && courses.isNotEmpty) {
            _instructorCourses = courses;
            print('🔍 InstructorProfileScreen: Found ${courses.length} courses in instructor data');
          }
          _isLoading = false;
        });
        print('🔍 InstructorProfileScreen: Instructor data loaded successfully');
      } else {
        print('🔍 InstructorProfileScreen: Failed to load instructor: ${instructorResponse.error}');
        throw Exception(instructorResponse.error ?? 'Failed to load instructor');
      }

      // If no courses in instructor data, fetch from course service
      if (_instructorCourses.isEmpty) {
        print('🔍 InstructorProfileScreen: No courses in instructor data, fetching from course service');
        await _loadInstructorCourses();
      }
    } catch (e) {
      if (!mounted) return;
      print('🔍 InstructorProfileScreen: Error loading instructor data: $e');
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadInstructorCourses() async {
    try {
      print('🔍 InstructorProfileScreen: Loading instructor courses for ID: ${widget.instructorId}');
      // Fetch courses for this instructor
      final coursesResponse = await _courseService.getInstructorPublicCourses(
        instructorId: widget.instructorId,
        limit: 20, // Limit to 20 courses for now
      );
      print('🔍 InstructorProfileScreen: getInstructorPublicCourses response: success=${coursesResponse.success}, data=${coursesResponse.data != null ? 'present' : 'null'}');
      if (!mounted) return;

      if (coursesResponse.success &&
          coursesResponse.data != null &&
          coursesResponse.data!['data'] != null) {
        final data = coursesResponse.data as Map<String, dynamic>;
        final courses = data['data'] as List<dynamic>?;
        if (courses != null) {
          print('🔍 InstructorProfileScreen: Found ${courses.length} courses from course service');
          setState(() {
            _instructorCourses = courses;
          });
        }
      } else {
        print('🔍 InstructorProfileScreen: No courses found from course service');
      }
    } catch (e) {
      // Non-fatal: we might still have instructor data
      print('🔍 InstructorProfileScreen: Error loading instructor courses: $e');
      debugPrint('Failed to load instructor courses: $e');
    }
  }

  Future<void> _loadInstructorReviews() async {
    if (_isLoadingReviews) return;
    setState(() => _isLoadingReviews = true);

    try {
      final instructorId = _instructorData != null
          ? _getInstructorId(_instructorData!)
          : widget.instructorId;
      final response = await _apiService.getInstructorReviews(
        instructorId: instructorId,
        page: 1,
        limit: 20,
      );
      if (!mounted) return;

      if (response.success && response.data != null) {
        final data = response.data!;
        final reviewsList = (data['data'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ?? [];
        final meta = data['meta'] as Map<String, dynamic>?;
        setState(() {
          _instructorReviews = reviewsList;
          _totalReviews = meta?['total'] as int? ?? 0;
          _instructorAvgRating = (meta?['averageRating'] as num?)?.toDouble() ?? 0.0;
          _isLoadingReviews = false;
        });
      } else {
        setState(() => _isLoadingReviews = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingReviews = false);
    }
  }

  @override
  void dispose() {
    print('🔍 InstructorProfileScreen: dispose called');
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow() async {
    if (_instructorData == null) return;

    final instructorId = _getInstructorId(_instructorData!);
    if (instructorId.isEmpty) return;

    final isCurrentlyFollowing = _isFollowing(_instructorData!);

    // Optimistically update UI
    setState(() {
      _instructorData!['isFollowing'] = !isCurrentlyFollowing;
    });

    try {
      final response = await _instructorService.toggleFollowInstructor(
        instructorId,
      );
      if (!mounted) return;

      if (response.success) {
        final newIsFollowing =
            response.data?['isFollowing'] ?? !isCurrentlyFollowing;
        final newFollowersCount =
            response.data?['followersCount'] as int?;
        setState(() {
          _instructorData!['isFollowing'] = newIsFollowing;
          if (newFollowersCount != null) {
            _instructorData!['followersCount'] = newFollowersCount;
          }
        });
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newIsFollowing
                  ? 'Now following this instructor'
                  : 'Unfollowed instructor',
            ),
            backgroundColor: newIsFollowing ? Colors.green : Colors.orange,
          ),
        );
      } else {
        // Revert the optimistic update
        setState(() {
          _instructorData!['isFollowing'] = isCurrentlyFollowing;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ??
                  'Failed to update follow status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Revert the optimistic update
      setState(() {
        _instructorData!['isFollowing'] = isCurrentlyFollowing;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getInstructorName(Map<String, dynamic> instructor) {
    if (instructor['firstName'] != null &&
        instructor['lastName'] != null) {
      return '${instructor['firstName']} ${instructor['lastName']}'.trim();
    }
    if (instructor['name'] != null &&
        instructor['name'] is String) {
      return instructor['name'] as String;
    }
    if (instructor['fullName'] != null &&
        instructor['fullName'] is String) {
      return instructor['fullName'] as String;
    }
    return 'Instructor';
  }

  String _getInstructorTitle(Map<String, dynamic> instructor) {
    if (instructor['title'] != null &&
        instructor['title'] is String) {
      return instructor['title'] as String;
    }
    if (instructor['headline'] != null &&
        instructor['headline'] is String) {
      return instructor['headline'] as String;
    }
    if (instructor['bio'] != null &&
        instructor['bio'] is String) {
      final bio = instructor['bio'] as String;
      return bio.length > 30
          ? '${bio.substring(0, 30)}...'
          : bio;
    }
    return 'Instructor';
  }

  String _getInstructorImageUrl(Map<String, dynamic> instructor) {
    const imageFields = [
      'image',
      'avatar',
      'photo',
      'profileImage',
      'profilePicture',
      'avatarUrl'
    ];
    for (final field in imageFields) {
      if (instructor[field] != null &&
          instructor[field] is String) {
        final value = instructor[field] as String;
        if (value.isNotEmpty) return value;
      }
    }
    final name = _getInstructorName(instructor);
    return 'https://ui-avatars.com/api/?name=' +
        '${Uri.encodeComponent(name)}&size=200&background=4F46E5&color=fff';
  }

  bool _isFollowing(Map<String, dynamic> instructor) {
    return instructor['isFollowing'] == true;
  }

  int _getFollowersCount(Map<String, dynamic> instructor) {
    if (instructor['followersCount'] != null) {
      if (instructor['followersCount'] is int) {
        return instructor['followersCount'] as int;
      }
      if (instructor['followersCount'] is double) {
        return (instructor['followersCount'] as double).toInt();
      }
    }
    return 0;
  }

  int _getCoursesCount(Map<String, dynamic> instructor) {
    if (instructor['coursesCount'] != null) {
      if (instructor['coursesCount'] is int) {
        return instructor['coursesCount'] as int;
      }
      if (instructor['coursesCount'] is double) {
        return (instructor['coursesCount'] as double).toInt();
      }
    }
    // Fallback to actual courses list length
    return _instructorCourses.length;
  }

  int _getStudentsCount(Map<String, dynamic> instructor) {
    if (instructor['studentsCount'] != null) {
      if (instructor['studentsCount'] is int) {
        return instructor['studentsCount'] as int;
      }
      if (instructor['studentsCount'] is double) {
        return (instructor['studentsCount'] as double).toInt();
      }
    }
    return 0;
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildHeader(
      BuildContext context,
      String imageUrl,
      String name,
      String title,
      bool isFollowing,
      int followersCount,
      int coursesCount,
      int studentsCount,
      bool isDark,
      Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          // Follow button and stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Follow button
              ElevatedButton.icon(
                onPressed: _toggleFollow,
                icon: Icon(
                  isFollowing ? Icons.check : Icons.person_add,
                  size: 20,
                ),
                label: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: isFollowing
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      _formatCount(coursesCount),
                      'Courses',
                      Icons.menu_book,
                      isDark,
                      brightness,
                    ),
                    _buildStatColumn(
                      _formatCount(studentsCount),
                      'Students',
                      Icons.people,
                      isDark,
                      brightness,
                    ),
                    _buildStatColumn(
                      _formatCount(followersCount),
                      'Followers',
                      Icons.person,
                      isDark,
                      brightness,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
      String value, String label, IconData icon, bool isDark, Brightness brightness) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context, bool isDark, Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor:
            Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 16),
        tabs: const [
          Tab(text: 'Courses'),
          Tab(text: 'Reviews'),
          Tab(text: 'About'),
        ],
      ),
    );
  }

  Widget _buildCoursesTab(
      BuildContext context, bool isDark, Brightness brightness) {
    if (_instructorCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No courses available',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _instructorCourses.length,
      itemBuilder: (context, index) {
        final courseData = _instructorCourses[index] as Map<String, dynamic>;
        return CourseCard(
          course: courseData,
          onTap: () {
            // Navigate to course detail
            final courseId = courseData['id'] as String?;
            if (courseId != null && courseId.isNotEmpty) {
              // For now, we'll just show a snackbar since the course detail screen doesn't exist yet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Course details screen not implemented yet'),
                  backgroundColor: Colors.orange,
                ),
              );
              // Uncomment the line below when the course detail screen is implemented
              /*
              Navigator.pushNamed(
                context,
                AppRoutes.course,
                arguments: {AppRoutes.argCourseId: courseId},
              );
              */
            }
          },
        );
      },
    );
  }

  Widget _buildInstructorReviewsTab(
      BuildContext context, bool isDark, Brightness brightness) {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_instructorReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reviews from students will appear here',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final reviews = _instructorReviews
        .map((r) => Review.fromJson(r))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CourseReviews(
        rating: _instructorAvgRating,
        reviews: reviews,
        brightness: brightness,
      ),
    );
  }

  Widget _buildAboutTab(
      BuildContext context, bool isDark, Brightness brightness) {
    final instructor = _instructorData!;
    final bio = instructor['bio'] ?? 'No biography available.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            bio,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // TODO: Add social media links if available
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 InstructorProfileScreen: build called. _isLoading=$_isLoading, _isError=$_isError, _instructorData!=null=${_instructorData != null}');
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Profile'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? ErrorState(
                  message: _errorMessage,
                  onRetry: _loadInstructorData,
                )
              : _instructorData == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        _buildHeader(
                          context,
                          _getInstructorImageUrl(_instructorData!),
                          _getInstructorName(_instructorData!),
                          _getInstructorTitle(_instructorData!),
                          _isFollowing(_instructorData!),
                          _getFollowersCount(_instructorData!),
                          _getCoursesCount(_instructorData!),
                          _getStudentsCount(_instructorData!),
                          isDark,
                          brightness,
                        ),
                        _buildTabs(context, isDark, brightness),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildCoursesTab(context, isDark, brightness),
                              _buildInstructorReviewsTab(context, isDark, brightness),
                              _buildAboutTab(context, isDark, brightness),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}