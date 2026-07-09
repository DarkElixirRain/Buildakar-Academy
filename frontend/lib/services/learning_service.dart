import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class LearningApiService extends BaseApiService {
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseSections(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/sections/course/$courseId'),
        headers: await getHeaders(requireAuth: false),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          List<Map<String, dynamic>>.from(data['data'] ?? []),
          message: data['message'],
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to load sections');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getLessonsBySection(String sectionId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/lessons/section/$sectionId'),
        headers: await getHeaders(requireAuth: false),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          List<Map<String, dynamic>>.from(data['data'] ?? []),
          message: data['message'],
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to load lessons');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getLessonVideoStream(String lessonId, {int expiresIn = 3600}) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/lessons/$lessonId/video/stream?expiresIn=$expiresIn'),
        headers: await getHeaders(requireAuth: true),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to get video stream');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
