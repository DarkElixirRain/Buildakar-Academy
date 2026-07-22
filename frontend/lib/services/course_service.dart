// lib/services/course_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class CourseApiService extends BaseApiService {
  Future<ApiResponse<List<Map<String, dynamic>>>> getFeaturedCourses({int limit = 5}) async {
    final response = await _authAwareJsonGet('/courses/featured?limit=$limit');
    if (response != null) {
      final courses = (response['data'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      return ApiResponse.success(courses, message: response['message']);
    }
    return ApiResponse.error('Failed to fetch featured courses');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRecommendedCourses({int limit = 10}) async {
    final token = await getToken();
    final response = await _authAwareJsonGet('/courses/public',
        requireAuth: token != null && token.isNotEmpty);
    if (response != null) {
      final courses = (response['data'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      return ApiResponse.success(courses, message: response['message']);
    }
    return ApiResponse.error('Failed to fetch recommended courses');
  }

  Future<ApiResponse<Map<String, dynamic>>> getCourseById(String id) async {
    final token = await getToken();
    final response = await _authAwareJsonGet('/courses/$id',
        requireAuth: token != null && token.isNotEmpty);
    if (response != null) {
      return ApiResponse.success(response['data'] as Map<String, dynamic>, message: response['message']);
    }
    return ApiResponse.error('Failed to fetch course');
  }

  Future<ApiResponse<Map<String, dynamic>>> getPublicCourses({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
    String? sortBy = 'popular',
    String? level,
  }) async {
    final response = await _authAwareJsonGet('/courses/public');
    if (response != null) {
      return ApiResponse.success(
        {'data': response['data'] ?? []},
        message: response['message'],
      );
    }
    return ApiResponse.error('Failed to fetch courses');
  }

  Future<ApiResponse<Map<String, dynamic>>> getPopularCourses({
    int limit = 10,
    int page = 1,
    String timeRange = 'week',
  }) async {
    final response = await _authAwareJsonGet('/courses/public');
    if (response != null) {
      return ApiResponse.success(
        {'data': response['data'] ?? []},
        message: response['message'],
      );
    }
    return ApiResponse.error('Failed to fetch popular courses');
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

      final userResponse = await _authAwareJsonGet('/auth/me', requireAuth: true);
      if (userResponse == null || userResponse['data'] == null) {
        return ApiResponse.error('Failed to get user info');
      }

      final instructorId = (userResponse['data'] as Map<String, dynamic>)['id'];
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'instructorId': instructorId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'sortBy': sortBy ?? 'newest',
      };

      final queryString = queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final response = await _authAwareJsonGet('/courses?$queryString', requireAuth: true);
      if (response != null) {
        return ApiResponse.success(
          {'data': response['data'] ?? [], 'pagination': response['pagination'] ?? {}},
          message: response['message'],
        );
      }
      return ApiResponse.error('Failed to fetch instructor courses');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getInstructorStats() async {
    final response = await _authAwareJsonGet('/courses/stats', requireAuth: true);
    if (response != null) {
      return ApiResponse.success(response['data'] as Map<String, dynamic>, message: response['message']);
    }
    return ApiResponse.error('Failed to fetch instructor stats');
  }

  Future<ApiResponse<dynamic>> deleteCourse(String courseId) async {
    final response = await _authAwareRequest('DELETE', '/courses/$courseId', requireAuth: true);
    if (response != null) {
      return ApiResponse.success(null, message: response['message']);
    }
    return ApiResponse.error('Failed to delete course');
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCourseStatus(String courseId, String status) async {
    final response = await _authAwareJsonPatch(
      '/courses/$courseId/status',
      {'status': status},
      requireAuth: true,
    );
    if (response != null) {
      return ApiResponse.success(response['data'] as Map<String, dynamic>, message: response['message']);
    }
    return ApiResponse.error('Failed to update course status');
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCourse(String courseId, Map<String, dynamic> data) async {
    final response = await _authAwareJsonPatch('/courses/$courseId', data, requireAuth: true);
    if (response != null) {
      return ApiResponse.success(response['data'] as Map<String, dynamic>, message: response['message']);
    }
    return ApiResponse.error('Failed to update course');
  }

  Future<ApiResponse<Map<String, dynamic>>> duplicateCourse(String courseId) async {
    final response = await _authAwareJsonPost('/courses/$courseId/duplicate', requireAuth: true);
    if (response != null) {
      return ApiResponse.success(response['data'] as Map<String, dynamic>, message: response['message']);
    }
    return ApiResponse.error('Failed to duplicate course');
  }

  Future<ApiResponse<Map<String, dynamic>>> getCourseAnalytics({String? courseId}) async {
    final queryString = courseId != null && courseId.isNotEmpty
        ? '?courseId=${Uri.encodeComponent(courseId)}'
        : '';
    final response = await _authAwareJsonGet('/instructors/analytics$queryString', requireAuth: true);
    if (response != null) {
      return ApiResponse.success(response['data'] as Map<String, dynamic>, message: response['message']);
    }
    return ApiResponse.error('Failed to fetch course analytics');
  }

  // ── helpers with 401 auto-refresh ──

  Future<Map<String, dynamic>?> _authAwareJsonGet(String endpoint, {bool requireAuth = false}) async {
    final result = await _authAwareRequest('GET', endpoint, requireAuth: requireAuth);
    return result;
  }

  Future<Map<String, dynamic>?> _authAwareJsonPost(String endpoint, {dynamic data, bool requireAuth = false}) async {
    return await _authAwareRequest('POST', endpoint, data: data, requireAuth: requireAuth);
  }

  Future<Map<String, dynamic>?> _authAwareJsonPatch(String endpoint, dynamic data, {bool requireAuth = false}) async {
    return await _authAwareRequest('PATCH', endpoint, data: data, requireAuth: requireAuth);
  }

  Future<Map<String, dynamic>?> _authAwareRequest(
    String method,
    String endpoint, {
    dynamic data,
    bool requireAuth = false,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    print('🌐 $method Request to: $url');
    print('🔐 requireAuth: $requireAuth');

    http.Response response;
    try {
      response = await _sendRequest(method, url, headers, data);
    } catch (e) {
      print('❌ $method Error: $e');
      return null;
    }

    print('📥 $method Response Status: ${response.statusCode}');

    if (response.statusCode == 401 && requireAuth) {
      print('🔄 CourseService: Got 401, attempting token refresh...');
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        headers['Authorization'] = 'Bearer $newToken';
        try {
          response = await _sendRequest(method, url, headers, data);
        } catch (e) {
          print('❌ $method Error (retry): $e');
          return null;
        }
        print('📥 $method Retry Response Status: ${response.statusCode}');
      } else {
        return null;
      }
    }

    return _decodeJson(response);
  }

  Future<http.Response> _sendRequest(String method, Uri url, Map<String, String> headers, dynamic data) async {
    switch (method) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(url, headers: headers, body: data != null ? jsonEncode(data) : null);
      case 'PUT':
        return await http.put(url, headers: headers, body: data != null ? jsonEncode(data) : null);
      case 'DELETE':
        return await http.delete(url, headers: headers);
      case 'PATCH':
        return await http.patch(url, headers: headers, body: data != null ? jsonEncode(data) : null);
      default:
        throw Exception('Unsupported method: $method');
    }
  }

  Map<String, dynamic>? _decodeJson(http.Response response) {
    try {
      if (response.body.isEmpty) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300 && json['success'] == true) {
        return json;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
