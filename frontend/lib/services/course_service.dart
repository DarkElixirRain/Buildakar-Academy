import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class CourseApiService extends BaseApiService {
  Future<ApiResponse<List<Map<String, dynamic>>>> getFeaturedCourses({int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/featured?limit=$limit'),
        headers: await getHeaders(requireAuth: false),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> courses = data['data'] ?? [];
        return ApiResponse.success(
          courses.map((e) => e as Map<String, dynamic>).toList(),
          message: data['message'],
        );
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch featured courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRecommendedCourses({int limit = 10}) async {
    try {
      final token = await getToken();
      final headers = await getHeaders(requireAuth: token != null);
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/public'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> courses = data['data'] ?? [];
        return ApiResponse.success(
          courses.map((e) => e as Map<String, dynamic>).toList(),
          message: data['message'],
        );
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch recommended courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCourseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$id'),
        headers: await getHeaders(requireAuth: false),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch course');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getPublicCourses({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
    String? sortBy = 'popular',
    String? level,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/public'),
        headers: await getHeaders(requireAuth: false),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          {'data': data['data'] ?? [], 'pagination': data['pagination'] ?? {}},
          message: data['message'],
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch courses');
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
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/public'),
        headers: await getHeaders(requireAuth: false),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          {'data': data['data'] ?? [], 'pagination': data['pagination'] ?? {}},
          message: data['message'],
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch popular courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

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

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/courses').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await getHeaders(requireAuth: true));
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

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/instructors/stats'),
        headers: await getHeaders(requireAuth: true),
      );
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

      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId'),
        headers: await getHeaders(requireAuth: true),
      );
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

      final response = await http.patch(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId/status'),
        headers: await getHeaders(requireAuth: true),
        body: jsonEncode({'status': status}),
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

      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId'),
        headers: await getHeaders(requireAuth: true),
        body: jsonEncode(data),
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

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId/duplicate'),
        headers: await getHeaders(requireAuth: true),
      );
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

      final queryParams = <String, String>{if (courseId != null && courseId.isNotEmpty) 'courseId': courseId};
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/instructors/analytics').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await getHeaders(requireAuth: true));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch course analytics');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getInstructorPublicCourses({
    required String instructorId,
    int page = 1,
    int limit = 20,
    String? search,
    String? sortBy = 'newest',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'instructorId': instructorId,
        if (search != null && search.isNotEmpty) 'search': search,
        'sortBy': sortBy ?? 'newest',
      };

      final queryString = queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final response = await get('/courses?$queryString', requireAuth: true);
      if (response.success) {
        return ApiResponse.success(
          {'data': response.data['data'] ?? [], 'pagination': response.data['pagination'] ?? {}},
          message: response.message,
        );
      }
      return ApiResponse.error('Failed to fetch instructor courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}