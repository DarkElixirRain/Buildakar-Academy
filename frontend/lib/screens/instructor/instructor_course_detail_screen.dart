// lib/screens/instructor/instructor_course_detail_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/instructor_course_provider.dart';
import '../../services/api_service.dart';
import 'course_edit_screen.dart';
import '../../core/widgets/app_card.dart';

enum CourseTab {
  overview,
  content,
  reviews,
  qa,
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
  late final InstructorCourseProvider _courseProvider;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  
  // Course Data
  Map<String, dynamic> _courseData = {};
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _qaQuestions = [];
  List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> _activities = [];

  // Section/Lesson processing state
  bool _isProcessingSection = false;
  bool _isProcessingLesson = false;
  String? _processingSectionId;
  String? _processingLessonId;

  @override
  void initState() {
    super.initState();
    _courseProvider = Provider.of<InstructorCourseProvider>(context, listen: false);
    _tabController = TabController(
      length: 4,
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
      final courseResponse = await _apiService.getCourseByIdAuthenticated(widget.courseId);
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

      final sectionsResponse = await _apiService.getCourseSections(widget.courseId);
      if (sectionsResponse.success && sectionsResponse.data != null) {
        final sectionsData = sectionsResponse.data!;
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
      }

      final reviewsResponse = await _apiService.getCourseReviews(
        courseId: widget.courseId,
        limit: 50,
      );
      if (reviewsResponse.success && reviewsResponse.data != null) {
        final reviewsData = reviewsResponse.data!['data'] as List? ?? [];
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
      }

      setState(() {
        _qaQuestions = [];
        _activities = [];
        _isLoading = false;
      });
    } catch (e, stackTrace) {
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
              foregroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
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
          SnackBar(
            content: const Text('Review deleted successfully'),
            backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
          ),
        );
        await _refreshData();
      } else {
        throw Exception(response.error ?? 'Failed to delete review');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
        ),
      );
    }
  }

  // ============================================
  // Q&A METHODS
  // ============================================

  Future<void> _answerQuestion(String questionId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No questions to answer'),
      ),
    );
  }

  // ============================================
  // COURSE MANAGEMENT METHODS
  // ============================================

  Future<void> _submitForReview() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await _apiService.updateCourseStatus(
        widget.courseId,
        'UNDER_REVIEW',
      );
      if (response.success) {
        setState(() {
          _courseData['status'] = 'UNDER_REVIEW';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course submitted for admin review!'),
            backgroundColor: AppColors.getPrimaryColor(Theme.of(context).brightness),
          ),
        );
      } else {
        throw Exception(response.error ?? 'Failed to submit course for review');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
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
          SnackBar(
            content: Text('Course unpublished successfully!'),
            backgroundColor: AppColors.getWarningColor(Theme.of(context).brightness),
          ),
        );
      } else {
        throw Exception(response.error ?? 'Failed to unpublish course');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PUBLISHED': return 'Published';
      case 'PENDING_APPROVAL': return 'Pending Approval';
      case 'DRAFT': return 'Draft';
      case 'UNDER_REVIEW': return 'Under Review';
      default: return status;
    }
  }

  Color _statusColor(String status, Brightness brightness) {
    switch (status) {
      case 'PUBLISHED': return AppColors.getSuccessColor(brightness);
      case 'PENDING_APPROVAL': return AppColors.getPrimaryColor(brightness);
      case 'DRAFT': return AppColors.getWarningColor(brightness);
      case 'UNDER_REVIEW': return AppColors.getPrimaryColor(brightness);
      default: return AppColors.getTextSecondaryColor(brightness);
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
              foregroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
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
          SnackBar(
            content: Text('Course deleted successfully'),
            backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
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
          backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
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
          SnackBar(
            content: Text('Course duplicated successfully!'),
            backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
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
          backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _navigateToEditCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseEditScreen(
          courseId: widget.courseId,
          courseData: _courseData,
        ),
      ),
    ).then((edited) {
      if (edited == true) _loadCourseData();
    });
  }

  // ============================================
  // SECTION CRUD
  // ============================================

  Future<void> _showAddSectionDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Section'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Section Title',
                  hintText: 'e.g. Introduction',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isProcessingSection = true);
      try {
        final response = await _apiService.createSection(widget.courseId, {
          'title': titleController.text.trim(),
          if (descController.text.trim().isNotEmpty) 'description': descController.text.trim(),
        });
        if (response.success && response.data != null) {
          final newSection = response.data!;
          setState(() {
            _sections.add({
              'id': newSection['id']?.toString() ?? '',
              'title': newSection['title'] ?? 'Untitled Section',
              'order': newSection['order'] ?? _sections.length,
              'lessons': <Map<String, dynamic>>[],
            });
          });
          await _loadCourseData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Section created'),
                backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
              ),
            );
          }
        } else {
          throw Exception(response.error ?? 'Failed to create section');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessingSection = false);
      }
    }
    titleController.dispose();
    descController.dispose();
  }

  Future<void> _showEditSectionDialog(Map<String, dynamic> section) async {
    final titleController = TextEditingController(text: section['title'] ?? '');
    final descController = TextEditingController(text: section['description'] ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Section'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Section Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isProcessingSection = true);
      try {
        final response = await _apiService.updateSection(section['id'], {
          'title': titleController.text.trim(),
          if (descController.text.trim().isNotEmpty) 'description': descController.text.trim(),
        });
        if (response.success) {
          setState(() {
            final idx = _sections.indexWhere((s) => s['id'] == section['id']);
            if (idx != -1) {
              _sections[idx]['title'] = titleController.text.trim();
              if (descController.text.trim().isNotEmpty) _sections[idx]['description'] = descController.text.trim();
            }
          });
          await _loadCourseData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Section updated'),
                backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
              ),
            );
          }
        } else {
          throw Exception(response.error ?? 'Failed to update section');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessingSection = false);
      }
    }
    titleController.dispose();
    descController.dispose();
  }

  Future<void> _deleteSectionConfirm(Map<String, dynamic> section) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Section'),
        content: Text('Delete "${section['title']}" and all its lessons?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isProcessingSection = true);
      try {
        final response = await _apiService.deleteSection(section['id']);
        if (response.success) {
          setState(() {
            _sections.removeWhere((s) => s['id'] == section['id']);
          });
          await _loadCourseData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Section deleted'),
                backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
              ),
            );
          }
        } else {
          throw Exception(response.error ?? 'Failed to delete section');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessingSection = false);
      }
    }
  }

  // ============================================
  // LESSON CRUD - FULLY RESPONSIVE WITH KEYBOARD FIX
  // ============================================

  Future<void> _showAddLessonDialog(String sectionId) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final durationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Lesson'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Lesson Title',
                      hintText: 'e.g. Introduction to Flutter',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (optional)',
                      hintText: 'e.g. 10:30',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        _isProcessingLesson = true;
        _processingSectionId = sectionId;
      });
      try {
        final response = await _apiService.createLesson(sectionId, {
          'title': titleController.text.trim(),
          if (descController.text.trim().isNotEmpty) 'description': descController.text.trim(),
          if (durationController.text.trim().isNotEmpty) 'duration': durationController.text.trim(),
        });
        if (response.success && response.data != null) {
          final newLesson = response.data!;
          setState(() {
            final sectionIndex = _sections.indexWhere((s) => s['id'] == sectionId);
            if (sectionIndex != -1) {
              final lessons = _sections[sectionIndex]['lessons'] as List<Map<String, dynamic>>;
              lessons.add({
                'id': newLesson['id']?.toString() ?? '',
                'title': newLesson['title'] ?? 'Untitled Lesson',
                'type': newLesson['type'] ?? 'video',
                'duration': newLesson['duration'] ?? '0:00',
                'isPreview': newLesson['isPreview'] ?? false,
                'description': newLesson['description'] ?? '',
                'videoUrl': newLesson['videoUrl'],
              });
            }
          });
          await _loadCourseData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lesson created successfully'),
                backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
              ),
            );
          }
        } else {
          throw Exception(response.error ?? 'Failed to create lesson');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessingLesson = false;
            _processingSectionId = null;
          });
        }
      }
    }
    titleController.dispose();
    descController.dispose();
    durationController.dispose();
  }

  Future<void> _showEditLessonDialog(Map<String, dynamic> lesson) async {
    final titleController = TextEditingController(text: lesson['title'] ?? '');
    final descController = TextEditingController(text: lesson['description'] ?? '');
    final durationController = TextEditingController(text: lesson['duration'] ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Lesson'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Lesson Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      hintText: 'e.g. 10:30',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() => _isProcessingLesson = true);
      try {
        final response = await _apiService.updateLesson(lesson['id'], {
          'title': titleController.text.trim(),
          if (descController.text.trim().isNotEmpty) 'description': descController.text.trim(),
          if (durationController.text.trim().isNotEmpty) 'duration': durationController.text.trim(),
        });
        if (response.success) {
          setState(() {
            for (final section in _sections) {
              final lessons = section['lessons'] as List<Map<String, dynamic>>?;
              if (lessons != null) {
                final idx = lessons.indexWhere((l) => l['id'] == lesson['id']);
                if (idx != -1) {
                  lessons[idx]['title'] = titleController.text.trim();
                  if (descController.text.trim().isNotEmpty) lessons[idx]['description'] = descController.text.trim();
                  if (durationController.text.trim().isNotEmpty) lessons[idx]['duration'] = durationController.text.trim();
                }
              }
            }
          });
          await _loadCourseData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lesson updated successfully'),
                backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
              ),
            );
          }
        } else {
          throw Exception(response.error ?? 'Failed to update lesson');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessingLesson = false);
      }
    }
    titleController.dispose();
    descController.dispose();
    durationController.dispose();
  }

  Future<void> _deleteLessonConfirm(Map<String, dynamic> lesson) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: Text('Delete "${lesson['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isProcessingLesson = true);
      try {
        final response = await _apiService.deleteLesson(lesson['id']);
        if (response.success) {
          setState(() {
            for (final section in _sections) {
              final lessons = section['lessons'] as List<Map<String, dynamic>>?;
              if (lessons != null) {
                lessons.removeWhere((l) => l['id'] == lesson['id']);
              }
            }
          });
          await _loadCourseData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lesson deleted successfully'),
                backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
              ),
            );
          }
        } else {
          throw Exception(response.error ?? 'Failed to delete lesson');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessingLesson = false);
      }
    }
  }

  // ============================================
  // VIDEO UPLOAD
  // ============================================

  Future<void> _showVideoUploadDialog(Map<String, dynamic> lesson) async {
    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;

      final file = File(video.path);
      final fileSizeMb = file.lengthSync() / (1024 * 1024);

      if (!mounted) return;
      _showUploadProgressDialog(lesson, file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: ${e.toString()}'),
            backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
          ),
        );
      }
    }
  }

  void _showUploadProgressDialog(Map<String, dynamic> lesson, File videoFile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final progress = _courseProvider.uploadProgress;
            final phase = _courseProvider.uploadPhase;
            final isUploading = _courseProvider.isUploading;
            final fileSizeMb = videoFile.lengthSync() / (1024 * 1024);

            return AlertDialog(
              title: const Text('Upload Video'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase,
                      style: TextStyle(
                        fontSize: 14,
                        color: phase == 'Complete!'
                            ? Colors.green
                            : phase == 'Failed'
                                ? Colors.red
                                : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: phase == 'Complete!'
                            ? 1.0
                            : phase == 'Failed'
                                ? 0.0
                                : progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          phase == 'Complete!'
                              ? Colors.green
                              : phase == 'Failed'
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      phase == 'Complete!'
                          ? 'Video uploaded successfully'
                          : phase == 'Failed'
                              ? 'Upload failed. Please try again.'
                              : '${(progress * 100).toStringAsFixed(0)}% — ${fileSizeMb.toStringAsFixed(1)} MB',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              actions: [
                if (!isUploading)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (phase == 'Complete!') {
                        _loadCourseData();
                      }
                    },
                    child: Text(phase == 'Failed' ? 'Dismiss' : 'Done'),
                  ),
              ],
            );
          },
        );
      },
    );

    _courseProvider.uploadLessonVideo(lesson['id'], videoFile).then((success) {
      if (success && mounted) {
        _loadCourseData();
      }
    });
  }

  Future<void> _deleteVideoConfirm(Map<String, dynamic> lesson) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Remove video from "${lesson['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _apiService.deleteLessonVideo(lesson['id']);
        if (response.success) {
          await _loadCourseData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Video deleted successfully'),
                backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
              ),
            );
          }
        } else {
          throw Exception(response.error ?? 'Failed to delete video');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
            ),
          );
        }
      }
    }
  }

  // ============================================
  // UI METHODS
  // ============================================

  void _showReviewActions(Map<String, dynamic> review) {
    final brightness = Theme.of(context).brightness;
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
              leading: Icon(Icons.reply, color: AppColors.getPrimaryColor(brightness)),
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
              leading: Icon(Icons.flag, color: AppColors.getWarningColor(brightness)),
              title: Text(
                'Report Review',
                style: GoogleFonts.inter(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Review reported successfully'),
                    backgroundColor: AppColors.getSuccessColor(brightness),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.getErrorColor(brightness)),
              title: Text(
                'Delete Review',
                style: GoogleFonts.inter(color: AppColors.getErrorColor(brightness)),
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
    final brightness = Theme.of(context).brightness;
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
              leading: Icon(Icons.edit_outlined, color: AppColors.getPrimaryColor(brightness)),
              title: Text(
                'Edit Course',
                style: GoogleFonts.inter(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditCourse();
              },
            ),
            ListTile(
              leading: Icon(Icons.copy_outlined, color: AppColors.getPrimaryLightColor(brightness)),
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
              leading: Icon(Icons.download_outlined, color: AppColors.getWarningColor(brightness)),
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
              leading: Icon(Icons.archive_outlined, color: AppColors.getWarningColor(brightness)),
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
              leading: Icon(Icons.delete_outline, color: AppColors.getErrorColor(brightness)),
              title: Text(
                'Delete Course',
                style: GoogleFonts.inter(color: AppColors.getErrorColor(brightness)),
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
    final brightness = Theme.of(context).brightness;
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
            onPressed: () => _navigateToEditCourse(),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: textColor,
            ),
            onPressed: _showMoreOptions,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: primaryColor,
                unselectedLabelColor: textSecondaryColor,
                indicatorColor: primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Content'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Q&A'),
                ],
              ),
            ],
          ),
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
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(_courseData['status'] ?? 'DRAFT', brightness).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(_courseData['status'] ?? 'DRAFT'),
                  style: GoogleFonts.inter(
                    color: _statusColor(_courseData['status'] ?? 'DRAFT', brightness),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (_courseData['status'] == 'PUBLISHED')
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _unpublishCourse,
                  icon: const Icon(Icons.visibility_off, size: 18),
                  label: const Text('Unpublish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getWarningColor(brightness),
                    foregroundColor: Colors.white,
                  ),
                )
              else if (_courseData['status'] == 'DRAFT')
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForReview,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Submit for Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimaryColor(brightness),
                    foregroundColor: Colors.white,
                  ),
                )
              else if (_courseData['status'] == 'PENDING_APPROVAL')
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.hourglass_empty, size: 18),
                  label: const Text('Pending Approval'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getTextSecondaryColor(brightness),
                    foregroundColor: Colors.white,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Under Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimaryColor(brightness).withOpacity(0.5),
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 400;
              return isSmall
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Students',
                                '${_courseData['studentsCount'] ?? 0}',
                                Icons.people_rounded,
                                AppColors.getPrimaryColor(brightness),
                                cardColor,
                                textColor,
                                textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Rating',
                                '${_courseData['rating'] ?? 0.0} ⭐',
                                Icons.star_rounded,
                                AppColors.getWarningColor(brightness),
                                cardColor,
                                textColor,
                                textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Lessons',
                                '${_courseData['lessonCount'] ?? 0}',
                                Icons.play_circle_rounded,
                                AppColors.getPrimaryLightColor(brightness),
                                cardColor,
                                textColor,
                                textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Revenue',
                                'रु ${(_courseData['studentsCount'] ?? 0) * (_courseData['price'] ?? 0)}',
                                Icons.attach_money_rounded,
                                AppColors.getSuccessColor(brightness),
                                cardColor,
                                textColor,
                                textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Students',
                            '${_courseData['studentsCount'] ?? 0}',
                            Icons.people_rounded,
                            AppColors.getPrimaryColor(brightness),
                            cardColor,
                            textColor,
                            textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Rating',
                            '${_courseData['rating'] ?? 0.0} ⭐',
                            Icons.star_rounded,
                            AppColors.getWarningColor(brightness),
                            cardColor,
                            textColor,
                            textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Lessons',
                            '${_courseData['lessonCount'] ?? 0}',
                            Icons.play_circle_rounded,
                            AppColors.getPrimaryLightColor(brightness),
                            cardColor,
                            textColor,
                            textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Revenue',
                            'रु ${(_courseData['studentsCount'] ?? 0) * (_courseData['price'] ?? 0)}',
                            Icons.attach_money_rounded,
                            AppColors.getSuccessColor(brightness),
                            cardColor,
                            textColor,
                            textSecondaryColor,
                          ),
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),

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
                        Icon(Icons.check_circle, color: AppColors.getSuccessColor(brightness), size: 20),
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
          _buildInfoRow('Price', 'रु ${_courseData['price'] ?? 0}', textColor, textSecondaryColor),
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
    return AppStatCard(
      icon: icon,
      value: value,
      label: label,
      color: color,
      cardColor: cardColor,
      textColor: textColor,
      textSecondaryColor: textSecondaryColor,
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
  // CONTENT TAB
  // ============================================

  Widget _buildContentTab(
    Brightness brightness,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
    Color primaryColor,
  ) {
    final courseStatus = _courseData['status'] ?? 'DRAFT';
    final canEditContent = courseStatus != 'PENDING_APPROVAL';

    if (_sections.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_outlined,
                size: 64,
                color: textSecondaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                courseStatus == 'PENDING_APPROVAL' ? 'Waiting for Approval' : 'No Content Yet',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                courseStatus == 'PENDING_APPROVAL'
                    ? 'This course is pending admin approval. You will be able to add content once it is approved.'
                    : 'Add sections and lessons to build your course.',
                style: GoogleFonts.inter(
                  color: textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!canEditContent && courseStatus == 'PENDING_APPROVAL')
                Icon(Icons.lock_outline, size: 32, color: textSecondaryColor.withOpacity(0.5))
              else if (_isProcessingSection)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _showAddSectionDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Section'),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sections.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Course Content (${_sections.length} sections)',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (!_isProcessingSection && canEditContent)
                  TextButton.icon(
                    onPressed: _showAddSectionDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Section'),
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                  )
                else if (_isProcessingSection)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          );
        }

        final section = _sections[index - 1];
        final lessons = section['lessons'] as List? ?? [];

        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.zero,
          borderRadius: 12,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              section['title'] ?? 'Untitled Section',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor),
            ),
            subtitle: Text(
              '${lessons.length} lessons',
              style: GoogleFonts.inter(color: textSecondaryColor, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isProcessingLesson && _processingSectionId == section['id'])
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else if (canEditContent)
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: primaryColor, size: 20),
                    onPressed: () => _showAddLessonDialog(section['id']),
                    tooltip: 'Add Lesson',
                  )
                else
                  const SizedBox.shrink(),
                PopupMenuButton<String>(
                  color: cardColor,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditSectionDialog(section);
                    } else if (value == 'delete') {
                      _deleteSectionConfirm(section);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Section')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Section', style: TextStyle(color: AppColors.getErrorColor(brightness))),
                    ),
                  ],
                  child: Icon(Icons.more_vert, color: textSecondaryColor),
                ),
              ],
            ),
            children: [
              ...lessons.map<Widget>((lesson) {
                return _buildLessonTile(lesson, textColor, textSecondaryColor, cardColor, primaryColor, brightness, section['id']);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _isProcessingLesson && _processingSectionId == section['id']
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : canEditContent
                        ? TextButton.icon(
                            onPressed: () => _showAddLessonDialog(section['id']),
                            icon: Icon(Icons.add, size: 16, color: primaryColor),
                            label: Text('Add Lesson', style: GoogleFonts.inter(color: primaryColor, fontSize: 13)),
                          )
                        : const SizedBox.shrink(),
              ),
            ],
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
    Brightness brightness,
    String sectionId,
  ) {
    final hasVideo = lesson['videoUrl'] != null && lesson['videoUrl'].toString().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Icon(
            hasVideo ? Icons.play_circle_filled : Icons.description_outlined,
            color: hasVideo ? AppColors.getPrimaryColor(brightness) : textSecondaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'] ?? 'Untitled Lesson',
                  style: GoogleFonts.inter(color: textColor, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lesson['duration'] != null && lesson['duration'].toString().isNotEmpty)
                  Text(
                    lesson['duration'],
                    style: GoogleFonts.inter(color: textSecondaryColor, fontSize: 11),
                  ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!hasVideo)
                  IconButton(
                    icon: Icon(Icons.cloud_upload_outlined, color: primaryColor, size: 18),
                    onPressed: () => _showVideoUploadDialog(lesson),
                    tooltip: 'Upload Video',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                if (hasVideo)
                  IconButton(
                    icon: Icon(Icons.video_library, color: AppColors.getSuccessColor(brightness), size: 18),
                    onPressed: () => _showVideoUploadDialog(lesson),
                    tooltip: 'Change Video',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                PopupMenuButton<String>(
                  color: cardColor,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditLessonDialog(lesson);
                    } else if (value == 'delete') {
                      _deleteLessonConfirm(lesson);
                    } else if (value == 'upload_video') {
                      _showVideoUploadDialog(lesson);
                    } else if (value == 'delete_video') {
                      _deleteVideoConfirm(lesson);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Lesson')),
                    if (!hasVideo)
                      const PopupMenuItem(value: 'upload_video', child: Text('Upload Video'))
                    else ...[
                      const PopupMenuItem(value: 'upload_video', child: Text('Change Video')),
                      PopupMenuItem(
                        value: 'delete_video',
                        child: Text('Remove Video', style: TextStyle(color: AppColors.getWarningColor(brightness))),
                      ),
                    ],
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Lesson', style: TextStyle(color: AppColors.getErrorColor(brightness))),
                    ),
                  ],
                  child: Icon(Icons.more_vert, color: textSecondaryColor, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // REVIEWS TAB
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
              color: textSecondaryColor.withOpacity(0.5),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 400;
              return isSmall
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                      color: AppColors.getWarningColor(brightness),
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
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            _buildRatingBar(5, 45, textSecondaryColor, brightness),
                            _buildRatingBar(4, 30, textSecondaryColor, brightness),
                            _buildRatingBar(3, 15, textSecondaryColor, brightness),
                            _buildRatingBar(2, 7, textSecondaryColor, brightness),
                            _buildRatingBar(1, 3, textSecondaryColor, brightness),
                          ],
                        ),
                      ],
                    )
                  : Row(
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
                                  color: AppColors.getWarningColor(brightness),
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
                              _buildRatingBar(5, 45, textSecondaryColor, brightness),
                              _buildRatingBar(4, 30, textSecondaryColor, brightness),
                              _buildRatingBar(3, 15, textSecondaryColor, brightness),
                              _buildRatingBar(2, 7, textSecondaryColor, brightness),
                              _buildRatingBar(1, 3, textSecondaryColor, brightness),
                            ],
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              final rating = review['rating'] ?? 0;

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: AppColors.getWarningColor(brightness),
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
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
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

  Widget _buildRatingBar(int rating, int percentage, Color textSecondaryColor, Brightness brightness) {
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
                backgroundColor: AppColors.getBackgroundSelectedColor(brightness),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.getWarningColor(brightness)),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.question_answer_outlined,
            size: 64,
            color: textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Questions Yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Students will ask questions here when they need clarification.',
            style: GoogleFonts.inter(
              color: textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AppStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final Color textSecondaryColor;

  const AppStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.textSecondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textSecondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}