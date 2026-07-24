import 'dart:convert';


import '../services/base_api_service.dart';
import '../types/api_response.dart';

class NotificationApiService extends BaseApiService {
  Future<ApiResponse<Map<String, dynamic>>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final queryString = '?page=$page&limit=$limit';
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/notifications$queryString',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success({
          'data': data['data'] ?? [],
          'meta': data['meta'] ?? {},
        }, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch notifications');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> markNotificationAsRead(String id) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/notifications/$id/read',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to mark notification as read');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> markAllNotificationsAsRead() async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/notifications/read-all',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to mark all as read');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> deleteNotification(String id) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'DELETE',
        endpoint: '/notifications/$id',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to delete notification');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUnreadCount() async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/notifications/unread-count',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success({'count': data['data']?['count'] ?? 0}, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to get unread count');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
