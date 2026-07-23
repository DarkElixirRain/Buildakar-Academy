import 'dart:convert';

import '../services/base_api_service.dart';
import '../types/api_response.dart';

class CategoryApiService extends BaseApiService {
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories({
    bool includeCourses = false,
    bool? isActive,
  }) async {
    try {
      final qParams = <String>[];
      if (includeCourses) qParams.add('includeCourses=true');
      if (isActive != null) qParams.add('isActive=$isActive');
      final qs = qParams.isNotEmpty ? '?${qParams.join('&')}' : '';

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/categories$qs',
      );
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
      final qs = includeCourses ? '?includeCourses=true' : '';
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/categories/$id$qs',
      );
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
      final qParams = <String>[
        if (includeCourses) 'includeCourses=true',
        'limit=$limit',
        'offset=$offset',
        'sortBy=$sortBy',
      ];
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/categories/slug/$slug?${qParams.join('&')}',
      );
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
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/categories/$id/stats',
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
