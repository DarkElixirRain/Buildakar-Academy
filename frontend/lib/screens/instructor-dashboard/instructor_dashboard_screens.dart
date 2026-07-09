// lib/screens/instructor/instructor_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../instructor/course_creation_screen.dart';
import '../instructor/instructor_course_detail_screen.dart';

enum CourseStatus { 
  draft, 
  published, 
  underReview, 
  rejected 
}

class Course {
  final String id;
  String title;
  String description;
  String category;
  double price;
  CourseStatus status;
  int studentsEnrolled;
  DateTime createdAt;
  String? thumbnail;
  String? level;
  double? rating;
  int? reviewsCount;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.status = CourseStatus.draft,
    this.studentsEnrolled = 0,
    DateTime? createdAt,
    this.thumbnail,
    this.level,
    this.rating,
    this.reviewsCount,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Course.fromJson(Map<String, dynamic> json) {
    final statusMap = {
      'DRAFT': CourseStatus.draft,
      'PUBLISHED': CourseStatus.published,
      'UNDER_REVIEW': CourseStatus.underReview,
      'REJECTED': CourseStatus.rejected,
    };

    // Get category name
    String categoryName = 'General';
    if (json['category'] != null) {
      if (json['category'] is Map<String, dynamic>) {
        categoryName = json['category']['name'] ?? 'General';
      } else if (json['category'] is String) {
        categoryName = json['category'];
      }
    }

    return Course(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Course',
      description: json['description'] ?? '',
      category: categoryName,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: statusMap[json['status']] ?? CourseStatus.draft,
      studentsEnrolled: json['studentsCount'] ?? json['studentCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      thumbnail: json['thumbnail'] ?? json['thumbnailUrl'],
      level: json['level'],
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: json['reviewsCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final statusMap = {
      CourseStatus.draft: 'DRAFT',
      CourseStatus.published: 'PUBLISHED',
      CourseStatus.underReview: 'UNDER_REVIEW',
      CourseStatus.rejected: 'REJECTED',
    };

    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'status': statusMap[status],
      'studentsCount': studentsEnrolled,
      'createdAt': createdAt.toIso8601String(),
      'thumbnail': thumbnail,
      'level': level,
    };
  }

  String get statusText {
    switch (status) {
      case CourseStatus.draft:
        return 'Draft';
      case CourseStatus.published:
        return 'Published';
      case CourseStatus.underReview:
        return 'Under Review';
      case CourseStatus.rejected:
        return 'Rejected';
    }
  }

  Color get statusColor {
    switch (status) {
      case CourseStatus.draft:
        return Colors.orange;
      case CourseStatus.published:
        return Colors.green;
      case CourseStatus.underReview:
        return Colors.blue;
      case CourseStatus.rejected:
        return Colors.red;
    }
  }
}

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState
    extends State<InstructorDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Course> _courses = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load courses and stats in parallel
      final results = await Future.wait([
        _apiService.getInstructorCourses(limit: 50),
        _apiService.getInstructorStats(),
      ]);

      // Process courses
      final coursesResponse = results[0];
      if (coursesResponse.success && coursesResponse.data != null) {
        final data = coursesResponse.data!['data'] as List? ?? [];
        setState(() {
          _courses = data.map((json) => Course.fromJson(json)).toList();
        });
      } else {
        setState(() {
          _error = coursesResponse.error ?? 'Failed to load courses';
        });
      }

      // Process stats
      final statsResponse = results[1];
      if (statsResponse.success && statsResponse.data != null) {
        setState(() {
          _stats = statsResponse.data;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  Future<void> _openCreateCourse() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CourseCreationScreen()),
    );
    if (result == true) {
      await _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _openCourseDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstructorCourseDetailScreen(
          courseId: course.id,
          courseTitle: course.title,
        ),
      ),
    );
  }

  Future<void> _deleteCourse(Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),
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
      final response = await _apiService.deleteCourse(course.id);
      if (response.success) {
        setState(() {
          _courses.remove(course);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${course.title}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _refreshData(); // Refresh stats
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
    }
  }

  Future<void> _togglePublish(Course course) async {
    final newStatus = course.status == CourseStatus.published
        ? 'DRAFT'
        : 'PUBLISHED';

    try {
      final response = await _apiService.updateCourseStatus(course.id, newStatus);
      if (response.success) {
        setState(() {
          course.status = course.status == CourseStatus.published
              ? CourseStatus.draft
              : CourseStatus.published;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${course.title}" ${course.status == CourseStatus.published ? 'published' : 'unpublished'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _refreshData(); // Refresh stats
      } else {
        throw Exception(response.error ?? 'Failed to update status');
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

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);

    final totalStudents = _stats?['totalStudents'] ?? 
        _courses.fold<int>(0, (sum, c) => sum + c.studentsEnrolled);
    final published = _stats?['publishedCourses'] ?? 
        _courses.where((c) => c.status == CourseStatus.published).length;
    final totalRevenue = _stats?['totalRevenue'] ?? 0.0;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null && _courses.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
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
                'Error loading courses',
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
                  backgroundColor: AppColors.getPrimaryColor(brightness),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.getPrimaryColor(brightness),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructor Studio',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your courses and students',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: _StatsRow(
                totalCourses: _courses.length,
                published: published,
                totalStudents: totalStudents,
                totalRevenue: totalRevenue,
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Courses (${_courses.length})',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openCreateCourse,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.getPrimaryColor(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_courses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(onCreate: _openCreateCourse),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = _courses[index];
                    return _CourseListTile(
                      course: course,
                      onTap: () => _openCourseDetail(course),
                      onDelete: () => _deleteCourse(course),
                      onTogglePublish: () => _togglePublish(course),
                    );
                  },
                  childCount: _courses.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------
// STATS ROW
// -----------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final int totalCourses;
  final int published;
  final int totalStudents;
  final double totalRevenue;

  const _StatsRow({
    required this.totalCourses,
    required this.published,
    required this.totalStudents,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final cardColor = AppColors.getBackgroundElementColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.video_library_outlined,
              label: 'Courses',
              value: '$totalCourses',
              color: Colors.indigo,
              cardColor: cardColor,
              textColor: textColor,
              textSecondaryColor: textSecondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.cloud_done_outlined,
              label: 'Published',
              value: '$published',
              color: Colors.green,
              cardColor: cardColor,
              textColor: textColor,
              textSecondaryColor: textSecondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.groups_outlined,
              label: 'Students',
              value: '$totalStudents',
              color: Colors.orange,
              cardColor: cardColor,
              textColor: textColor,
              textSecondaryColor: textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final Color textSecondaryColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.textSecondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// EMPTY STATE
// -----------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.video_call_outlined,
              size: 72,
              color: textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No courses yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your first course to start teaching students.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: textSecondaryColor,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create your first course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------
// COURSE LIST TILE - WITH ON TAP
// -----------------------------------------------------------------------

class _CourseListTile extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePublish;

  const _CourseListTile({
    required this.course,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final cardColor = AppColors.getBackgroundElementColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    
    final isPublished = course.status == CourseStatus.published;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80,
                height: 56,
                color: primaryColor.withValues(alpha: 0.1),
                child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                    ? Image.network(
                        course.thumbnail!,
                        width: 80,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.play_circle_outline,
                            color: primaryColor.withValues(alpha: 0.5),
                            size: 28,
                          );
                        },
                      )
                    : Icon(
                        Icons.play_circle_outline,
                        color: primaryColor.withValues(alpha: 0.5),
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Course info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    course.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Status and stats row
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _StatusChip(
                        label: course.statusText,
                        color: course.statusColor,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 14,
                            color: textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.studentsEnrolled}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${course.price.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      if (course.rating != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.rating!.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: textSecondaryColor,
                              ),
                            ),
                            if (course.reviewsCount != null)
                              Text(
                                ' (${course.reviewsCount})',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: textSecondaryColor,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu button
            SizedBox(
              width: 40,
              child: PopupMenuButton<String>(
                color: cardColor,
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                  if (value == 'toggle') onTogglePublish();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(
                      isPublished ? 'Unpublish' : 'Publish',
                      style: GoogleFonts.inter(color: textColor),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      'Edit',
                      style: GoogleFonts.inter(color: textColor),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}