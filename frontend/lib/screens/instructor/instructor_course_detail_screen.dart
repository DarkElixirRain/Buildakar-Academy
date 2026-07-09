// lib/screens/instructor/instructor_course_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';

enum CourseTab {
  overview,
  content,
  reviews,
  qa,
  analytics,
}

class InstructorCourseDetailScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const InstructorCourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<InstructorCourseDetailScreen> createState() =>
      _InstructorCourseDetailScreenState();
}

class _InstructorCourseDetailScreenState
    extends State<InstructorCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  
  // Course Data
  Map<String, dynamic> _courseData = {};
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _qaQuestions = [];
  Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );
    _loadCourseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourseData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load course details
      final courseResponse = await _apiService.getCourseById(widget.courseId);
      if (courseResponse.success && courseResponse.data != null) {
        final data = courseResponse.data!;
        setState(() {
          _courseData = {
            'id': data['id'] ?? widget.courseId,
            'title': data['title'] ?? widget.courseTitle,
            'subtitle': data['subtitle'] ?? '',
            'description': data['description'] ?? '',
            'status': data['status'] ?? 'DRAFT',
            'level': data['level'] ?? 'Beginner',
            'language': data['language'] ?? 'English',
            'price': data['price'] ?? 0.0,
            'discountPrice': data['discountPrice'],
            'category': data['category'] ?? {'name': 'General'},
            'instructor': data['instructor'] ?? {'name': 'Unknown Instructor'},
            'studentsCount': data['studentsCount'] ?? 0,
            'rating': data['rating'] ?? 0.0,
            'reviewsCount': data['reviewsCount'] ?? 0,
            'lessonCount': data['lessonCount'] ?? 0,
            'createdAt': data['createdAt'] ?? '',
            'lastUpdated': data['lastUpdated'] ?? '',
            'whatYouWillLearn': data['whatYouWillLearn'] ?? [],
          };
        });
      } else {
        throw Exception(courseResponse.error ?? 'Failed to load course');
      }

      // Load sections with lessons
      final sectionsResponse = await _apiService.getCourseSections(widget.courseId);
      if (sectionsResponse.success && sectionsResponse.data != null) {
        final sectionsData = sectionsResponse.data!;
        print('✅ Sections loaded: ${sectionsData.length}');
        setState(() {
          _sections = sectionsData.map((section) {
            final lessons = (section['lessons'] as List? ?? []).map((lesson) {
              return {
                'id': lesson['id']?.toString() ?? '',
                'title': lesson['title'] ?? 'Untitled Lesson',
                'type': lesson['type'] ?? 'video',
                'duration': lesson['duration'] ?? '0:00',
                'isPreview': lesson['isPreview'] ?? false,
                'description': lesson['description'] ?? '',
                'videoUrl': lesson['videoUrl'],
              };
            }).toList();
            
            return {
              'id': section['id']?.toString() ?? '',
              'title': section['title'] ?? 'Untitled Section',
              'order': section['order'] ?? 0,
              'lessons': lessons,
            };
          }).toList();
        });
      } else {
        print('❌ Failed to load sections: ${sectionsResponse.error}');
      }

      // Load reviews
      final reviewsResponse = await _apiService.getCourseReviews(
        courseId: widget.courseId,
        limit: 50,
      );
      if (reviewsResponse.success && reviewsResponse.data != null) {
        final reviewsData = reviewsResponse.data!['data'] as List? ?? [];
        print('✅ Reviews loaded: ${reviewsData.length}');
        setState(() {
          _reviews = reviewsData.map((review) {
            final student = review['student'] as Map<String, dynamic>? ?? {};
            return {
              'id': review['id']?.toString() ?? '',
              'student': {
                'id': student['id']?.toString() ?? '',
                'name': student['name'] ?? 'Anonymous',
                'avatar': student['avatar'] ?? 
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(student['name'] ?? 'User')}&size=150&background=4F46E5&color=fff',
              },
              'rating': review['rating'] ?? 0,
              'comment': review['comment'] ?? '',
              'createdAt': review['createdAt'] ?? '',
              'isHelpful': review['isHelpful'] ?? 0,
            };
          }).toList();
        });
      } else {
        print('❌ Failed to load reviews: ${reviewsResponse.error}');
      }

      // Load analytics
      final analyticsResponse = await _apiService.getCourseAnalytics(
        courseId: widget.courseId,
      );
      if (analyticsResponse.success && analyticsResponse.data != null) {
        setState(() {
          _analytics = analyticsResponse.data!;
        });
      } else {
        // Use calculated analytics if API fails
        setState(() {
          _analytics = {
            'totalStudents': _courseData['studentsCount'] ?? 0,
            'totalRevenue': (_courseData['studentsCount'] ?? 0) * (_courseData['price'] ?? 0),
            'avgRating': _courseData['rating'] ?? 0.0,
            'totalReviews': _courseData['reviewsCount'] ?? 0,
            'completionRate': 72,
            'engagement': 85,
            'monthlyGrowth': 12,
            'retentionRate': 89,
            'topPerformingSection': _sections.isNotEmpty ? _sections[0]['title'] : 'N/A',
            'avgQuizScore': 84,
            'totalCertificates': (_courseData['studentsCount'] ?? 0) ~/ 2,
          };
        });
      }

      // Load Q&A (will be replaced with real API when available)
      setState(() {
        _qaQuestions = [
          {
            'id': 'q1',
            'student': {
              'id': 's1',
              'name': 'Sarah Johnson',
              'avatar': 'https://ui-avatars.com/api/?name=Sarah+Johnson&size=150&background=6366F1&color=fff',
            },
            'question': 'How long does it typically take to complete this course?',
            'answer': 'The course is designed to be completed in 4-6 weeks if you dedicate 3-4 hours per week.',
            'answered': true,
            'answeredAt': '2024-06-14',
            'date': '2024-06-10',
            'likes': 15,
          },
          {
            'id': 'q2',
            'student': {
              'id': 's5',
              'name': 'James Wilson',
              'avatar': 'https://ui-avatars.com/api/?name=James+Wilson&size=150&background=F59E0B&color=fff',
            },
            'question': 'Do I need prior experience to take this course?',
            'answer': null,
            'answered': false,
            'answeredAt': null,
            'date': '2024-06-16',
            'likes': 5,
          },
        ];
      });

      // Activities (dummy data)
      setState(() {
        _activities = [
          {
            'icon': Icons.person_add_rounded,
            'color': Colors.green,
            'title': 'New Enrollment',
            'description': 'A new student enrolled in your course',
            'time': '2 hours ago',
          },
          {
            'icon': Icons.star_rounded,
            'color': Colors.amber,
            'title': 'New Review',
            'description': 'A student left a 5-star review',
            'time': '5 hours ago',
          },
          {
            'icon': Icons.question_answer_rounded,
            'color': Colors.blue,
            'title': 'New Question',
            'description': 'A student asked a question',
            'time': '1 day ago',
          },
        ];
      });

      setState(() => _isLoading = false);
    } catch (e, stackTrace) {
      print('❌ Error loading course data: $e');
      print(stackTrace);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadCourseData();
  }

  // ============================================
  // REVIEW METHODS
  // ============================================

  Future<void> _deleteReview(String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _apiService.deleteReview(reviewId);
      if (response.success) {
        setState(() {
          _reviews.removeWhere((review) => review['id'] == reviewId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _refreshData(); // Refresh to update counts
      } else {
        throw Exception(response.error ?? 'Failed to delete review');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================
  // Q&A METHODS
  // ============================================

  Future<void> _answerQuestion(String questionId) async {
    final TextEditingController answerController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Answer Question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _qaQuestions.firstWhere((q) => q['id'] == questionId)['question'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your answer...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (answerController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Post Answer'),
          ),
        ],
      ),
    );

    if (result == true && answerController.text.trim().isNotEmpty) {
      try {
        // TODO: Implement answer API
        setState(() {
          final index = _qaQuestions.indexWhere(
            (q) => q['id'] == questionId,
          );
          if (index != -1) {
            _qaQuestions[index]['answer'] = answerController.text.trim();
            _qaQuestions[index]['answered'] = true;
            _qaQuestions[index]['answeredAt'] = DateTime.now().toIso8601String();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ============================================
  // COURSE MANAGEMENT METHODS
  // ============================================

  Future<void> _publishCourse() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await _apiService.updateCourseStatus(
        widget.courseId,
        'PUBLISHED',
      );
      if (response.success) {
        setState(() {
          _courseData['status'] = 'PUBLISHED';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response.error ?? 'Failed to publish course');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _unpublishCourse() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await _apiService.updateCourseStatus(
        widget.courseId,
        'DRAFT',
      );
      if (response.success) {
        setState(() {
          _courseData['status'] = 'DRAFT';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course unpublished successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception(response.error ?? 'Failed to unpublish course');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteCourse() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text(
          'Are you sure you want to delete this course? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    try {
      final response = await _apiService.deleteCourse(widget.courseId);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(response.error ?? 'Failed to delete course');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _duplicateCourse() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await _apiService.duplicateCourse(widget.courseId);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course duplicated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(response.error ?? 'Failed to duplicate course');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ============================================
  // UI METHODS
  // ============================================

  void _showReviewActions(Map<String, dynamic> review) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = AppColors.getTextColor(brightness);
    final cardColor = AppColors.getBackgroundElementColor(brightness);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply, color: Colors.blue),
              title: Text(
                'Reply to Review',
                style: GoogleFonts.inter(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reply feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.orange),
              title: Text(
                'Report Review',
                style: GoogleFonts.inter(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review reported successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Review',
                style: GoogleFonts.inter(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteReview(review['id']);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = AppColors.getTextColor(brightness);
    final cardColor = AppColors.getBackgroundElementColor(brightness);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.blue),
              title: Text(
                'Edit Course',
                style: GoogleFonts.inter(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit course coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined, color: Colors.purple),
              title: Text(
                'Duplicate Course',
                style: GoogleFonts.inter(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _duplicateCourse();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined, color: Colors.orange),
              title: Text(
                'Export Course Data',
                style: GoogleFonts.inter(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting course data...')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.orange),
              title: Text(
                'Archive Course',
                style: GoogleFonts.inter(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course archived!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Delete Course',
                style: GoogleFonts.inter(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteCourse();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  // ============================================
  // BUILD METHODS
  // ============================================

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final cardColor = AppColors.getBackgroundElementColor(brightness);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.courseTitle,
            style: GoogleFonts.inter(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: cardColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.courseTitle,
            style: GoogleFonts.inter(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: cardColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading course',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  color: textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isPublished = _courseData['status'] == 'PUBLISHED';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.courseTitle,
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: primaryColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit course feature coming soon!'),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: textColor,
            ),
            onPressed: _showMoreOptions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondaryColor,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Content'),
            Tab(text: 'Reviews'),
            Tab(text: 'Q&A'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryColor,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(
              brightness, textColor, textSecondaryColor, cardColor, primaryColor,
              isPublished,
            ),
            _buildContentTab(
              brightness, textColor, textSecondaryColor, cardColor, primaryColor,
            ),
            _buildReviewsTab(
              brightness, textColor, textSecondaryColor, cardColor, primaryColor,
            ),
            _buildQATab(
              brightness, textColor, textSecondaryColor, cardColor, primaryColor,
            ),
            _buildAnalyticsTab(
              brightness, textColor, textSecondaryColor, cardColor, primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // OVERVIEW TAB
  // ============================================

  Widget _buildOverviewTab(
    Brightness brightness,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
    Color primaryColor,
    bool isPublished,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Status and Actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPublished
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _courseData['status'] ?? 'DRAFT',
                  style: GoogleFonts.inter(
                    color: isPublished ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (isPublished)
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _unpublishCourse,
                  icon: const Icon(Icons.visibility_off, size: 18),
                  label: const Text('Unpublish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _publishCourse,
                  icon: const Icon(Icons.publish_rounded, size: 18),
                  label: const Text('Publish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Course Stats Cards
          Row(
            children: [
              _buildStatCard(
                'Students',
                '${_courseData['studentsCount'] ?? 0}',
                Icons.people_rounded,
                Colors.blue,
                cardColor,
                textColor,
                textSecondaryColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Rating',
                '${_courseData['rating'] ?? 0.0} ⭐',
                Icons.star_rounded,
                Colors.amber,
                cardColor,
                textColor,
                textSecondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                'Lessons',
                '${_courseData['lessonCount'] ?? 0}',
                Icons.play_circle_rounded,
                Colors.purple,
                cardColor,
                textColor,
                textSecondaryColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Revenue',
                '\$${(_courseData['studentsCount'] ?? 0) * (_courseData['price'] ?? 0)}',
                Icons.attach_money_rounded,
                Colors.green,
                cardColor,
                textColor,
                textSecondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Course Description
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _courseData['description'] ?? 'No description available',
            style: GoogleFonts.inter(
              color: textSecondaryColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // What You'll Learn
          if (_courseData['whatYouWillLearn'] != null &&
              (_courseData['whatYouWillLearn'] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What You\'ll Learn',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                ...(_courseData['whatYouWillLearn'] as List).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: GoogleFonts.inter(
                              color: textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),

          // Course Info
          Text(
            'Course Information',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Category', _courseData['category']?['name'] ?? 'General', textColor, textSecondaryColor),
          _buildInfoRow('Level', _courseData['level'] ?? 'Beginner', textColor, textSecondaryColor),
          _buildInfoRow('Language', _courseData['language'] ?? 'English', textColor, textSecondaryColor),
          _buildInfoRow('Price', '\$${_courseData['price'] ?? 0}', textColor, textSecondaryColor),
          _buildInfoRow('Created', _formatDate(_courseData['createdAt']), textColor, textSecondaryColor),
          _buildInfoRow('Last Updated', _formatDate(_courseData['lastUpdated']), textColor, textSecondaryColor),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color cardColor,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CONTENT TAB - Using Real Section Data
  // ============================================

  Widget _buildContentTab(
    Brightness brightness,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
    Color primaryColor,
  ) {
    if (_sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Content Yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add sections and lessons to build your course.',
              style: GoogleFonts.inter(
                color: textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add section coming soon!')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Section'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sections.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Course Content (${_sections.length} sections)',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add section coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Section'),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        final section = _sections[index - 1];
        final lessons = section['lessons'] as List? ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              section['title'] ?? 'Untitled Section',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            subtitle: Text(
              '${lessons.length} lessons',
              style: GoogleFonts.inter(
                color: textSecondaryColor,
                fontSize: 12,
              ),
            ),
            trailing: PopupMenuButton<String>(
              color: cardColor,
              onSelected: (value) {
                if (value == 'edit') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit section coming soon!')),
                  );
                } else if (value == 'delete') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delete section coming soon!')),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Section'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Section', style: TextStyle(color: Colors.red)),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                color: textSecondaryColor,
              ),
            ),
            children: lessons.map<Widget>((lesson) {
              return _buildLessonTile(lesson, textColor, textSecondaryColor, cardColor, primaryColor);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLessonTile(
    Map<String, dynamic> lesson,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
    Color primaryColor,
  ) {
    final iconMap = {
      'video': Icons.play_circle_outline,
      'quiz': Icons.quiz_outlined,
      'project': Icons.code_rounded,
      'assignment': Icons.assignment_outlined,
    };

    final colorMap = {
      'video': Colors.blue,
      'quiz': Colors.orange,
      'project': Colors.purple,
      'assignment': Colors.green,
    };

    return ListTile(
      leading: Icon(
        iconMap[lesson['type']] ?? Icons.description_outlined,
        color: colorMap[lesson['type']] ?? textSecondaryColor,
      ),
      title: Text(
        lesson['title'] ?? 'Untitled Lesson',
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        lesson['duration'] ?? '0:00',
        style: GoogleFonts.inter(
          color: textSecondaryColor,
          fontSize: 12,
        ),
      ),
      trailing: PopupMenuButton<String>(
        color: cardColor,
        onSelected: (value) {
          if (value == 'edit') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit lesson coming soon!')),
            );
          } else if (value == 'delete') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Delete lesson coming soon!')),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit Lesson'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete Lesson', style: TextStyle(color: Colors.red)),
          ),
        ],
        child: Icon(
          Icons.more_vert,
          color: textSecondaryColor,
          size: 18,
        ),
      ),
    );
  }

  // ============================================
  // REVIEWS TAB - Using Real Review Data
  // ============================================

  Widget _buildReviewsTab(
    Brightness brightness,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
    Color primaryColor,
  ) {
    final avgRating = _courseData['rating'] ?? 0.0;
    final totalReviews = _courseData['reviewsCount'] ?? 0;

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline_rounded,
              size: 64,
              color: textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Reviews Yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Students will leave reviews after completing the course.',
              style: GoogleFonts.inter(
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Rating Summary
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < avgRating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  Text(
                    '$totalReviews reviews',
                    style: GoogleFonts.inter(
                      color: textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 45, textSecondaryColor),
                    _buildRatingBar(4, 30, textSecondaryColor),
                    _buildRatingBar(3, 15, textSecondaryColor),
                    _buildRatingBar(2, 7, textSecondaryColor),
                    _buildRatingBar(1, 3, textSecondaryColor),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Reviews List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              final rating = review['rating'] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            review['student']['avatar'] ?? 
                            'https://ui-avatars.com/api/?name=User&size=150&background=4F46E5&color=fff',
                          ),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['student']['name'] ?? 'Anonymous',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < rating ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(review['createdAt']),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review['comment'] ?? 'No comment provided.',
                      style: GoogleFonts.inter(
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reply feature coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.reply, size: 16),
                          label: const Text('Reply'),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            _showReviewActions(review);
                          },
                          icon: const Icon(Icons.more_vert, size: 16),
                          label: const Text('More'),
                          style: TextButton.styleFrom(
                            foregroundColor: textSecondaryColor,
                          ),
                        ),
                      ],
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

  Widget _buildRatingBar(int rating, int percentage, Color textSecondaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rating ★',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$percentage%',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Q&A TAB
  // ============================================

  Widget _buildQATab(
    Brightness brightness,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
    Color primaryColor,
  ) {
    final unansweredCount = _qaQuestions.where((q) => !q['answered']).length;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q&A',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '${_qaQuestions.length} total questions • $unansweredCount unanswered',
                    style: GoogleFonts.inter(
                      color: textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (unansweredCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$unansweredCount Pending',
                    style: GoogleFonts.inter(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Questions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _qaQuestions.length,
            itemBuilder: (context, index) {
              final qa = _qaQuestions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: qa['answered']
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            qa['student']['avatar'] ?? 
                            'https://ui-avatars.com/api/?name=User&size=150&background=4F46E5&color=fff',
                          ),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                qa['student']['name'] ?? 'Anonymous',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                qa['date'] ?? 'Recently',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: qa['answered']
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            qa['answered'] ? 'Answered' : 'Pending',
                            style: GoogleFonts.inter(
                              color: qa['answered'] ? Colors.green : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      qa['question'],
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    if (qa['answer'] != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Answer',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  qa['answeredAt'] ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              qa['answer']!,
                              style: GoogleFonts.inter(
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (!qa['answered'])
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _answerQuestion(qa['id']),
                          icon: const Icon(Icons.reply, size: 18),
                          label: const Text('Answer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
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

  // ============================================
  // ANALYTICS TAB
  // ============================================

  Widget _buildAnalyticsTab(
    Brightness brightness,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
    Color primaryColor,
  ) {
    final analytics = _analytics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Performance',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your course metrics and student engagement',
            style: GoogleFonts.inter(
              color: textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Analytics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildAnalyticsCard(
                'Students',
                '${analytics['totalStudents'] ?? 0}',
                Icons.people_rounded,
                Colors.blue,
                cardColor,
                textColor,
                textSecondaryColor,
                '+${analytics['monthlyGrowth'] ?? 0}%',
              ),
              _buildAnalyticsCard(
                'Revenue',
                '\$${analytics['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                Icons.attach_money_rounded,
                Colors.green,
                cardColor,
                textColor,
                textSecondaryColor,
                'Lifetime',
              ),
              _buildAnalyticsCard(
                'Rating',
                '${analytics['avgRating'] ?? 0} ⭐',
                Icons.star_rounded,
                Colors.amber,
                cardColor,
                textColor,
                textSecondaryColor,
                '${analytics['totalReviews'] ?? 0} reviews',
              ),
              _buildAnalyticsCard(
                'Completion',
                '${analytics['completionRate'] ?? 0}%',
                Icons.trending_up_rounded,
                Colors.orange,
                cardColor,
                textColor,
                textSecondaryColor,
                'Rate',
              ),
              _buildAnalyticsCard(
                'Engagement',
                '${analytics['engagement'] ?? 0}%',
                Icons.insights_rounded,
                Colors.purple,
                cardColor,
                textColor,
                textSecondaryColor,
                'Active',
              ),
              _buildAnalyticsCard(
                'Retention',
                '${analytics['retentionRate'] ?? 0}%',
                Icons.people_alt_rounded,
                Colors.teal,
                cardColor,
                textColor,
                textSecondaryColor,
                'Rate',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Additional Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildAnalyticsInfoRow(
                  'Top Performing Section',
                  analytics['topPerformingSection'] ?? 'N/A',
                  Icons.trending_up_rounded,
                  Colors.green,
                  textColor,
                  textSecondaryColor,
                ),
                const Divider(),
                _buildAnalyticsInfoRow(
                  'Average Quiz Score',
                  '${analytics['avgQuizScore'] ?? 0}%',
                  Icons.quiz_outlined,
                  Colors.orange,
                  textColor,
                  textSecondaryColor,
                ),
                const Divider(),
                _buildAnalyticsInfoRow(
                  'Total Certificates',
                  '${analytics['totalCertificates'] ?? 0}',
                  Icons.emoji_events_rounded,
                  Colors.amber,
                  textColor,
                  textSecondaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Activity',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: _activities.map((activity) {
                return _buildActivityItem(
                  activity['icon'],
                  activity['color'],
                  activity['title'],
                  activity['description'],
                  activity['time'],
                  textColor,
                  textSecondaryColor,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Export Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exporting analytics data...'),
                  ),
                );
              },
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export Analytics Data'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color cardColor,
    Color textColor,
    Color textSecondaryColor,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: textSecondaryColor,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    Color color,
    String title,
    String description,
    String time,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}