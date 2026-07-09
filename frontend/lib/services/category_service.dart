import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class CategoryApiService extends BaseApiService {
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories({
    bool includeCourses = false,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, String>{
        if (includeCourses) 'includeCourses': 'true',
        if (isActive != null) 'isActive': isActive.toString(),
      };

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/categories').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: await getHeaders(requireAuth: false));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> categories = data['data'] ?? [];
        return ApiResponse.success(
          categories.map((e) => e as Map<String, dynamic>).toList(),
          message: data['message'],
        );
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch categories');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCategoryById(
    String id, {
    bool includeCourses = false,
  }) async {
    try {
      final queryParams = <String, String>{if (includeCourses) 'includeCourses': 'true'};
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/categories/$id').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: await getHeaders(requireAuth: false));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch category');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCategoryBySlug(
    String slug, {
    bool includeCourses = false,
    int limit = 10,
    int offset = 0,
    String sortBy = 'newest',
  }) async {
    try {
      final queryParams = <String, String>{
        if (includeCourses) 'includeCourses': 'true',
        'limit': limit.toString(),
        'offset': offset.toString(),
        'sortBy': sortBy,
      };

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/categories/slug/$slug').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: await getHeaders(requireAuth: false));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch category');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCategoryStats(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/categories/$id/stats'),
        headers: await getHeaders(requireAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch category stats');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
