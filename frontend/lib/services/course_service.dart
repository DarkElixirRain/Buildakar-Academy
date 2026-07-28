import 'dart:convert';

import '../services/base_api_service.dart';
import '../types/api_response.dart';

class CourseApiService extends BaseApiService {
  // ── Public (no auth) endpoints ──

  Future<ApiResponse<List<Map<String, dynamic>>>> getFeaturedCourses({int limit = 5}) async {
    try {
      final response = await get('/courses/featured?limit=$limit', requireAuth: false);
      if (response.success && response.data != null) {
        final List<dynamic> courses = response.data is List ? response.data : (response.data['data'] ?? []);
        return ApiResponse.success(
          courses.map((e) => e as Map<String, dynamic>).toList(),
          message: response.message,
        );
      }
      return ApiResponse.error(response.error ?? 'Failed to fetch featured courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRecommendedCourses({int limit = 10}) async {
    try {
      final token = await getToken();
      final response = await get('/courses/public', requireAuth: token != null);
      if (response.success && response.data != null) {
        final List<dynamic> courses = response.data is List ? response.data : (response.data['data'] ?? []);
        return ApiResponse.success(
          courses.map((e) => e as Map<String, dynamic>).toList(),
          message: response.message,
        );
      }
      return ApiResponse.error(response.error ?? 'Failed to fetch recommended courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCourseById(String id) async {
    try {
      final response = await get('/courses/$id', requireAuth: false);
      if (response.success && response.data != null) {
        return ApiResponse.success(response.data as Map<String, dynamic>, message: response.message);
      }
      return ApiResponse.error(response.error ?? 'Failed to fetch course');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getPublicCourses({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? instructorId,
    String? search,
    String? sortBy = 'popular',
    String? level,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (categoryId != null) 'categoryId': categoryId,
        if (instructorId != null) 'instructorId': instructorId,
        if (search != null) 'search': search,
        if (sortBy != null) 'sortBy': sortBy,
        if (level != null) 'level': level,
      };
      final queryString = queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final response = await get('/courses/public?$queryString', requireAuth: false);
      if (response.success) {
        final courses = response.data is List ? response.data as List<dynamic> : [];
        return ApiResponse.success(
          {'data': courses, 'pagination': {}},
          message: response.message,
        );
      }
      return ApiResponse.error(response.error ?? 'Failed to fetch courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getPopularCourses({
    int limit = 10,
    int page = 1,
    String timeRange = 'week',
  }) async {
    try {
      final response = await get('/courses/public', requireAuth: false);
      if (response.success) {
        final data = response.data as Map<String, dynamic>? ?? {};
        return ApiResponse.success(
          {'data': data['data'] ?? [], 'pagination': data['pagination'] ?? {}},
          message: response.message,
        );
      }
      return ApiResponse.error(response.error ?? 'Failed to fetch popular courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ── Authenticated endpoints (use sendAuthenticatedRequest for 401 retry) ──

  Future<ApiResponse<Map<String, dynamic>>> getInstructorCourses({
    int page = 1,
    int limit = 50,
    String? status,
    String? search,
    String? sortBy = 'newest',
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'sortBy': sortBy ?? 'newest',
      };

      final queryString = queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final response = await sendAuthenticatedRequest(method: 'GET', endpoint: '/courses?$queryString');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          {'data': data['data'] ?? [], 'pagination': data['pagination'] ?? {}},
          message: data['message'],
        );
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getInstructorStats() async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await sendAuthenticatedRequest(method: 'GET', endpoint: '/instructors/stats');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor stats');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> deleteCourse(String courseId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await sendAuthenticatedRequest(method: 'DELETE', endpoint: '/courses/$courseId');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to delete course');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCourseStatus(String courseId, String status) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/courses/$courseId/status',
        body: {'status': status},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to update course status');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCourse(String courseId, Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await sendAuthenticatedRequest(
        method: 'PUT',
        endpoint: '/courses/$courseId',
        body: data,
      );
      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return ApiResponse.success(result['data'] as Map<String, dynamic>, message: result['message']);
      }
      return ApiResponse.error(result['message'] ?? 'Failed to update course');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> duplicateCourse(String courseId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await sendAuthenticatedRequest(method: 'POST', endpoint: '/courses/$courseId/duplicate');
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to duplicate course');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCourseAnalytics({String? courseId}) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final queryParams = <String, String>{};
      if (courseId != null && courseId.isNotEmpty) {
        queryParams['courseId'] = courseId;
      }
      final queryString = queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final suffix = queryString.isNotEmpty ? '?$queryString' : '';
      final response = await sendAuthenticatedRequest(method: 'GET', endpoint: '/instructors/analytics$suffix');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch course analytics');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}