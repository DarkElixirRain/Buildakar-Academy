import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class NotesMaterialsApiService extends BaseApiService {
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseNotes(String courseId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId/notes'),
        headers: await getHeaders(requireAuth: true),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          List<Map<String, dynamic>>.from(data['data'] ?? []),
          message: data['message'],
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to load notes');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> addCourseNote(String courseId, String content, String? lessonId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId/notes'),
        headers: await getHeaders(requireAuth: true),
        body: jsonEncode({'content': content, 'lessonId': lessonId}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to add note');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> deleteCourseNote(String noteId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/notes/$noteId'),
        headers: await getHeaders(requireAuth: true),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to delete note');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseMaterials(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId/materials'),
        headers: await getHeaders(requireAuth: false),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          List<Map<String, dynamic>>.from(data['data'] ?? []),
          message: data['message'],
        );
      }
      return ApiResponse.error(data['message'] ?? 'Failed to load materials');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
