import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class NotificationApiService extends BaseApiService {
  Future<ApiResponse<Map<String, dynamic>>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final queryParams = <String, String>{'page': page.toString(), 'limit': limit.toString()};
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/notifications').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await getHeaders(requireAuth: true));
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
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/notifications/$id/read'),
        headers: await getHeaders(requireAuth: true),
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
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/notifications/read-all'),
        headers: await getHeaders(requireAuth: true),
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
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/notifications/$id'),
        headers: await getHeaders(requireAuth: true),
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
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/notifications/unread-count'),
        headers: await getHeaders(requireAuth: true),
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
