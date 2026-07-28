// lib/services/live_class_service.dart
import 'dart:convert';
import '../models/live_class_model.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class LiveClassApiService extends BaseApiService {
  // ==================== INSTRUCTOR ENDPOINTS ====================

  /// GET /live-classes/instructor - Get instructor's live classes
  Future<ApiResponse<List<LiveClass>>> getInstructorLiveClasses() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/live-classes/instructor',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<LiveClass> classes = (data['data'] as List? ?? [])
            .map((item) => LiveClass.fromJson(item))
            .toList();
        return ApiResponse.success(classes, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor live classes');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// POST /live-classes - Create a live class
  Future<ApiResponse<LiveClass>> createLiveClass(Map<String, dynamic> liveClassData) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'POST',
        endpoint: '/live-classes',
        body: liveClassData,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to create live class');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// PATCH /live-classes/:id - Update live class
  Future<ApiResponse<LiveClass>> updateLiveClass(String id, Map<String, dynamic> liveClassData) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/live-classes/$id',
        body: liveClassData,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to update live class');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// PATCH /live-classes/:id/start - Start live class
  Future<ApiResponse<LiveClass>> startLiveClass(String id) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/live-classes/$id/start',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to start live class');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// PATCH /live-classes/:id/end - End live class
  Future<ApiResponse<LiveClass>> endLiveClass(String id) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/live-classes/$id/end',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to end live class');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// PATCH /live-classes/:id/cancel - Cancel live class
  Future<ApiResponse<LiveClass>> cancelLiveClass(String id) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/live-classes/$id/cancel',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to cancel live class');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // ==================== STUDENT ENDPOINTS ====================

  /// GET /live-classes/student/all - Get ALL live classes (categorized)
  Future<ApiResponse<Map<String, dynamic>>> getAllStudentLiveClasses() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/live-classes/student/all',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final Map<String, dynamic> result = data['data'] ?? {};

        // Parse the categorized lists
        _parseClassList(result, 'live');
        _parseClassList(result, 'upcoming');
        _parseClassList(result, 'ended');
        _parseClassList(result, 'cancelled');
        _parseClassList(result, 'all');

        return ApiResponse.success(result, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch student live classes');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Helper method to parse class lists
  void _parseClassList(Map<String, dynamic> result, String key) {
    if (result[key] != null && result[key] is List) {
      result[key] = (result[key] as List)
          .map((item) => LiveClass.fromJson(item))
          .toList();
    }
  }

  /// GET /live-classes/student - Get student's live classes (excluding cancelled)
  Future<ApiResponse<List<LiveClass>>> getStudentLiveClasses() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/live-classes/student',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<LiveClass> classes = (data['data'] as List? ?? [])
            .map((item) => LiveClass.fromJson(item))
            .toList();
        return ApiResponse.success(classes, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch student live classes');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// GET /live-classes/student/upcoming - Get upcoming live classes
  Future<ApiResponse<List<LiveClass>>> getUpcomingStudentLiveClasses() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/live-classes/student/upcoming',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<LiveClass> classes = (data['data'] as List? ?? [])
            .map((item) => LiveClass.fromJson(item))
            .toList();
        return ApiResponse.success(classes, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch upcoming live classes');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// GET /live-classes/student/current - Get currently live classes
  Future<ApiResponse<List<LiveClass>>> getCurrentStudentLiveClasses() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/live-classes/student/current',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<LiveClass> classes = (data['data'] as List? ?? [])
            .map((item) => LiveClass.fromJson(item))
            .toList();
        return ApiResponse.success(classes, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch current live classes');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// GET /live-classes/student/stats - Get student live class statistics
  Future<ApiResponse<Map<String, dynamic>>> getStudentLiveClassStats() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/live-classes/student/stats',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final Map<String, dynamic> stats = data['data'] ?? {};

        // Parse the classes list if present
        if (stats['classes'] != null && stats['classes'] is List) {
          stats['classes'] = (stats['classes'] as List)
              .map((item) => LiveClass.fromJson(item))
              .toList();
        }

        return ApiResponse.success(stats, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch live class statistics');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// POST /live-classes/:id/join - Join live class
  Future<ApiResponse<Map<String, dynamic>>> joinLiveClass(String id) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse.error('User not authenticated. Please login again.');
      }

      final response = await sendAuthenticatedRequest(
        method: 'POST',
        endpoint: '/live-classes/$id/join',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          data['data'] ?? {},
          message: data['message']
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to join live class');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // ==================== SHARED ENDPOINTS ====================

  /// GET /live-classes/course/:courseId - Get course live classes
  Future<ApiResponse<List<LiveClass>>> getCourseLiveClasses(String courseId) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/live-classes/course/$courseId',
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
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// GET /live-classes/:id - Get live class by ID
  Future<ApiResponse<LiveClass>> getLiveClassById(String id) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/live-classes/$id',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          LiveClass.fromJson(data['data'] ?? {}),
          message: data['message']
        );
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Live class not found');
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch live class');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get live classes by status (convenience method)
  Future<ApiResponse<List<LiveClass>>> getLiveClassesByStatus(String status) async {
    final result = await getStudentLiveClasses();
    if (result.success && result.data != null) {
      final filtered = result.data!
          .where((c) => c.status.toLowerCase() == status.toLowerCase())
          .toList();
      return ApiResponse.success(filtered, message: 'Filtered by status: $status');
    }
    return ApiResponse.error(result.error ?? 'Failed to fetch classes');
  }

  /// Check if a class is joinable (convenience method)
  Future<bool> isClassJoinable(String classId) async {
    final result = await getLiveClassById(classId);
    if (result.success && result.data != null) {
      return result.data!.status.toLowerCase() == 'live';
    }
    return false;
  }

  /// Get room info for a live class (convenience method)
  Future<ApiResponse<Map<String, dynamic>>> getLiveClassRoomInfo(String classId) async {
    return await joinLiveClass(classId);
  }

  /// Get all live class status counts
  Future<ApiResponse<Map<String, int>>> getLiveClassStatusCounts() async {
    final result = await getAllStudentLiveClasses();
    if (result.success && result.data != null) {
      final counts = {
        'live': (result.data!['live'] as List?)?.length ?? 0,
        'upcoming': (result.data!['upcoming'] as List?)?.length ?? 0,
        'ended': (result.data!['ended'] as List?)?.length ?? 0,
        'cancelled': (result.data!['cancelled'] as List?)?.length ?? 0,
        'total': (result.data!['all'] as List?)?.length ?? 0,
      };
      return ApiResponse.success(counts, message: 'Status counts retrieved');
    }
    return ApiResponse.error(result.error ?? 'Failed to get status counts');
  }

  // ==================== DEPRECATED/UNUSED METHODS ====================

  /// DEPRECATED: Use getUpcomingStudentLiveClasses() instead
  @Deprecated('Use getUpcomingStudentLiveClasses() instead')
  Future<ApiResponse<List<LiveClass>>> getUpcomingLiveClasses({int limit = 20}) async {
    final result = await getUpcomingStudentLiveClasses();
    if (result.success && result.data != null) {
      final limited = result.data!.take(limit).toList();
      return ApiResponse.success(limited, message: result.message);
    }
    return ApiResponse.error(result.error ?? 'Failed to fetch upcoming classes');
  }

  @Deprecated('Follow functionality not implemented in backend')
  Future<ApiResponse<Map<String, dynamic>>> followLiveClass(String classId) async {
    return ApiResponse.error('Follow functionality not implemented in backend');
  }

  @Deprecated('Unfollow functionality not implemented in backend')
  Future<ApiResponse<Map<String, dynamic>>> unfollowLiveClass(String classId) async {
    return ApiResponse.error('Unfollow functionality not implemented in backend');
  }

  @Deprecated('Toggle follow functionality not implemented in backend')
  Future<ApiResponse<Map<String, dynamic>>> toggleFollowLiveClass(String classId) async {
    return ApiResponse.error('Toggle follow functionality not implemented in backend');
  }

  @Deprecated('Is following check not implemented in backend')
  Future<ApiResponse<Map<String, dynamic>>> isFollowingLiveClass(String classId) async {
    return ApiResponse.success({'isFollowing': false}, message: 'Not implemented');
  }

  @Deprecated('Use getStudentLiveClassStats() instead')
  Future<ApiResponse<Map<String, dynamic>>> getLiveClassStats() async {
    return await getStudentLiveClassStats();
  }
}
