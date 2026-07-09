import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class ReviewApiService extends BaseApiService {
  Future<ApiResponse<Map<String, dynamic>>> createReview({
    required String courseId,
    required int rating,
    String? comment,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId/reviews'),
        headers: await getHeaders(requireAuth: true),
        body: jsonEncode({
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        }),
      );
      final data = jsonDecode(response.body);

      if ((response.statusCode == 201 || response.statusCode == 200) && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to create review');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final body = <String, dynamic>{};
      if (rating != null) body['rating'] = rating;
      if (comment != null && comment.isNotEmpty) body['comment'] = comment;

      final response = await http.patch(
        Uri.parse('${AppConfig.apiBaseUrl}/reviews/$reviewId'),
        headers: await getHeaders(requireAuth: true),
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to update review');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> deleteReview(String reviewId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/reviews/$reviewId'),
        headers: await getHeaders(requireAuth: true),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to delete review');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCourseReviews({
    required String courseId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{'page': page.toString(), 'limit': limit.toString()};
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId/reviews').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await getHeaders(requireAuth: false));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success({
          'data': data['data'] ?? [],
          'meta': data['meta'] ?? {},
        }, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch reviews');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getMyReview(String courseId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId/my-review'),
        headers: await getHeaders(requireAuth: true),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch your review');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
