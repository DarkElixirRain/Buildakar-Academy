// lib/screens/course/course_learning/course_learning.dart
import 'package:flutter/material.dart';
import 'package:buildacad/widgets/course/course_reviews.dart' hide formatRelativeDate;
import 'package:buildacad/widgets/course/custom_video_player.dart';
import 'package:buildacad/utils/date_utils.dart';
import 'package:buildacad/services/api_service.dart';

import '../../../models/course_model.dart';
import '../../../constants/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

// ============================================================================
// Q&A and Notes have no backend yet, so their models are defined locally.
// Everything else (sections, lessons, reviews, study materials) comes
// straight from your real Course model.
// ============================================================================

class QnaAnswer {
  final String author;
  final String text;
  final DateTime postedAt;
  final bool isInstructor;

  QnaAnswer({
    required this.author,
    required this.text,
    required this.postedAt,
    this.isInstructor = false,
  });
}

class QnaQuestion {
  final String id;
  final String author;
  final String text;
  final DateTime postedAt;
  int upvotes;
  bool upvoted;
  final List<QnaAnswer> answers;

  QnaQuestion({
    required this.id,
    required this.author,
    required this.text,
    required this.postedAt,
    this.upvotes = 0,
    this.upvoted = false,
    List<QnaAnswer>? answers,
  }) : answers = answers ?? [];
}

class LearningNote {
  final String id;
  final String lessonId;
  final String lessonTitle;
  String content;
  DateTime updatedAt;

  LearningNote({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.content,
    required this.updatedAt,
  });
}

List<QnaQuestion> _dummyQuestions() {
  final now = DateTime.now();
  return [
    QnaQuestion(
      id: 'q1',
      author: 'Alex M.',
      text: 'Does this section cover error handling in depth, or just the basics?',
      postedAt: now.subtract(const Duration(days: 3)),
      upvotes: 6,
      answers: [
        QnaAnswer(
          author: 'Instructor',
          text: 'Great question — a later lesson covers it in depth with real examples.',
          postedAt: now.subtract(const Duration(days: 2)),
          isInstructor: true,
        ),
      ],
    ),
    QnaQuestion(
      id: 'q2',
      author: 'Priya S.',
      text: 'Is there a downloadable version of the starter project?',
      postedAt: now.subtract(const Duration(days: 1)),
      upvotes: 2,
    ),
    QnaQuestion(
      id: 'q3',
      author: 'Daniel K.',
      text: 'What Flutter/Dart version is used in this course?',
      postedAt: now.subtract(const Duration(hours: 10)),
      upvotes: 1,
      answers: [
        QnaAnswer(
          author: 'Instructor',
          text: 'The latest stable release at the time of recording — check the resources tab.',
          postedAt: now.subtract(const Duration(hours: 6)),
          isInstructor: true,
        ),
      ],
    ),
  ];
}

class CourseLearningPage extends StatefulWidget {
  final String courseId;
  final Course course;

  const CourseLearningPage({
    super.key,
    required this.courseId,
    required this.course,
  });

  @override
  State<CourseLearningPage> createState() => _CourseLearningPageState();
}

class _CourseLearningPageState extends State<CourseLearningPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String? _currentSectionId;
  String? _currentLessonId;
  final Set<String> _completedLessonIds = {};
  final Set<String> _expandedSectionIds = {};
  bool _videoVisible = false;
  bool _showCelebration = false;
  bool _bookmarked = false;

  late List<QnaQuestion> _questions;
  final List<LearningNote> _notes = [];

  final TextEditingController _questionController = TextEditingController();
  final FocusNode _questionFocus = FocusNode();
  int _myRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  
  // Review submission state
  bool _isSubmittingReview = false;
  String? _reviewError;

  final ApiService _apiService = ApiService();

  // --------------------------------------------------------------------
  // Colors
  // --------------------------------------------------------------------
  Brightness get _brightness => MediaQuery.of(context).platformBrightness;
  Color get _textColor => AppColors.getTextColor(_brightness);
  Color get _backgroundColor => AppColors.getBackgroundColor(_brightness);
  Color get _backgroundElementColor => AppColors.getBackgroundElementColor(_brightness);
  Color get _backgroundSelectedColor => AppColors.getBackgroundSelectedColor(_brightness);
  Color get _textSecondaryColor => AppColors.getTextSecondaryColor(_brightness);
  Color get _primaryColor => AppColors.getPrimaryColor(_brightness);
  Color get _successColor => AppColors.getSuccessColor(_brightness);
  Color get _errorColor => AppColors.getErrorColor(_brightness);

  // --------------------------------------------------------------------
  // Full responsive breakpoint system
  // --------------------------------------------------------------------
  double get _w => MediaQuery.of(context).size.width;
  bool get _isTinyScreen => _w < 340;
  bool get _isSmallScreen => _w < 380;
  bool get _isMediumScreen => _w >= 380 && _w < 600;
  bool get _isTablet => _w >= 600 && _w < 900;
  bool get _isLargeScreen => _w >= 900;

  // Responsive helpers for hero
  bool get _isSmallScreenHero {
    final width = MediaQuery.of(context).size.width;
    return width < 400;
  }

  bool get _isMediumScreenHero {
    final width = MediaQuery.of(context).size.width;
    return width >= 400 && width < 600;
  }

  bool get _isLargeScreenHero {
    final width = MediaQuery.of(context).size.width;
    return width >= 900;
  }

  double get _smallBodySize {
    if (_isSmallScreenHero) return 10;
    if (_isMediumScreenHero) return 11;
    if (_isLargeScreenHero) return 14;
    return 12;
  }

  double get _contentPadding {
    if (_isTinyScreen) return 10.0;
    if (_isSmallScreen) return 12.0;
    if (_isTablet) return 24.0;
    if (_isLargeScreen) return 40.0;
    return 16.0;
  }

  double get _titleFont {
    if (_isTinyScreen) return 13.5;
    if (_isSmallScreen) return 14.5;
    if (_isLargeScreen) return 17.0;
    return 15.5;
  }

  double get _bodyFont {
    if (_isTinyScreen) return 11.5;
    if (_isLargeScreen) return 14.0;
    return 13.0;
  }

  double get _smallFont {
    if (_isTinyScreen) return 9.5;
    if (_isLargeScreen) return 12.0;
    return 11.0;
  }

  double get _playButtonSize {
    if (_isTinyScreen) return 44;
    if (_isLargeScreen) return 64;
    return 52;
  }

  double get _maxContentWidth => _isLargeScreen ? 1000 : double.infinity;

  int get _gridColumns {
    if (_isLargeScreen) return 2;
    if (_isTablet) return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _questions = _dummyQuestions();

    for (final section in widget.course.sections) {
      for (final lesson in section.lessons) {
        if (lesson.completed) _completedLessonIds.add(lesson.id);
      }
    }

    outer:
    for (final section in widget.course.sections) {
      for (final lesson in section.lessons) {
        if (!_completedLessonIds.contains(lesson.id)) {
          _currentSectionId = section.id;
          _currentLessonId = lesson.id;
          break outer;
        }
      }
    }
    if (_currentLessonId == null && widget.course.sections.isNotEmpty) {
      final firstSection = widget.course.sections.first;
      if (firstSection.lessons.isNotEmpty) {
        _currentSectionId = firstSection.id;
        _currentLessonId = firstSection.lessons.first.id;
      }
    }
    if (_currentSectionId != null) _expandedSectionIds.add(_currentSectionId!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    _questionFocus.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------
  // Lesson / progress helpers
  // --------------------------------------------------------------------
  CourseSection? get _currentSection {
    if (_currentSectionId == null) return null;
    for (final s in widget.course.sections) {
      if (s.id == _currentSectionId) return s;
    }
    return null;
  }

  Lesson? get _currentLesson {
    final section = _currentSection;
    if (section == null || _currentLessonId == null) return null;
    for (final l in section.lessons) {
      if (l.id == _currentLessonId) return l;
    }
    return null;
  }

  bool _isCompleted(Lesson lesson) => _completedLessonIds.contains(lesson.id);

  int get _totalLessons =>
      widget.course.sections.fold(0, (sum, sec) => sum + sec.lessons.length);

  double get _progress =>
      _totalLessons == 0 ? 0 : _completedLessonIds.length / _totalLessons;

  List<MapEntry<CourseSection, Lesson>> get _flatLessons {
    final list = <MapEntry<CourseSection, Lesson>>[];
    for (final s in widget.course.sections) {
      for (final l in s.lessons) {
        list.add(MapEntry(s, l));
      }
    }
    return list;
  }

  void _selectLesson(CourseSection section, Lesson lesson, {bool autoPlay = true}) {
    setState(() {
      _currentSectionId = section.id;
      _currentLessonId = lesson.id;
      _expandedSectionIds.add(section.id);
      if (autoPlay) _videoVisible = true;
    });
  }

  void _toggleLessonComplete(Lesson lesson) {
    setState(() {
      final wasComplete = _completedLessonIds.contains(lesson.id);
      if (wasComplete) {
        _completedLessonIds.remove(lesson.id);
      } else {
        _completedLessonIds.add(lesson.id);
        if (_completedLessonIds.length == _totalLessons && _totalLessons > 0) {
          _showCelebration = true;
        }
      }
    });
  }

  void _goToNextLesson() {
    final flat = _flatLessons;
    final pos = flat.indexWhere(
        (e) => e.key.id == _currentSectionId && e.value.id == _currentLessonId);
    if (pos == -1 || pos >= flat.length - 1) return;
    setState(() => _completedLessonIds.add(flat[pos].value.id));
    final next = flat[pos + 1];
    _selectLesson(next.key, next.value, autoPlay: true);
  }

  void _goToPreviousLesson() {
    final flat = _flatLessons;
    final pos = flat.indexWhere(
        (e) => e.key.id == _currentSectionId && e.value.id == _currentLessonId);
    if (pos <= 0) return;
    final prev = flat[pos - 1];
    _selectLesson(prev.key, prev.value, autoPlay: true);
  }

  void _closeVideo() {
    setState(() => _videoVisible = false);
  }

  void _toggleBookmark() => setState(() => _bookmarked = !_bookmarked);

  void _openPreview(Lesson? lesson) {
    setState(() {
      _videoVisible = true;
    });
  }

  // --------------------------------------------------------------------
  // Review Submission
  // --------------------------------------------------------------------
  Future<void> _submitReview() async {
    if (_myRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating first')),
      );
      return;
    }

    setState(() {
      _isSubmittingReview = true;
      _reviewError = null;
    });

    try {
      final response = await _apiService.createReview(
        courseId: widget.courseId,
        rating: _myRating,
        comment: _reviewController.text.trim().isEmpty 
            ? null 
            : _reviewController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isSubmittingReview = false;
      });

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form
        setState(() {
          _myRating = 0;
          _reviewController.clear();
        });
        
        // Refresh the course to show updated reviews
        // You can emit an event to refresh the parent widget
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to submit review'),
            backgroundColor: _errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmittingReview = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  // --------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (widget.course.sections.isEmpty || _currentLesson == null) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _backgroundElementColor,
          title: Text(widget.course.title, style: TextStyle(color: _textColor)),
        ),
        body: Center(
          child: Text('This course has no lessons yet.',
              style: TextStyle(color: _textSecondaryColor)),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final insetsTop = MediaQuery.of(context).padding.top;
    final isLargeScreen = _isLargeScreenHero;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hero Section with responsive width
                  _buildHero(widget.course, size.width, insetsTop, isLargeScreen),
                  
                  // Main content with responsive constraints
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTabBar(),
                        _buildContentTabs(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Video player overlay
          if (_videoVisible)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: CustomVideoPlayer(
                  videoUrl: _currentLesson?.videoUrl ??
                      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                  title: _currentLesson?.title ?? 'Lesson',
                  topInset: insetsTop,
                  onBack: _closeVideo,
                ),
              ),
            ),
          if (_showCelebration) _buildCelebrationOverlay(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Content Tabs
  // ------------------------------------------------------------------
  Widget _buildContentTabs() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildContentTab(),
          _buildQnaTab(),
          _buildNotesTab(),
          _buildReviewsTab(),
          _buildResourcesTab(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Hero Section
  // ------------------------------------------------------------------
  Widget _buildHero(
      Course course, double width, double insetsTop, bool isLargeScreen) {
    final heroHeight = isLargeScreen
        ? width * 0.35
        : (width > 600 ? width * 0.45 : width * 0.55);
    final heroWidth = width - (_isSmallScreenHero ? 24 : 32);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: _isSmallScreenHero ? 12 : 16,
          vertical: _isSmallScreenHero ? 8 : 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_isSmallScreenHero ? 24 : 30),
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
                          width: _isSmallScreenHero ? 36 : 40,
                          height: _isSmallScreenHero ? 36 : 40,
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
                            size: _isSmallScreenHero ? 18 : 20,
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
                          onTap: () => setState(() => _videoVisible = !_videoVisible),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width:
                                isLargeScreen ? 80 : (_isSmallScreenHero ? 50 : 64),
                            height:
                                isLargeScreen ? 80 : (_isSmallScreenHero ? 50 : 64),
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
                              _videoVisible ? Icons.pause : Icons.play_arrow,
                              size: isLargeScreen
                                  ? 40
                                  : (_isSmallScreenHero ? 24 : 32),
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
                          _videoVisible ? 'Playing Now' : 'Watch Lesson',
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentSection?.title ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: _smallBodySize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _currentLesson?.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_filled,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_completedLessonIds.length} of $_totalLessons lessons completed',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: _smallBodySize,
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
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(_isSmallScreen ? 20 : 32),
            padding: const EdgeInsets.all(28),
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: _backgroundElementColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 12)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Course complete!',
                    style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  'You finished every lesson in "${widget.course.title}". Nice work!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textSecondaryColor, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 18),
                AppButton(
                  title: 'Leave a review',
                  onPressed: () {
                    setState(() {
                      _showCelebration = false;
                      _tabController.animateTo(3);
                    });
                  },
                ),
                TextButton(
                  onPressed: () => setState(() => _showCelebration = false),
                  child: Text('Keep browsing', style: TextStyle(color: _textSecondaryColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, {Color? color}) {
    final c = color ?? _textSecondaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: c, fontSize: _smallFont - 1, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: EdgeInsets.symmetric(
        horizontal: _isLargeScreenHero ? 40 : _contentPadding,
        vertical: _isSmallScreenHero ? 2 : 4,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _textSecondaryColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: !_isLargeScreen && !_isTablet,
        labelColor: _primaryColor,
        unselectedLabelColor: _textSecondaryColor,
        indicatorColor: _primaryColor,
        indicatorWeight: 3,
        labelPadding: EdgeInsets.symmetric(horizontal: _isSmallScreen ? 10 : 16),
        labelStyle: TextStyle(fontSize: _bodyFont, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: _bodyFont, fontWeight: FontWeight.w600),
        tabs: [
          const Tab(text: 'Content'),
          Tab(text: _isTinyScreen ? 'Q&A' : 'Q&A (${_questions.length})'),
          Tab(text: _isTinyScreen ? 'Notes' : 'Notes${_notes.isNotEmpty ? ' (${_notes.length})' : ''}'),
          Tab(text: _isTinyScreen ? 'Reviews' : 'Reviews (${widget.course.reviewsCount})'),
          Tab(text: _isTinyScreen ? 'Files' : 'Resources (${widget.course.studyMaterials.length})'),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------
  // Content tab
  // --------------------------------------------------------------------
  Widget _buildContentTab() {
    return ListView.builder(
      padding: EdgeInsets.all(_contentPadding),
      itemCount: widget.course.sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = widget.course.sections[sectionIndex];
        final completedInSection = section.lessons.where((l) => _isCompleted(l)).length;
        final allDone = completedInSection == section.lessons.length && section.lessons.isNotEmpty;
        final expanded = _expandedSectionIds.contains(section.id);
        final sectionDuration = formatTotalDurationFromSections([section]);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _backgroundElementColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: allDone ? _successColor.withValues(alpha: 0.3) : _textSecondaryColor.withValues(alpha: 0.06),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: PageStorageKey(section.id),
              initiallyExpanded: expanded,
              onExpansionChanged: (isOpen) => setState(() {
                if (isOpen) {
                  _expandedSectionIds.add(section.id);
                } else {
                  _expandedSectionIds.remove(section.id);
                }
              }),
              leading: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: allDone ? _successColor.withValues(alpha: 0.15) : _primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: allDone
                    ? Icon(Icons.check, color: _successColor, size: 18)
                    : Text('${sectionIndex + 1}',
                        style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w800, fontSize: _bodyFont)),
              ),
              title: Text(
                section.title,
                style: TextStyle(color: _textColor, fontSize: _titleFont - 1, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '$completedInSection/${section.lessons.length} completed  •  $sectionDuration',
                style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont),
              ),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: section.lessons.asMap().entries.map((entry) {
                final lesson = entry.value;
                final isCurrent = lesson.id == _currentLessonId;
                final done = _isCompleted(lesson);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCurrent ? _primaryColor.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent ? Border.all(color: _primaryColor.withValues(alpha: 0.25)) : null,
                  ),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () => _selectLesson(section, lesson),
                    leading: Icon(
                      isCurrent
                          ? Icons.play_circle_fill
                          : (done ? Icons.check_circle : Icons.play_circle_outline),
                      color: isCurrent ? _primaryColor : (done ? _successColor : _textSecondaryColor),
                    ),
                    title: Text(
                      lesson.title,
                      style: TextStyle(
                        color: isCurrent ? _primaryColor : _textColor,
                        fontSize: _bodyFont,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    subtitle: (lesson.duration != null && lesson.duration!.isNotEmpty) || lesson.isFree
                        ? Row(
                            children: [
                              if (lesson.duration != null && lesson.duration!.isNotEmpty)
                                Text(lesson.duration!, style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont)),
                              if (lesson.isFree) ...[
                                const SizedBox(width: 8),
                                _pill('Free', color: _successColor),
                              ],
                            ],
                          )
                        : null,
                    trailing: IconButton(
                      icon: Icon(
                        done ? Icons.check_circle : Icons.check_circle_outline,
                        size: 20,
                        color: done ? _successColor : _textSecondaryColor.withValues(alpha: 0.5),
                      ),
                      onPressed: () => _toggleLessonComplete(lesson),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------
  // Q&A tab
  // --------------------------------------------------------------------
  Widget _buildQnaTab() {
    return Column(
      children: [
        Expanded(
          child: _questions.isEmpty
              ? _buildEmptyState(Icons.forum_outlined, 'No questions yet', 'Be the first to ask about this course.')
              : ListView.builder(
                  padding: EdgeInsets.all(_contentPadding),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[_questions.length - 1 - index];
                    return _buildQuestionCard(q);
                  },
                ),
        ),
        _buildAskQuestionBar(),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: _backgroundSelectedColor, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: _textSecondaryColor),
            ),
            const SizedBox(height: 14),
            Text(title, style: TextStyle(color: _textColor, fontSize: _titleFont - 1, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center, style: TextStyle(color: _textSecondaryColor, fontSize: _bodyFont)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QnaQuestion q) {
    final replyController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      q.author.isNotEmpty ? q.author[0] : '?',
                      style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.author,
                            style: TextStyle(color: _textColor, fontSize: _bodyFont, fontWeight: FontWeight.w700)),
                        Text(formatRelativeDate(q.postedAt),
                            style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont)),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setLocalState(() {
                      setState(() {
                        if (q.upvoted) {
                          q.upvoted = false;
                          q.upvotes--;
                        } else {
                          q.upvoted = true;
                          q.upvotes++;
                        }
                      });
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Icon(
                            q.upvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 16,
                            color: q.upvoted ? _primaryColor : _textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text('${q.upvotes}', style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(q.text, style: TextStyle(color: _textColor, fontSize: _bodyFont, height: 1.4)),
              if (q.answers.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...q.answers.map((a) => Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _backgroundSelectedColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(a.author,
                                  style: TextStyle(
                                      color: a.isInstructor ? _primaryColor : _textColor,
                                      fontSize: _smallFont + 1,
                                      fontWeight: FontWeight.w700)),
                              if (a.isInstructor) ...[
                                const SizedBox(width: 6),
                                _pill('Instructor', color: _primaryColor),
                              ],
                              const Spacer(),
                              Text(formatRelativeDate(a.postedAt),
                                  style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont - 1)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(a.text,
                              style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont + 1, height: 1.4)),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      style: TextStyle(color: _textColor, fontSize: _smallFont + 1),
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        hintStyle: TextStyle(color: _textSecondaryColor, fontSize: _smallFont + 1),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: _backgroundSelectedColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, size: 18, color: _primaryColor),
                    onPressed: () {
                      if (replyController.text.trim().isEmpty) return;
                      setState(() {
                        q.answers.add(QnaAnswer(
                          author: 'You',
                          text: replyController.text.trim(),
                          postedAt: DateTime.now(),
                        ));
                      });
                      replyController.clear();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAskQuestionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(_contentPadding, 10, _contentPadding, 14),
      decoration: BoxDecoration(
        color: _backgroundElementColor,
        border: Border(top: BorderSide(color: _textSecondaryColor.withValues(alpha: 0.08))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _questionController,
                focusNode: _questionFocus,
                style: TextStyle(color: _textColor, fontSize: _bodyFont),
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: TextStyle(color: _textSecondaryColor, fontSize: _bodyFont),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: _backgroundSelectedColor,
                ),
                onSubmitted: (_) => _submitQuestion(),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: _primaryColor,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _submitQuestion,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitQuestion() {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _questions.add(QnaQuestion(
        id: 'q${DateTime.now().millisecondsSinceEpoch}',
        author: 'You',
        text: text,
        postedAt: DateTime.now(),
      ));
    });
    _questionController.clear();
    _questionFocus.unfocus();
  }

  // --------------------------------------------------------------------
  // Notes tab
  // --------------------------------------------------------------------
  void _openNoteEditor({LearningNote? existing}) {
    final lesson = _currentLesson!;
    final controller = TextEditingController(text: existing?.content ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _backgroundElementColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          existing == null ? 'Add note — ${lesson.title}' : 'Edit note',
          style: TextStyle(color: _textColor, fontSize: 15),
        ),
        content: TextField(
          controller: controller,
          maxLines: 6,
          autofocus: true,
          style: TextStyle(color: _textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Write what you want to remember from this lesson...',
            hintStyle: TextStyle(color: _textSecondaryColor, fontSize: 12),
            filled: true,
            fillColor: _backgroundSelectedColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: _textSecondaryColor)),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) {
                Navigator.pop(ctx);
                return;
              }
              setState(() {
                if (existing != null) {
                  // Update existing note
                  final index = _notes.indexWhere((n) => n.id == existing.id);
                  if (index != -1) {
                    _notes[index] = LearningNote(
                      id: existing.id,
                      lessonId: existing.lessonId,
                      lessonTitle: existing.lessonTitle,
                      content: text,
                      updatedAt: DateTime.now(),
                    );
                  }
                } else {
                  _notes.add(LearningNote(
                    id: 'n${DateTime.now().millisecondsSinceEpoch}',
                    lessonId: lesson.id,
                    lessonTitle: lesson.title,
                    content: text,
                    updatedAt: DateTime.now(),
                  ));
                }
              });
              Navigator.pop(ctx);
            },
            child: Text('Save', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    final sorted = [..._notes]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Stack(
      children: [
        sorted.isEmpty
            ? _buildEmptyState(Icons.edit_note, 'No notes yet',
                'Tap + to jot down anything from "${_currentLesson!.title}".')
            : _isLargeScreen || _isTablet
                ? GridView.builder(
                    padding: EdgeInsets.fromLTRB(_contentPadding, _contentPadding, _contentPadding, 90),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridColumns,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.4,
                    ),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) => _buildNoteCard(sorted[index]),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(_contentPadding, _contentPadding, _contentPadding, 90),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildNoteCard(sorted[index]),
                    ),
                  ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'add_note_fab',
            backgroundColor: _primaryColor,
            onPressed: () => _openNoteEditor(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(LearningNote note) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_outline, size: 14, color: _primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  note.lessonTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _primaryColor, fontSize: _smallFont, fontWeight: FontWeight.w700),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, size: 18, color: _textSecondaryColor),
                color: _backgroundElementColor,
                onSelected: (value) {
                  if (value == 'edit') _openNoteEditor(existing: note);
                  if (value == 'delete') {
                    setState(() => _notes.removeWhere((n) => n.id == note.id));
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: _textColor))),
                  PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: _textColor))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(note.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _textColor, fontSize: _bodyFont, height: 1.4)),
          const SizedBox(height: 6),
          Text(formatRelativeDate(note.updatedAt),
              style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont - 1)),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------
  // Reviews tab - With API Integration
  // --------------------------------------------------------------------
  Widget _buildReviewsTab() {
    return ListView(
      padding: EdgeInsets.all(_contentPadding),
      children: [
        // Review Form
        AppCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rate this course',
                style: TextStyle(
                  color: _textColor,
                  fontSize: _titleFont - 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              // Rating Stars
              Row(
                children: List.generate(5, (i) {
                  final filled = i < _myRating;
                  return IconButton(
                    onPressed: () => setState(() => _myRating = i + 1),
                    icon: Icon(
                      filled ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF59E0B),
                      size: 28,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              // Review Text Field
              TextField(
                controller: _reviewController,
                maxLines: 3,
                style: TextStyle(color: _textColor, fontSize: _bodyFont),
                decoration: InputDecoration(
                  hintText: 'Share your experience with this course...',
                  hintStyle: TextStyle(color: _textSecondaryColor, fontSize: _smallFont + 1),
                  filled: true,
                  fillColor: _backgroundSelectedColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Submit Button
              AppButton(
                title: 'Submit Review',
                onPressed: _isSubmittingReview ? null : _submitReview,
                isLoading: _isSubmittingReview,
              ),
              if (_reviewError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _reviewError!,
                  style: TextStyle(
                    color: _errorColor,
                    fontSize: _smallFont,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Existing Reviews
        if (widget.course.reviews.isNotEmpty)
          CourseReviews(
            rating: widget.course.rating,
            reviews: widget.course.reviews,
            brightness: _brightness,
          )
        else
          _buildEmptyState(
            Icons.star_outline,
            'No reviews yet',
            'Be the first to review this course!',
          ),
      ],
    );
  }

  // --------------------------------------------------------------------
  // Resources tab (backed by Course.studyMaterials)
  // --------------------------------------------------------------------
  IconData _materialIcon(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.pdf:
        return Icons.picture_as_pdf_outlined;
      case StudyMaterialType.doc:
        return Icons.description_outlined;
      case StudyMaterialType.zip:
        return Icons.folder_zip_outlined;
      case StudyMaterialType.slides:
        return Icons.slideshow_outlined;
      case StudyMaterialType.link:
        return Icons.link;
    }
  }

  Widget _buildResourcesTab() {
    final materials = widget.course.studyMaterials;
    if (materials.isEmpty) {
      return _buildEmptyState(
          Icons.folder_open_outlined, 'No resources yet', 'Downloadable materials will show up here.');
    }

    if (_isLargeScreen || _isTablet) {
      return GridView.builder(
        padding: EdgeInsets.all(_contentPadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridColumns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 3.4,
        ),
        itemCount: materials.length,
        itemBuilder: (context, index) => _buildResourceCard(materials[index]),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(_contentPadding),
      itemCount: materials.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildResourceCard(materials[index]),
      ),
    );
  }

  Widget _buildResourceCard(StudyMaterial m) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_materialIcon(m.type), color: _primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _textColor, fontSize: _bodyFont, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Text(m.sizeLabel, style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont)),
                    if (m.relatedSectionTitle != null) ...[
                      Text('  •  ', style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont)),
                      Flexible(
                        child: Text(
                          m.relatedSectionTitle!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _textSecondaryColor, fontSize: _smallFont),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              m.type == StudyMaterialType.link ? Icons.open_in_new : Icons.download_outlined,
              color: _primaryColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(m.type == StudyMaterialType.link
                        ? 'Opening ${m.title}...'
                        : 'Downloading ${m.title}...')),
              );
            },
          ),
        ],
      ),
    );
  }
}