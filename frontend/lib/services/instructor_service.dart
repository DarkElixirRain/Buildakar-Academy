// lib/services/instructor_service.dart

import 'dart:convert';

import '../models/course_model.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class InstructorApiService extends BaseApiService {
  // ==================== INSTRUCTOR ENDPOINTS ====================

  // GET /instructors/top - Get top instructors
  Future<ApiResponse<List<Map<String, dynamic>>>> getTopInstructors({int limit = 10}) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/instructors/top?limit=$limit',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> instructors = data['data'] ?? [];
        return ApiResponse.success(
          instructors.map((e) => e as Map<String, dynamic>).toList(),
          message: data['message'],
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch top instructors');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // GET /instructors - Get all instructors with filters
  Future<ApiResponse<Map<String, dynamic>>> getInstructors({
    String? search,
    String? expertise,
    int limit = 10,
    int offset = 0,
    String sortBy = 'popular',
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        'sortBy': sortBy,
        if (search != null && search.isNotEmpty) 'search': search,
        if (expertise != null && expertise.isNotEmpty) 'expertise': expertise,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      };

      final endpoint = Uri(path: '/instructors', queryParameters: queryParams).toString();
      final response = await sendAuthenticatedRequest(method: 'GET', endpoint: endpoint);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          data['data'] as Map<String, dynamic>,
          message: data['message'],
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructors');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // GET /instructors/:id - Get instructor by ID
  Future<ApiResponse<Map<String, dynamic>>> getInstructorById(String id) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/instructors/$id',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // POST /instructors/:id/follow - Toggle follow instructor
  Future<ApiResponse<Map<String, dynamic>>> toggleFollowInstructor(String instructorId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await sendAuthenticatedRequest(
        method: 'POST',
        endpoint: '/instructors/$instructorId/follow',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to toggle follow');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // GET /instructors/:id/followers - Get instructor's followers
  Future<ApiResponse<Map<String, dynamic>>> getFollowers(
    String instructorId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/instructors/$instructorId/followers?limit=$limit&offset=$offset',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch followers');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // GET /instructors/search - Search instructors
  Future<ApiResponse<List<Map<String, dynamic>>>> searchInstructors(String query, {int limit = 10}) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/instructors/search?q=${Uri.encodeComponent(query)}&limit=$limit',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> instructors = data['data'] ?? [];
        return ApiResponse.success(
          instructors.map((e) => e as Map<String, dynamic>).toList(),
          message: data['message'],
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to search instructors');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ==================== INSTRUCTOR PROTECTED ENDPOINTS ====================

  // GET /instructors/courses - Get instructor's own courses
  Future<ApiResponse<List<Course>>> getInstructorCourses() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/instructors/courses',
      );

      print('📡 getInstructorCourses response status: ${response.statusCode}');
      print('📡 getInstructorCourses response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        List<Course> courses = [];

        if (data['data'] is List) {
          courses = (data['data'] as List)
              .map((item) => Course.fromJson(item))
              .toList();
        } else if (data['data'] is Map && data['data']['data'] != null) {
          courses = (data['data']['data'] as List)
              .map((item) => Course.fromJson(item))
              .toList();
        }

        print('✅ Loaded ${courses.length} courses');
        return ApiResponse.success(courses, message: data['message']);
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor courses');
    } catch (e) {
      print('❌ Error fetching instructor courses: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // GET /instructors/stats - Get instructor stats
  Future<ApiResponse<Map<String, dynamic>>> getInstructorStats() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/instructors/stats',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor stats');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // GET /instructors/analytics - Get instructor analytics
  Future<ApiResponse<Map<String, dynamic>>> getInstructorAnalytics({String? courseId}) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final queryParams = <String, String>{};
      if (courseId != null && courseId.isNotEmpty) {
        queryParams['courseId'] = courseId;
      }

      final endpoint = Uri(path: '/instructors/analytics', queryParameters: queryParams).toString();

      final response = await sendAuthenticatedRequest(method: 'GET', endpoint: endpoint);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor analytics');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // PATCH /instructors/profile - Update instructor profile
  Future<ApiResponse<Map<String, dynamic>>> updateInstructorProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/instructors/profile',
        body: jsonEncode(profileData),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to update instructor profile');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // GET /instructors/students - Get instructor's students
  Future<ApiResponse<Map<String, dynamic>>> getInstructorStudents({
    int page = 1,
    int limit = 20,
    String? search,
    String? sortBy = 'newest',
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        'sortBy': sortBy ?? 'newest',
      };

      final endpoint = Uri(path: '/instructors/students', queryParameters: queryParams).toString();

      final response = await sendAuthenticatedRequest(method: 'GET', endpoint: endpoint);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor students');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // GET /instructors/earnings - Get instructor earnings
  Future<ApiResponse<Map<String, dynamic>>> getInstructorEarnings({
    String? timeRange = 'month',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final queryParams = <String, String>{
        'timeRange': timeRange ?? 'month',
        if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
        if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
      };

      final endpoint = Uri(path: '/instructors/earnings', queryParameters: queryParams).toString();

      final response = await sendAuthenticatedRequest(method: 'GET', endpoint: endpoint);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor earnings');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
