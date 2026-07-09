// lib/services/live_class_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/live_class_model.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class LiveClassApiService extends BaseApiService {
  // Get instructor's live classes (matches GET /live-classes/instructor)
  Future<ApiResponse<List<LiveClass>>> getInstructorLiveClasses() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final headers = await getHeaders(requireAuth: true);
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/live-classes/instructor'),
        headers: headers,
      );
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<LiveClass> classes = (data['data'] as List? ?? [])
            .map((item) => LiveClass.fromJson(item))
            .toList();
        return ApiResponse.success(classes, message: data['message']);
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor live classes');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Get course live classes (matches GET /live-classes/course/:courseId)
  Future<ApiResponse<List<LiveClass>>> getCourseLiveClasses(String courseId) async {
    try {
      final headers = await getHeaders(requireAuth: false);
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/live-classes/course/$courseId'),
        headers: headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<LiveClass> classes = (data['data'] as List? ?? [])
            .map((item) => LiveClass.fromJson(item))
            .toList();
        return ApiResponse.success(classes, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch course live classes');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Get live class by ID (matches GET /live-classes/:id)
  Future<ApiResponse<LiveClass>> getLiveClassById(String id) async {
    try {
      final headers = await getHeaders(requireAuth: false);
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/live-classes/$id'),
        headers: headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch live class');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Create live class (matches POST /live-classes)
  Future<ApiResponse<LiveClass>> createLiveClass(Map<String, dynamic> liveClassData) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final headers = await getHeaders(requireAuth: true);
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/live-classes'),
        headers: headers,
        body: jsonEncode(liveClassData),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to create live class');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Update live class (matches PUT /live-classes/:id)
  Future<ApiResponse<LiveClass>> updateLiveClass(String id, Map<String, dynamic> liveClassData) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final headers = await getHeaders(requireAuth: true);
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/live-classes/$id'),
        headers: headers,
        body: jsonEncode(liveClassData),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to update live class');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Cancel/Delete live class (matches DELETE /live-classes/:id)
  Future<ApiResponse<LiveClass>> cancelLiveClass(String id) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final headers = await getHeaders(requireAuth: true);
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/live-classes/$id'),
        headers: headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to cancel live class');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Start live class (matches POST /live-classes/:id/start)
  Future<ApiResponse<LiveClass>> startLiveClass(String id) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final headers = await getHeaders(requireAuth: true);
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/live-classes/$id/start'),
        headers: headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to start live class');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // End live class (matches POST /live-classes/:id/end)
  Future<ApiResponse<LiveClass>> endLiveClass(String id) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final headers = await getHeaders(requireAuth: true);
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/live-classes/$id/end'),
        headers: headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to end live class');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Join live class (matches POST /live-classes/:id/join)
  Future<ApiResponse<Map<String, dynamic>>> joinLiveClass(String id) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final headers = await getHeaders(requireAuth: true);
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/live-classes/$id/join'),
        headers: headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          data['data'] ?? {},
          message: data['message']
        );
      } else if (response.statusCode == 401) {
        await clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to join live class');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Convenience method to get classes by status (using existing endpoints)
  Future<ApiResponse<List<LiveClass>>> getLiveClassesByStatus(String status) async {
    final result = await getInstructorLiveClasses();
    if (result.success && result.data != null) {
      final filtered = result.data!.where((c) => c.status.toLowerCase() == status.toLowerCase()).toList();
      return ApiResponse.success(filtered, message: result.message);
    }
    return ApiResponse.error(result.error ?? 'Failed to fetch classes');
  }

  // Get upcoming classes (filter from instructor classes)
  Future<ApiResponse<List<LiveClass>>> getUpcomingLiveClasses({int limit = 20}) async {
    final result = await getLiveClassesByStatus('scheduled');
    if (result.success && result.data != null) {
      final limited = result.data!.take(limit).toList();
      return ApiResponse.success(limited, message: result.message);
    }
    return ApiResponse.error(result.error ?? 'Failed to fetch upcoming classes');
  }

  // Follow/unfollow functionality (not implemented in backend)
  Future<ApiResponse<Map<String, dynamic>>> followLiveClass(String classId) async {
    return ApiResponse.error('Follow functionality not implemented in backend');
  }

  Future<ApiResponse<Map<String, dynamic>>> unfollowLiveClass(String classId) async {
    return ApiResponse.error('Unfollow functionality not implemented in backend');
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleFollowLiveClass(String classId) async {
    return ApiResponse.error('Toggle follow functionality not implemented in backend');
  }

  Future<ApiResponse<Map<String, dynamic>>> isFollowingLiveClass(String classId) async {
    return ApiResponse.success({'isFollowing': false}, message: 'Not implemented');
  }

  Future<ApiResponse<Map<String, dynamic>>> getLiveClassStats() async {
    return ApiResponse.error('Stats functionality not implemented in backend');
  }
}