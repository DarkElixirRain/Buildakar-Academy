import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class InstructorApiService extends BaseApiService {
  Future<ApiResponse<List<Map<String, dynamic>>>> getTopInstructors({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/instructors/top?limit=$limit'),
        headers: await getHeaders(requireAuth: false),
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

  Future<ApiResponse<Map<String, dynamic>>> getInstructorById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/instructors/$id'),
        headers: await getHeaders(requireAuth: false),
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

  Future<ApiResponse<Map<String, dynamic>>> toggleFollowInstructor(String instructorId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/instructors/$instructorId/follow'),
        headers: await getHeaders(requireAuth: true),
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

  Future<ApiResponse<List<Map<String, dynamic>>>> searchInstructors(String query, {int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/instructors/search?q=${Uri.encodeComponent(query)}&limit=$limit'),
        headers: await getHeaders(requireAuth: false),
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
}
