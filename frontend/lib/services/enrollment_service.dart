import 'dart:convert';

import '../services/base_api_service.dart';
import '../types/api_response.dart';

class EnrollmentApiService extends BaseApiService {
  Future<ApiResponse<List<Map<String, dynamic>>>> getContinueLearning({int limit = 5}) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/enroll/continue-learning?limit=$limit',
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> enrollments = data['data'] ?? [];
        final courses = enrollments.map((e) {
          return {
            'id': e['id']?.toString() ?? '',
            'courseId': e['courseId']?.toString() ?? '',
            'title': e['title'] ?? 'Untitled Course',
            'description': e['description'] ?? '',
            'thumbnail': e['thumbnail']?.toString()?.isNotEmpty == true
                ? e['thumbnail'].toString()
                : 'https://via.placeholder.com/400x225/4F46E5/FFFFFF?text=Course',
            'instructor': e['instructor'] ?? 'Unknown Instructor',
            'instructorId': e['instructorId']?.toString() ?? '',
            'instructorAvatar': e['instructorAvatar']?.toString() ?? '',
            'progress': _toDouble(e['progress']),
            'remainingTime': _calculateRemainingTime(_toDouble(e['progress']), e['isCompleted'] ?? false),
            'isCompleted': e['isCompleted'] ?? false,
            'level': e['level'] ?? 'Beginner',
            'category': e['category'] ?? 'General',
            'price': _toDouble(e['price']),
            'originalPrice': _toDouble(e['originalPrice']),
            'rating': _toDouble(e['rating']),
            'reviewsCount': _toInt(e['reviewsCount']),
            'studentsCount': _toInt(e['studentsCount']),
            'language': e['language'] ?? 'English',
            'lastAccessedAt': e['lastAccessedAt'],
            'sections': e['sections'] ?? [],
            'learningObjectives': e['learningObjectives'] ?? [],
            'requirements': e['requirements'] ?? [],
            'studyMaterials': e['studyMaterials'] ?? [],
            'whatYouWillLearn': e['whatYouWillLearn'] ?? [],
          };
        }).toList();
        return ApiResponse.success(courses, message: data['message']);
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch continue learning');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getMyEnrollments({
    int page = 1,
    int limit = 10,
    bool? isCompleted,
  }) async {
    try {
      String endpoint = '/enroll/my-enrollments?page=$page&limit=$limit';
      if (isCompleted != null) {
        endpoint += '&isCompleted=$isCompleted';
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: endpoint,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          {'data': data['data'] ?? [], 'pagination': data['pagination'] ?? {}},
          message: data['message'],
        );
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch enrollments');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCourseProgress(String courseId) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/enroll/courses/$courseId/progress',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] ?? {}, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch course progress');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> updateLessonProgress(String lessonId, bool isCompleted) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/enroll/lessons/$lessonId/progress',
        body: {'isCompleted': isCompleted},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to update progress');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> enrollInCourse(String courseId) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'POST',
        endpoint: '/enroll/$courseId',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse.success(data['data'] ?? {}, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to enroll');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> unenrollFromCourse(String courseId) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'DELETE',
        endpoint: '/enroll/$courseId',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to unenroll');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> checkEnrollmentStatus(String courseId) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/enroll/$courseId/status',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] ?? {}, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to check enrollment status');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    if (value is num) return value.toDouble();
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    if (value is num) return value.toInt();
    return 0;
  }

  static String _calculateRemainingTime(double progress, bool isCompleted) {
    if (isCompleted) {
      return 'Completed';
    }
    if (progress <= 0) {
      return 'Start learning';
    }
    return '${(100 - progress).toInt()}% remaining';
  }
}
