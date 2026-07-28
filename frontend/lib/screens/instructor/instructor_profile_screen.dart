import 'package:buildacad/screens/course/course_detail/course_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/instructor_service.dart';
import '../../services/course_service.dart';
import '../../services/api_service.dart';
import '../../constants/colors.dart';
import '../../models/course_model.dart';
import '../../widgets/explore/course_card.dart';
import '../../widgets/course/course_reviews.dart';
import '../../widgets/common/error_state.dart';
import '../../routes/app_routes.dart';

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

  int _instructorRating = 0;
  final TextEditingController _instructorReviewController = TextEditingController();
  bool _isSubmittingInstructorReview = false;
  String? _instructorReviewError;
  bool _hasReviewedInstructor = false;

  late final TabController _tabController;
  bool _isTogglingFollow = false;

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
    if (_tabController.index == 1 && _instructorReviews.isEmpty && !_isLoadingReviews) {
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
        final data = instructorResponse.data as Map<String, dynamic>;
        print('🔍 InstructorProfileScreen: Setting instructor data');
        print('🔍 INSTRUCTOR DATA KEYS: ${data.keys}');
        print('🔍 followerCount: ${data['followerCount']} (${data['followerCount'].runtimeType})');
        print('🔍 followersCount: ${data['followersCount']} (${data['followersCount'].runtimeType})');
        print('🔍 totalStudents: ${data['totalStudents']} (${data['totalStudents'].runtimeType})');
        print('🔍 studentsCount: ${data['studentsCount']} (${data['studentsCount'].runtimeType})');
        print('🔍 totalCourses: ${data['totalCourses']} (${data['totalCourses'].runtimeType})');
        print('🔍 coursesCount: ${data['coursesCount']} (${data['coursesCount'].runtimeType})');
        print('🔍 isFollowing: ${data['isFollowing']} (${data['isFollowing'].runtimeType})');
        print('🔍 followers array length: ${(data['followers'] as List?)?.length}');
        setState(() {
          _instructorData = data;
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
      final coursesResponse = await _courseService.getPublicCourses(
        instructorId: widget.instructorId,
        limit: 20,
      );
      print('🔍 InstructorProfileScreen: getPublicCourses response: success=${coursesResponse.success}, data=${coursesResponse.data != null ? 'present' : 'null'}');
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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = authProvider.user?.id;
        final hasReviewed = currentUserId != null && reviewsList.any((r) =>
            r['userId'] == currentUserId && r['source'] == 'instructor');
        setState(() {
          _instructorReviews = reviewsList;
          _totalReviews = meta?['total'] as int? ?? 0;
          _instructorAvgRating = (meta?['averageRating'] as num?)?.toDouble() ?? 0.0;
          _isLoadingReviews = false;
          _hasReviewedInstructor = hasReviewed;
        });
      } else {
        setState(() => _isLoadingReviews = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitInstructorReview() async {
    if (_instructorRating == 0) {
      setState(() => _instructorReviewError = 'Please select a rating');
      return;
    }

    setState(() {
      _isSubmittingInstructorReview = true;
      _instructorReviewError = null;
    });

    try {
      final instructorId = _instructorData != null
          ? _getInstructorId(_instructorData!)
          : widget.instructorId;
      final response = await _apiService.createInstructorReview(
        instructorId: instructorId,
        rating: _instructorRating,
        comment: _instructorReviewController.text.trim().isEmpty
            ? null
            : _instructorReviewController.text.trim(),
      );

      if (!mounted) return;

      if (response.success) {
        setState(() {
          _isSubmittingInstructorReview = false;
          _instructorRating = 0;
          _instructorReviewController.clear();
          _hasReviewedInstructor = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Instructor review submitted successfully!'),
            backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
          ),
        );

        _loadInstructorReviews();
      } else {
        setState(() {
          _isSubmittingInstructorReview = false;
          _instructorReviewError =
              response.error ?? 'Failed to submit review';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmittingInstructorReview = false;
        _instructorReviewError = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    print('🔍 InstructorProfileScreen: dispose called');
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _instructorReviewController.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow() async {
    if (_instructorData == null || _isTogglingFollow) return;

    final instructorId = _getInstructorId(_instructorData!);
    if (instructorId.isEmpty) return;

    setState(() => _isTogglingFollow = true);
    final isCurrentlyFollowing = _isFollowing(_instructorData!);

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
          _isTogglingFollow = false;
          _instructorData!['isFollowing'] = newIsFollowing;
          if (newFollowersCount != null) {
            _instructorData!['followersCount'] = newFollowersCount;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newIsFollowing
                  ? 'Now following this instructor'
                  : 'Unfollowed instructor',
            ),
            backgroundColor: newIsFollowing ? AppColors.getSuccessColor(Theme.of(context).brightness) : AppColors.getWarningColor(Theme.of(context).brightness),
          ),
        );
      } else {
        setState(() {
          _isTogglingFollow = false;
          _instructorData!['isFollowing'] = isCurrentlyFollowing;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ??
                  'Failed to update follow status'),
              backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isTogglingFollow = false;
        _instructorData!['isFollowing'] = isCurrentlyFollowing;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
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
    const keys = ['followersCount', 'followerCount'];
    for (final key in keys) {
      if (instructor[key] != null) {
        print('🔍 _getFollowersCount: found $key = ${instructor[key]} (${instructor[key].runtimeType})');
        if (instructor[key] is int) return instructor[key] as int;
        if (instructor[key] is double) return (instructor[key] as double).toInt();
        print('🔍 _getFollowersCount: $key was not int/double, type=${instructor[key].runtimeType}');
      }
    }
    if (instructor['followers'] is List) {
      final len = (instructor['followers'] as List).length;
      print('🔍 _getFollowersCount: using followers array length = $len');
      return len;
    }
    print('🔍 _getFollowersCount: returning 0 (no data found)');
    return 0;
  }

  int _getCoursesCount(Map<String, dynamic> instructor) {
    const keys = ['coursesCount', 'totalCourses'];
    for (final key in keys) {
      if (instructor[key] != null) {
        if (instructor[key] is int) return instructor[key] as int;
        if (instructor[key] is double) return (instructor[key] as double).toInt();
      }
    }
    return _instructorCourses.length;
  }

  int _getStudentsCount(Map<String, dynamic> instructor) {
    const keys = ['studentsCount', 'totalStudents'];
    for (final key in keys) {
      if (instructor[key] != null) {
        print('🔍 _getStudentsCount: found $key = ${instructor[key]} (${instructor[key].runtimeType})');
        if (instructor[key] is int) return instructor[key] as int;
        if (instructor[key] is double) return (instructor[key] as double).toInt();
      }
    }
    print('🔍 _getStudentsCount: returning 0');
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        children: [
          // Avatar with loading border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 58,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: imageUrl.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Follow button and stats
          Row(
            children: [
              // Follow button
              SizedBox(
                width: 130,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: _isTogglingFollow ? null : _toggleFollow,
                  icon: _isTogglingFollow
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isFollowing
                                ? colorScheme.onSecondaryContainer
                                : Colors.white,
                          ),
                        )
                      : Icon(
                          isFollowing ? Icons.check : Icons.person_add,
                          size: 20,
                        ),
                  label: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing
                        ? colorScheme.secondaryContainer
                        : colorScheme.primary,
                    foregroundColor: isFollowing
                        ? colorScheme.onSecondaryContainer
                        : Colors.white,
                    disabledBackgroundColor: isFollowing
                        ? colorScheme.secondaryContainer
                        : colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            final courseId = courseData['id'] as String?;
            if (courseId != null && courseId.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(
                    courseId: courseId,
                    isAuthenticated: Provider.of<AuthProvider>(context, listen: false).user != null,
                  ),
                ),
              );
              Navigator.pushNamed(
                context,
                AppRoutes.course,
                arguments: {AppRoutes.argCourseId: courseId},
              );
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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.user != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoggedIn && !_hasReviewedInstructor) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate this instructor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < _instructorRating;
                      return IconButton(
                        onPressed: () => setState(() => _instructorRating = i + 1),
                        icon: Icon(
                          filled ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF59E0B),
                          size: 28,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _instructorReviewController,
                    maxLines: 3,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Share your experience with this instructor...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isSubmittingInstructorReview
                          ? null
                          : _submitInstructorReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmittingInstructorReview
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit Review',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  if (_instructorReviewError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _instructorReviewError!,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_hasReviewedInstructor)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You have reviewed this instructor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_instructorReviews.isEmpty && !_hasReviewedInstructor)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
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
              ),
            )
          else if (_instructorReviews.isNotEmpty)
            CourseReviews(
              rating: _instructorAvgRating,
              reviews: _instructorReviews.map((r) => Review.fromJson(r)).toList(),
              brightness: brightness,
            ),
        ],
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