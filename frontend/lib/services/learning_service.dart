import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class LearningApiService extends BaseApiService {
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseSections(String courseId) async {
    final json = await _authAwareJsonGet('/courses/$courseId/sections', requireAuth: true);
    if (json != null) {
      return ApiResponse.success(
        List<Map<String, dynamic>>.from(json['data'] as List? ?? []),
        message: json['message'],
      );
    }
    return ApiResponse.error('Failed to load sections');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getLessonsBySection(String sectionId) async {
    final json = await _authAwareJsonGet('/sections/$sectionId/lessons', requireAuth: true);
    if (json != null) {
      return ApiResponse.success(
        List<Map<String, dynamic>>.from(json['data'] as List? ?? []),
        message: json['message'],
      );
    }
    return ApiResponse.error('Failed to load lessons');
  }

  Future<ApiResponse<Map<String, dynamic>>> getLessonVideoStream(String lessonId, {int expiresIn = 3600}) async {
    final json = await _authAwareJsonGet(
      '/lessons/$lessonId/video/stream?expiresIn=$expiresIn',
      requireAuth: true,
    );
    if (json != null) {
      return ApiResponse.success(json['data'] as Map<String, dynamic>, message: json['message']);
    }
    return ApiResponse.error('Failed to get video stream');
  }

  Future<ApiResponse<Map<String, dynamic>>> createSection(String courseId, Map<String, dynamic> data) async {
    final json = await _authAwareJsonPost('/courses/$courseId/sections', data: data, requireAuth: true);
    if (json != null) {
      return ApiResponse.success(json['data'] as Map<String, dynamic>, message: json['message']);
    }
    return ApiResponse.error('Failed to create section');
  }

  Future<ApiResponse<Map<String, dynamic>>> updateSection(String sectionId, Map<String, dynamic> data) async {
    final json = await _authAwareJsonPatch('/sections/$sectionId', data, requireAuth: true);
    if (json != null) {
      return ApiResponse.success(json['data'] as Map<String, dynamic>, message: json['message']);
    }
    return ApiResponse.error('Failed to update section');
  }

  Future<ApiResponse<dynamic>> deleteSection(String sectionId) async {
    final json = await _authAwareRequest('DELETE', '/sections/$sectionId', requireAuth: true);
    if (json != null) {
      return ApiResponse.success(null, message: json['message']);
    }
    return ApiResponse.error('Failed to delete section');
  }

  Future<ApiResponse<Map<String, dynamic>>> createLesson(String sectionId, Map<String, dynamic> data) async {
    final json = await _authAwareJsonPost('/sections/$sectionId/lessons', data: data, requireAuth: true);
    if (json != null) {
      return ApiResponse.success(json['data'] as Map<String, dynamic>, message: json['message']);
    }
    return ApiResponse.error('Failed to create lesson');
  }

  Future<ApiResponse<Map<String, dynamic>>> updateLesson(String lessonId, Map<String, dynamic> data) async {
    final json = await _authAwareJsonPatch('/lessons/$lessonId', data, requireAuth: true);
    if (json != null) {
      return ApiResponse.success(json['data'] as Map<String, dynamic>, message: json['message']);
    }
    return ApiResponse.error('Failed to update lesson');
  }

  Future<ApiResponse<dynamic>> deleteLesson(String lessonId) async {
    final json = await _authAwareRequest('DELETE', '/lessons/$lessonId', requireAuth: true);
    if (json != null) {
      return ApiResponse.success(null, message: json['message']);
    }
    return ApiResponse.error('Failed to delete lesson');
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadLessonVideo(String lessonId, File videoFile) async {
    try {
      final token = await getToken();
      if (token == null) return ApiResponse.error('User not authenticated');

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/lessons/$lessonId/upload-video');

      http.Response response;
      var bearer = token;

      // First attempt
      {
        final request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer $bearer';
        request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));
        response = await http.Response.fromStream(await request.send());
      }

      if (response.statusCode == 401) {
        final newToken = await refreshAccessToken();
        if (newToken == null) return ApiResponse.error('Session expired. Please login again.');
        bearer = newToken;
        final retry = http.MultipartRequest('POST', uri);
        retry.headers['Authorization'] = 'Bearer $bearer';
        retry.files.add(await http.MultipartFile.fromPath('video', videoFile.path));
        response = await http.Response.fromStream(await retry.send());
      }

      final result = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300 && result['success'] == true) {
        return ApiResponse.success(result['data'] as Map<String, dynamic>, message: result['message']);
      }
      return ApiResponse.error(result['message'] ?? 'Failed to upload video');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> deleteLessonVideo(String lessonId) async {
    final json = await _authAwareRequest('DELETE', '/lessons/$lessonId/video', requireAuth: true);
    if (json != null) {
      return ApiResponse.success(null, message: json['message']);
    }
    return ApiResponse.error('Failed to delete video');
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadThumbnail(File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) return ApiResponse.error('User not authenticated');

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/upload/thumbnail');

      http.Response response;
      var bearer = token;

      {
        final request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer $bearer';
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        response = await http.Response.fromStream(await request.send());
      }

      if (response.statusCode == 401) {
        final newToken = await refreshAccessToken();
        if (newToken == null) return ApiResponse.error('Session expired. Please login again.');
        bearer = newToken;
        final retry = http.MultipartRequest('POST', uri);
        retry.headers['Authorization'] = 'Bearer $bearer';
        retry.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        response = await http.Response.fromStream(await retry.send());
      }

      final result = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300 && result['success'] == true) {
        return ApiResponse.success(result['data'] as Map<String, dynamic>, message: result['message']);
      }
      return ApiResponse.error(result['message'] ?? 'Failed to upload thumbnail');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ── helpers with 401 auto-refresh ──

  Future<Map<String, dynamic>?> _authAwareJsonGet(String endpoint, {bool requireAuth = false}) async {
    return await _authAwareRequest('GET', endpoint, requireAuth: requireAuth);
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

    http.Response response;
    try {
      response = await _sendRequest(method, url, headers, data);
    } catch (e) {
      print('❌ LearningService Error: $e');
      return null;
    }

    if (response.statusCode == 401 && requireAuth) {
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        headers['Authorization'] = 'Bearer $newToken';
        try {
          response = await _sendRequest(method, url, headers, data);
        } catch (e) {
          print('❌ LearningService Error (retry): $e');
          return null;
        }
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
