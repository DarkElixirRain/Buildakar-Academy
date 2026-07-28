import 'dart:io';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';
class InstructorCourseProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  double _uploadProgress = 0.0;
  String _uploadPhase = '';
  bool _isUploading = false;

  List<Course> _courses = [];
  int _totalCourses = 0;
  int _currentPage = 1;
  bool _hasMore = true;

  Map<String, dynamic>? _currentCourseData;
  List<Map<String, dynamic>> _sections = [];
  List<dynamic> _reviews = [];
  Map<String, dynamic>? _analytics;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;
  String get uploadPhase => _uploadPhase;
  bool get isUploading => _isUploading;
  List<Course> get courses => _courses;
  int get totalCourses => _totalCourses;
  bool get hasMore => _hasMore;
  Map<String, dynamic>? get currentCourseData => _currentCourseData;
  List<Map<String, dynamic>> get sections => _sections;
  List<dynamic> get reviews => _reviews;
  Map<String, dynamic>? get courseAnalytics => _analytics;

  Future<void> loadCourses({bool reset = true, String? status, String? search, String? sortBy}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _courses = [];
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final r = await _api.getMyInstructorCourses(
        page: _currentPage,
        limit: 50,
        status: status,
        search: search,
        sortBy: sortBy,
      );
      if (r.success && r.data != null) {
        final data = r.data as Map<String, dynamic>;
        final List<dynamic> raw = data['data'] as List<dynamic>? ?? [];
        final parsed = raw.map((j) => Course.fromJson(j as Map<String, dynamic>)).toList();
        if (reset) {
          _courses = parsed;
        } else {
          _courses.addAll(parsed);
        }
        _totalCourses = (data['pagination']?['total'] as num?)?.toInt() ?? parsed.length;
        _hasMore = parsed.length >= 50;
      } else {
        _error = r.error;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCourse(Map<String, dynamic> data, {File? thumbnail}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      String? thumbnailUrl;
      if (thumbnail != null) {
        final upload = await _api.uploadThumbnail(thumbnail);
        if (upload.success && upload.data != null) {
          thumbnailUrl = upload.data!['url'] as String?;
        } else {
          _error = upload.error ?? 'Failed to upload thumbnail';
          _isSubmitting = false;
          notifyListeners();
          return false;
        }
      }
      if (thumbnailUrl != null) data['thumbnail'] = thumbnailUrl;

      final r = await _api.post('/courses', data: data, requireAuth: true);
      if (r.success) {
        await loadCourses();
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _error = r.error;
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(String courseId, Map<String, dynamic> data, {File? thumbnail}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      if (thumbnail != null) {
        final upload = await _api.uploadThumbnail(thumbnail);
        if (upload.success && upload.data != null) {
          data['thumbnail'] = upload.data!['url'];
        }
      }
      final r = await _api.updateCourse(courseId, data);
      if (r.success) {
        await loadCourseDetail(courseId);
        await loadCourses();
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _error = r.error;
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final r = await _api.deleteCourse(courseId);
      if (r.success) {
        _courses.removeWhere((c) => c.id == courseId);
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _error = r.error;
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourseStatus(String courseId, String status) async {
    try {
      final r = await _api.updateCourseStatus(courseId, status);
      if (r.success) {
        final idx = _courses.indexWhere((c) => c.id == courseId);
        if (idx != -1) {
          final old = _courses[idx];
          _courses[idx] = Course(
            id: old.id, title: old.title, description: old.description,
            thumbnail: old.thumbnail, price: old.price, originalPrice: old.originalPrice,
            level: old.level, language: old.language, duration: old.duration,
            totalHours: old.totalHours, rating: old.rating, studentsCount: old.studentsCount,
            isPublished: status == 'PUBLISHED', isBestseller: old.isBestseller,
            isTrending: old.isTrending, status: status, createdAt: old.createdAt,
            updatedAt: DateTime.now(), instructorId: old.instructorId,
            categoryId: old.categoryId, instructor: old.instructor,
            category: old.category, sections: old.sections,
            enrollmentsCount: old.enrollmentsCount, reviewsCount: old.reviewsCount,
            lessonsCount: old.lessonsCount, learningObjectives: old.learningObjectives,
            requirements: old.requirements, whatYouWillLearn: old.whatYouWillLearn,
            reviews: old.reviews, studyMaterials: old.studyMaterials,
          );
          notifyListeners();
        }
        return true;
      } else {
        _error = r.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> duplicateCourse(String courseId) async {
    try {
      final r = await _api.duplicateCourse(courseId);
      if (r.success) {
        await loadCourses();
        return true;
      } else {
        _error = r.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCourseDetail(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cr = await _api.getCourseByIdAuthenticated(courseId);
      if (cr.success && cr.data != null) {
        _currentCourseData = cr.data;
      }

      final sr = await _api.getCourseSections(courseId);
      if (sr.success && sr.data != null) {
        _sections = sr.data!.map((s) {
          final lessons = (s['lessons'] as List? ?? []).map((l) => {
            'id': l['id']?.toString() ?? '',
            'title': l['title'] ?? 'Untitled',
            'duration': l['duration'] ?? '0:00',
            'videoUrl': l['videoUrl'],
            'description': l['description'] ?? '',
            'isPreview': l['isPreview'] ?? false,
          }).toList();
          return {
            'id': s['id']?.toString() ?? '',
            'title': s['title'] ?? 'Untitled Section',
            'order': (s['order'] as num?)?.toInt() ?? 0,
            'lessons': lessons,
          };
        }).toList();
      }

      final rr = await _api.getCourseReviews(courseId: courseId, limit: 50);
      if (rr.success && rr.data != null) {
        _reviews = (rr.data!['data'] as List? ?? []);
      }

      final ar = await _api.getCourseAnalytics(courseId: courseId);
      if (ar.success) _analytics = ar.data;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSection(String courseId, Map<String, dynamic> data) async {
    try {
      final r = await _api.createSection(courseId, data);
      if (r.success) {
        await loadCourseDetail(courseId);
        return true;
      } else {
        _error = r.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSection(String sectionId, Map<String, dynamic> data) async {
    try {
      final r = await _api.updateSection(sectionId, data);
      if (r.success) {
        final idx = _sections.indexWhere((s) => s['id'] == sectionId);
        if (idx != -1) {
          _sections[idx]['title'] = data['title'] ?? _sections[idx]['title'];
          _sections[idx]['description'] = data['description'] ?? _sections[idx]['description'];
          notifyListeners();
        }
        return true;
      } else {
        _error = r.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSection(String sectionId) async {
    try {
      final r = await _api.deleteSection(sectionId);
      if (r.success) {
        _sections.removeWhere((s) => s['id'] == sectionId);
        notifyListeners();
        return true;
      } else {
        _error = r.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createLesson(String sectionId, Map<String, dynamic> data) async {
    try {
      final r = await _api.createLesson(sectionId, data);
      if (r.success) {
        final courseId = _currentCourseData?['id']?.toString();
        if (courseId != null) await loadCourseDetail(courseId);
        return true;
      } else {
        _error = r.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLesson(String lessonId, Map<String, dynamic> data) async {
    try {
      final r = await _api.updateLesson(lessonId, data);
      if (r.success) {
        final courseId = _currentCourseData?['id']?.toString();
        if (courseId != null) await loadCourseDetail(courseId);
        return true;
      } else {
        _error = r.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLesson(String lessonId) async {
    try {
      final r = await _api.deleteLesson(lessonId);
      if (r.success) {
        for (var s in _sections) {
          (s['lessons'] as List).removeWhere((l) => l['id'] == lessonId);
        }
        notifyListeners();
        return true;
      } else {
        _error = r.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadLessonVideo(String lessonId, File videoFile) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _uploadPhase = 'Preparing...';
    _error = null;
    notifyListeners();

    try {
      final fileSizeMb = videoFile.lengthSync() / (1024 * 1024);
      final r = await _api.uploadLessonVideo(
        lessonId,
        videoFile,
        onProgress: (sent, total) {
          final percent = sent / total;
          _uploadProgress = percent;
          _uploadPhase = 'Uploading ${(percent * 100).toStringAsFixed(0)}%';
          notifyListeners();
        },
      );
      if (r.success) {
        _uploadPhase = 'Processing video...';
        notifyListeners();
        final courseId = _currentCourseData?['id']?.toString();
        if (courseId != null) await loadCourseDetail(courseId);
        _uploadPhase = 'Complete!';
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        _error = r.error;
        _uploadPhase = 'Failed';
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _uploadPhase = 'Failed';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLessonVideo(String lessonId) async {
    try {
      final r = await _api.deleteLessonVideo(lessonId);
      if (r.success) {
        final courseId = _currentCourseData?['id']?.toString();
        if (courseId != null) await loadCourseDetail(courseId);
        return true;
      } else {
        _error = r.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
