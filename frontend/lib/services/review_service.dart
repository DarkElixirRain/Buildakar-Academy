import 'dart:convert';


import '../services/base_api_service.dart';
import '../types/api_response.dart';

class ReviewApiService extends BaseApiService {
  Future<ApiResponse<Map<String, dynamic>>> createReview({
    required String courseId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'POST',
        endpoint: '/courses/$courseId/reviews',
        body: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
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
      final body = <String, dynamic>{};
      if (rating != null) body['rating'] = rating;
      if (comment != null && comment.isNotEmpty) body['comment'] = comment;

      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/reviews/$reviewId',
        body: body,
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
      final response = await sendAuthenticatedRequest(
        method: 'DELETE',
        endpoint: '/reviews/$reviewId',
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
      final queryString = '?page=$page&limit=$limit';
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/courses/$courseId/reviews$queryString',
      );
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
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/courses/$courseId/my-review',
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

  Future<ApiResponse<Map<String, dynamic>>> createInstructorReview({
    required String instructorId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'POST',
        endpoint: '/instructors/$instructorId/reviews',
        body: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      final data = jsonDecode(response.body);

      if ((response.statusCode == 201 || response.statusCode == 200) && data['success'] == true) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to create instructor review');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getInstructorReviews({
    required String instructorId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryString = '?page=$page&limit=$limit';
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/instructors/$instructorId/reviews$queryString',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success({
          'data': data['data'] ?? [],
          'meta': data['meta'] ?? {},
        }, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch instructor reviews');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
