// lib/screens/course/course_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:buildacad/screens/course/course_learning/course_learning.dart';
import 'package:buildacad/widgets/course/course_curriculum.dart';
import 'package:buildacad/widgets/course/course_reviews.dart';
import 'package:buildacad/services/api_service.dart';
import 'package:buildacad/utils/date_utils.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

import '../../../models/course_model.dart';
import '../../../constants/colors.dart';
import '../../../core/widgets/app_card.dart';

enum CourseTab { overview, curriculum, reviews }

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final bool isAuthenticated;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.isAuthenticated = false,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailScreen> {
  bool _isLoading = true;
  bool _refreshing = false;
  Course? _course;
  CourseTab _activeTab = CourseTab.overview;
  bool _bookmarked = false;
  bool _previewVisible = false;
  Lesson? _previewLesson;

  bool _enrolled = false;
  bool _enrollmentLoading = false;
  bool _isCheckingEnrollment = true;
  bool _isOwner = false;
  EnrollmentStatus? _enrollmentStatus;

  String? _error;

  final ApiService _apiService = ApiService();

  // Get brightness from context
  Brightness get _brightness => MediaQuery.of(context).platformBrightness;

  // Helper getters using AppColors from constants/colors.dart
  Color get _textColor => AppColors.getTextColor(_brightness);
  Color get _backgroundColor => AppColors.getBackgroundColor(_brightness);
  Color get _backgroundElementColor =>
      AppColors.getBackgroundElementColor(_brightness);
  Color get _backgroundSelectedColor =>
      AppColors.getBackgroundSelectedColor(_brightness);
  Color get _textSecondaryColor => AppColors.getTextSecondaryColor(_brightness);
  Color get _primaryColor => AppColors.getPrimaryColor(_brightness);
  Color get _primaryLightColor => AppColors.getPrimaryLightColor(_brightness);
  Color get _successColor => AppColors.getSuccessColor(_brightness);
  Color get _errorColor => AppColors.getErrorColor(_brightness);
  Color get _badgeBg => _primaryColor.withValues(alpha: 0.15);

  // Responsive helpers
  bool get _isSmallScreen {
    final width = MediaQuery.of(context).size.width;
    return width < 400;
  }

  bool get _isMediumScreen {
    final width = MediaQuery.of(context).size.width;
    return width >= 400 && width < 600;
  }

  bool get _isLargeScreen {
    final width = MediaQuery.of(context).size.width;
    return width >= 900;
  }

  // Responsive text sizes
  double get _titleSize {
    if (_isSmallScreen) return 20.0;
    if (_isMediumScreen) return 22.0;
    if (_isLargeScreen) return 32.0;
    return 24.0;
  }

  double get _subtitleSize {
    if (_isSmallScreen) return 13.0;
    if (_isMediumScreen) return 14.0;
    if (_isLargeScreen) return 18.0;
    return 16.0;
  }

  double get _bodySize {
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 13.0;
    if (_isLargeScreen) return 16.0;
    return 14.0;
  }

  double get _smallBodySize {
    if (_isSmallScreen) return 10.0;
    if (_isMediumScreen) return 11.0;
    if (_isLargeScreen) return 14.0;
    return 12.0;
  }

  double get _buttonTextSize {
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 13.0;
    if (_isLargeScreen) return 16.0;
    return 15.0;
  }

  double get _headingSize {
    if (_isSmallScreen) return 14.0;
    if (_isMediumScreen) return 15.0;
    if (_isLargeScreen) return 18.0;
    return 16.0;
  }

  // Responsive paddings
  double get _contentPadding {
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 16.0;
    if (_isLargeScreen) return 40.0;
    return 20.0;
  }

  double get _buttonHeight {
    if (_isSmallScreen) return 40.0;
    if (_isMediumScreen) return 44.0;
    if (_isLargeScreen) return 56.0;
    return 50.0;
  }

  double get _cardRadius {
    if (_isSmallScreen) return 14.0;
    if (_isMediumScreen) return 16.0;
    if (_isLargeScreen) return 20.0;
    return 18.0;
  }

  double get _sectionSpacing {
    if (_isSmallScreen) return 16.0;
    if (_isMediumScreen) return 20.0;
    if (_isLargeScreen) return 24.0;
    return 20.0;
  }

  // Check if user is actually authenticated
  bool get _isActuallyAuthenticated {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated && authProvider.user != null;
  }

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchCourseDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _isCheckingEnrollment = true;
      _enrolled = false;
    });

    try {
      final response = await _apiService.getCourseById(widget.courseId);

      if (!mounted) return;

      if (response.success && response.data != null) {
        final courseData = response.data!;
        final course = Course.fromJson(courseData);
        
        setState(() {
          _course = course;
          _isLoading = false;
          _refreshing = false;
        });

        // Check if current user owns this course
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _isOwner = authProvider.isAuthenticated && authProvider.user != null &&
            authProvider.user!.id == course.instructorId;

        // Check enrollment status if authenticated
        if (_isActuallyAuthenticated) {
          await _checkEnrollmentStatus();
        } else {
          setState(() {
            _isCheckingEnrollment = false;
            _enrolled = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? response.message ?? 'Failed to load course';
          _isLoading = false;
          _refreshing = false;
          _isCheckingEnrollment = false;
          _enrolled = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _refreshing = false;
        _isCheckingEnrollment = false;
        _enrolled = false;
      });
    }
  }

  Future<void> _checkEnrollmentStatus() async {
    if (!_isActuallyAuthenticated) {
      setState(() {
        _isCheckingEnrollment = false;
        _enrolled = false;
      });
      return;
    }

    setState(() => _isCheckingEnrollment = true);

    try {
      final response = await _apiService.checkEnrollmentStatus(widget.courseId);

      if (!mounted) return;

      if (response.success && response.data != null) {
        final data = response.data!;
        
        final isEnrolled = data['isEnrolled'] ?? false;
        final progress = (data['progress'] ?? 0.0).toDouble();
        final isCompleted = data['isCompleted'] ?? false;
        final enrollmentId = data['enrollmentId'];
        
        setState(() {
          _enrollmentStatus = EnrollmentStatus(
            isEnrolled: isEnrolled,
            progress: progress,
            isCompleted: isCompleted,
            enrollmentId: enrollmentId,
          );
          _enrolled = isEnrolled;
          _isCheckingEnrollment = false;
        });
      } else {
        setState(() {
          _isCheckingEnrollment = false;
          _enrolled = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCheckingEnrollment = false;
        _enrolled = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    setState(() => _refreshing = true);
    await _fetchCourseDetails();
    if (mounted) {
      setState(() => _refreshing = false);
    }
  }

  Future<void> _handleEnroll() async {
    // Check if user is authenticated
    if (!_isActuallyAuthenticated) {
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _backgroundElementColor,
          title: Text(
            'Login Required',
            style: TextStyle(color: _textColor, fontSize: _subtitleSize),
          ),
          content: Text(
            'Please login to enroll in this course.',
            style: TextStyle(color: _textSecondaryColor, fontSize: _bodySize),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _textSecondaryColor,
                  fontSize: _smallBodySize,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Login',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: _smallBodySize,
                ),
              ),
            ),
          ],
        ),
      );
      
      if (shouldLogin == true) {
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    // If already enrolled, go to learning page
    if (_enrolled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseLearningPage(
            courseId: _course!.id,
            course: _course!,
          ),
        ),
      );
      return;
    }

    setState(() => _enrollmentLoading = true);

    try {
      final response = await _apiService.enrollInCourse(widget.courseId);

      if (!mounted) return;

      setState(() => _enrollmentLoading = false);

      if (response.success) {
        setState(() {
          _enrolled = true;
          _enrollmentStatus = EnrollmentStatus(
            isEnrolled: true,
            progress: 0,
            isCompleted: false,
            enrollmentId: response.data?['enrollmentId'],
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully enrolled in the course!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CourseLearningPage(
                courseId: _course!.id,
                course: _course!,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? response.message ?? 'Failed to enroll'),
            backgroundColor: _errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _enrollmentLoading = false);
      
      if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        _showLoginRequiredDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enroll: ${e.toString()}'),
            backgroundColor: _errorColor,
          ),
        );
      }
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _backgroundElementColor,
        title: Text(
          'Login Required',
          style: TextStyle(color: _textColor, fontSize: _subtitleSize),
        ),
        content: Text(
          'Please login to enroll in this course.',
          style: TextStyle(color: _textSecondaryColor, fontSize: _bodySize),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _textSecondaryColor,
                fontSize: _smallBodySize,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/login');
            },
            child: Text(
              'Login',
              style: TextStyle(
                color: _primaryColor,
                fontSize: _smallBodySize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePrimaryAction() {
    if (_isOwner || _enrolled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseLearningPage(
            courseId: _course!.id,
            course: _course!,
          ),
        ),
      );
    } else {
      _handleEnroll();
    }
  }

  void _openPreview(Lesson? lesson) {
    setState(() {
      _previewLesson = lesson;
      _previewVisible = true;
    });
  }

  void _closePreview() {
    setState(() => _previewVisible = false);
  }

  void _toggleBookmark() => setState(() => _bookmarked = !_bookmarked);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeleton();
    
    if (_error != null) return _buildErrorState();
    
    final course = _course;
    if (course == null) return _buildErrorState();

    final size = MediaQuery.of(context).size;
    final insetsTop = MediaQuery.of(context).padding.top;
    final insetsBottom = MediaQuery.of(context).padding.bottom;
    final totalDuration = formatTotalDurationFromSections(course.sections);
    final lessons = course.sections.expand((s) => s.lessons).toList();

    final isLargeScreen = _isLargeScreen;
    final contentPadding = _contentPadding;
    const maxContentWidth = 1200.0;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: _primaryColor,
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHero(course, size.width, insetsTop, isLargeScreen),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleMeta(
                            course,
                            lastUpdated: formatMonthYear(course.updatedAt),
                            isLargeScreen: isLargeScreen,
                            padding: contentPadding,
                          ),
                          _buildTabsBar(isLargeScreen: isLargeScreen),
                          _buildTabContent(
                              course, totalDuration, lessons, isLargeScreen),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildStickyBar(course, insetsBottom, isLargeScreen),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Hero Section - Responsive
  // ------------------------------------------------------------------
  Widget _buildHero(
      Course course, double width, double insetsTop, bool isLargeScreen) {
    final heroHeight = isLargeScreen
        ? width * 0.35
        : (width > 600 ? width * 0.45 : width * 0.55);
    final heroWidth = width - (_isSmallScreen ? 24 : 32);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: _isSmallScreen ? 12 : 16,
          vertical: _isSmallScreen ? 8 : 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_isSmallScreen ? 24 : 30),
        child: Container(
          width: heroWidth,
          height: heroHeight.clamp(200.0, 500.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: _textSecondaryColor.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                course.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _backgroundElementColor,
                  child: Icon(Icons.image_not_supported,
                      color: _textSecondaryColor),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _backgroundColor.withValues(alpha: 0.2),
                      Colors.transparent,
                      _backgroundColor.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: insetsTop + 8,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _backgroundElementColor.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: _textSecondaryColor.withValues(alpha: 0.16)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.chevron_left,
                                  color: _textColor, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'Back',
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: _smallBodySize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleBookmark,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: _isSmallScreen ? 36 : 40,
                          height: _isSmallScreen ? 36 : 40,
                          decoration: BoxDecoration(
                            color: _backgroundElementColor.withValues(alpha: 0.82),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _textSecondaryColor.withValues(alpha: 0.16)),
                          ),
                          child: Icon(
                            _bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: _textColor,
                            size: _isSmallScreen ? 18 : 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openPreview(null),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width:
                                isLargeScreen ? 80 : (_isSmallScreen ? 50 : 64),
                            height:
                                isLargeScreen ? 80 : (_isSmallScreen ? 50 : 64),
                            decoration: BoxDecoration(
                              color: _primaryColor.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withValues(alpha: 0.28),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: isLargeScreen
                                  ? 40
                                  : (_isSmallScreen ? 24 : 32),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _backgroundElementColor.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Watch Preview',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: _smallBodySize,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // ------------------------------------------------------------------
  // Title & Meta Section - Responsive
  // ------------------------------------------------------------------
  Widget _buildTitleMeta(Course course,
      {required String lastUpdated,
      required bool isLargeScreen,
      required double padding}) {
    final displayRating = course.rating;
    final displayReviewCount = course.reviewsCount;

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  course.level,
                  style: TextStyle(
                    fontSize: _smallBodySize,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _backgroundElementColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 15, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      displayRating.toStringAsFixed(1),
                      style: TextStyle(
                        color: _textColor,
                        fontSize: _smallBodySize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($displayReviewCount)',
                      style: TextStyle(
                        color: _textSecondaryColor,
                        fontSize: _smallBodySize,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _backgroundElementColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline,
                        size: 14, color: _textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '${course.studentsCount}',
                      style: TextStyle(
                        color: _textSecondaryColor,
                        fontSize: _smallBodySize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _isSmallScreen ? 10 : 12),
          Text(
            course.title,
            style: TextStyle(
              color: _textColor,
              fontSize: _titleSize,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: _isSmallScreen ? 12 : 16),
          Row(
            children: [
              CircleAvatar(
                radius: isLargeScreen ? 24 : (_isSmallScreen ? 16 : 20),
                backgroundImage: NetworkImage(course.instructor.avatarUrl),
                backgroundColor: _backgroundElementColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.instructor.fullName,
                      style: TextStyle(
                        color: _textColor,
                        fontSize:
                            isLargeScreen ? 16 : (_isSmallScreen ? 13 : 15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Course Instructor',
                      style: TextStyle(
                        color: _textSecondaryColor,
                        fontSize: _smallBodySize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _isSmallScreen ? 12 : 16),
          Container(
            padding:
                EdgeInsets.all(isLargeScreen ? 20 : (_isSmallScreen ? 12 : 14)),
            decoration: BoxDecoration(
              color: _backgroundElementColor,
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(color: _textSecondaryColor.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: _textSecondaryColor.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _metaChip(
                    Icons.access_time, formatTotalDurationFromSections(course.sections)),
                _metaChip(Icons.language, course.language),
                _metaChip(
                    Icons.calendar_today_outlined, 'Updated $lastUpdated'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: _primaryColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: _textSecondaryColor,
            fontSize: _smallBodySize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Tabs - Responsive
  // ------------------------------------------------------------------
  Widget _buildTabsBar({required bool isLargeScreen}) {
    final tabs = <CourseTab, String>{
      CourseTab.overview: 'Overview',
      CourseTab.curriculum: 'Curriculum',
      CourseTab.reviews: 'Reviews',
    };

    return Container(
      margin: EdgeInsets.only(top: _isSmallScreen ? 10 : 16),
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 40 : _contentPadding,
        vertical: _isSmallScreen ? 2 : 4,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _textSecondaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.entries.map((entry) {
            final isActive = _activeTab == entry.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _activeTab = entry.key),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          isLargeScreen ? 24 : (_isSmallScreen ? 12 : 16),
                      vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? _primaryColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : (_isSmallScreen ? 12 : 14),
                      fontWeight: FontWeight.w600,
                      color: isActive ? _primaryColor : _textSecondaryColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(Course course, String totalDuration,
      List<Lesson> lessons, bool isLargeScreen) {
    switch (_activeTab) {
      case CourseTab.overview:
        return _buildOverviewTab(course, isLargeScreen);
      case CourseTab.curriculum:
        return CourseCurriculum(
          sections: course.sections,
          totalDurationLabel: totalDuration,
          isEnrolled: _enrolled,
          brightness: _brightness,
          onPlayLesson: _openPreview,
        );
      case CourseTab.reviews:
        return _buildReviewsTab();
    }
  }

  // ------------------------------------------------------------------
  // Overview Tab - Responsive
  // ------------------------------------------------------------------
  Widget _buildOverviewTab(Course course, bool isLargeScreen) {
    final padding = isLargeScreen ? 40.0 : _contentPadding;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About this course', Icons.info_outline),
          SizedBox(height: _isSmallScreen ? 10 : 12),
          _buildCard(
            child: Text(
              course.description,
              style: TextStyle(
                color: _textSecondaryColor,
                fontSize: _bodySize,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: _sectionSpacing),
          _buildSectionHeader("What you'll learn", Icons.check_circle_outline),
          SizedBox(height: _isSmallScreen ? 10 : 12),
          if (course.whatYouWillLearn.isEmpty)
            _buildEmptyState('No learning objectives listed.')
          else
            _buildCard(
              child: Column(
                children: course.whatYouWillLearn
                    .map((point) =>
                        _bulletRow(Icons.check_circle, _successColor, point))
                    .toList(),
              ),
            ),
          SizedBox(height: _sectionSpacing),
          _buildSectionHeader('Requirements', Icons.list_alt),
          SizedBox(height: _isSmallScreen ? 10 : 12),
          if (course.requirements.isEmpty)
            _buildEmptyState('No requirements listed.')
          else
            _buildCard(
              child: Column(
                children:
                    course.requirements.map((req) => _dotRow(req)).toList(),
              ),
            ),
          SizedBox(height: _sectionSpacing),
          _buildSectionHeader('Instructor', Icons.person_outline),
          SizedBox(height: _isSmallScreen ? 10 : 12),
          _buildCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isLargeScreen ? 36 : (_isSmallScreen ? 24 : 28),
                  backgroundImage: NetworkImage(course.instructor.avatarUrl),
                  backgroundColor: _backgroundElementColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.instructor.fullName,
                        style: TextStyle(
                          color: _textColor,
                          fontSize:
                              isLargeScreen ? 18 : (_isSmallScreen ? 14 : 16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.instructor.bio ??
                            'Experienced instructor passionate about teaching.',
                        style: TextStyle(
                          color: _textSecondaryColor,
                          fontSize: _bodySize,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                '${course.instructor.rating}',
                                style: TextStyle(
                                  color: _textSecondaryColor,
                                  fontSize: _smallBodySize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 14, color: _textSecondaryColor),
                              const SizedBox(width: 4),
                              Text(
                                '${course.instructor.studentsCount} students',
                                style: TextStyle(
                                  color: _textSecondaryColor,
                                  fontSize: _smallBodySize,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return AppCard(
      padding: padding ??
          EdgeInsets.all(_isSmallScreen ? 12 : (_isMediumScreen ? 16 : 20)),
      borderRadius: _cardRadius,
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: _primaryColor),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: _textColor,
            fontSize: _headingSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundElementColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: _textSecondaryColor,
            fontSize: _bodySize,
          ),
        ),
      ),
    );
  }

  Widget _bulletRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 12),
            child: Icon(icon, size: 18, color: color),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _textSecondaryColor,
                fontSize: _bodySize,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _textSecondaryColor,
                fontSize: _bodySize,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Reviews Tab - Using Real API Data from Course
  // ------------------------------------------------------------------
  Widget _buildReviewsTab() {
    final course = _course;
    if (course == null) {
      return const SizedBox.shrink();
    }

    final reviews = course.reviews;
    final rating = course.rating;

    if (reviews.isEmpty) {
      return _buildEmptyState(
        'No reviews yet. Be the first to review this course!'
      );
    }

    return CourseReviews(
      rating: rating,
      reviews: reviews,
      brightness: _brightness,
    );
  }

  // ------------------------------------------------------------------
  // Sticky Bottom Bar - Fixed at Bottom
  // ------------------------------------------------------------------
  String get _buttonText {
    if (_isOwner) return 'View Course';
    if (_enrollmentLoading) return 'Enrolling...';
    if (_enrolled) return 'Continue Learning';
    if (_isCheckingEnrollment) return 'Checking...';
    return 'Enroll Now';
  }

  bool get _isButtonDisabled => !_isOwner && (_enrollmentLoading || _isCheckingEnrollment);

  Widget _buildStickyBar(
      Course course, double insetsBottom, bool isLargeScreen) {
    final padding = isLargeScreen ? 40.0 : _contentPadding;

    return Container(
      padding: EdgeInsets.fromLTRB(
          padding, 14, padding, insetsBottom > 12 ? insetsBottom : 14),
      decoration: BoxDecoration(
        color: _backgroundElementColor,
        border: Border(
          top: BorderSide(
            color: _textSecondaryColor.withValues(alpha: 0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _textSecondaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 480;
            return compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPriceSection(course, isLargeScreen),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: _buttonHeight,
                        child: ElevatedButton(
                          onPressed:
                              _isButtonDisabled ? null : _handlePrimaryAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _enrolled ? _successColor : _primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                (_enrolled ? _successColor : _primaryColor)
                                    .withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _enrollmentLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _buttonText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _buttonTextSize,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                          child: _buildPriceSection(course, isLargeScreen)),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: isLargeScreen ? 1 : 2,
                        child: SizedBox(
                          height: _buttonHeight,
                          child: ElevatedButton(
                            onPressed:
                                _isButtonDisabled ? null : _handlePrimaryAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _enrolled ? _successColor : _primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  (_enrolled ? _successColor : _primaryColor)
                                      .withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _enrollmentLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _buttonText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: _buttonTextSize,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildPriceSection(Course course, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_enrolled) ...[
          Text(
            '✅ Enrolled',
            style: TextStyle(
              color: _successColor,
              fontSize: isLargeScreen ? 18 : (_isSmallScreen ? 14 : 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: isLargeScreen ? 160 : (_isSmallScreen ? 80 : 120),
            height: 4,
            decoration: BoxDecoration(
              color: _backgroundSelectedColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: (_enrollmentStatus?.progress ?? 0) / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Text(
            '${(_enrollmentStatus?.progress ?? 0).round()}% complete',
            style: TextStyle(
              color: _textSecondaryColor,
              fontSize: _smallBodySize,
            ),
          ),
        ] else ...[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                course.price > 0 
                    ? 'रु ${course.price.toStringAsFixed(2)}'
                    : 'Free',
                style: TextStyle(
                  color: _textColor,
                  fontSize: isLargeScreen ? 24 : (_isSmallScreen ? 18 : 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (course.originalPrice != null && course.originalPrice! > 0)
                Text(
                  'रु ${course.originalPrice!.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _textSecondaryColor,
                    fontSize: isLargeScreen ? 16 : (_isSmallScreen ? 12 : 14),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          if (course.discountPercent > 0)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _successColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${course.discountPercent}% OFF',
                style: TextStyle(
                  color: _successColor,
                  fontSize: _smallBodySize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------------
  // Skeleton / Error States - Responsive
  // ------------------------------------------------------------------
  Widget _buildSkeleton() {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = _isLargeScreen;
    final isMediumScreen = _isMediumScreen;
    final padding =
        isLargeScreen ? 40.0 : (isMediumScreen ? 24.0 : _contentPadding);
    final heroHeight = isLargeScreen
        ? size.width * 0.35
        : (isMediumScreen ? size.width * 0.45 : size.width * 0.55);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ShimmerBox(
                  width: size.width,
                  height: heroHeight.clamp(200.0, 500.0),
                  color: _backgroundElementColor,
                  radius: 0),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                        width: 120, height: 24, color: _backgroundElementColor),
                    const SizedBox(height: 16),
                    _ShimmerBox(
                        width:
                            isLargeScreen ? size.width * 0.6 : size.width * 0.8,
                        height: isLargeScreen ? 36 : 28,
                        color: _backgroundElementColor),
                    const SizedBox(height: 16),
                    _ShimmerBox(
                        width: 200, height: 40, color: _backgroundElementColor),
                    const SizedBox(height: 24),
                    ...List.generate(
                        isLargeScreen ? 8 : 5,
                        (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ShimmerBox(
                                  width: double.infinity,
                                  height: isLargeScreen ? 20 : _bodySize,
                                  color: _backgroundElementColor),
                            )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _backgroundElementColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  size: 64,
                  color: _textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _error == 'Course not found' ? 'Course not found' : 'Error Loading Course',
                style: TextStyle(
                  color: _textColor,
                  fontSize: _subtitleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'The course you\'re looking for doesn\'t exist.',
                style: TextStyle(
                  color: _textSecondaryColor,
                  fontSize: _bodySize,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _fetchCourseDetails();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _buttonTextSize,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    color: _textSecondaryColor,
                    fontSize: _bodySize,
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

/// Simple pulsing placeholder box used for the loading skeleton.
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 8,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 0.8)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}