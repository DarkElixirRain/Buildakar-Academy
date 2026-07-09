// lib/services/base_api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../types/api_response.dart';
import '../config/app_config.dart';

class BaseApiService {
  final http.Client _client = http.Client();

  // Token management
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      // Handle error
    }
  }

  // User management
  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData));
    } catch (e) {
      // Handle error
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      // Handle error
    }
  }

  // Session management
  Future<void> clearSession() async {
    await clearToken();
    await clearUser();
  }

  // Google Sign Out
  Future<void> signOutFromGoogle() async {
    await clearSession();
  }

  // Headers
  Future<Map<String, String>> getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Helper method to get auth headers with validation
  Future<Map<String, String>?> getAuthHeadersWithValidation() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==================== HTTP METHODS ====================

  /// GET request
  Future<ApiResponse> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final token = await getToken();
      
      print('🌐 GET Request to: $url');
      
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          ...?headers,
        },
      );
      
      print('📥 GET Response Status: ${response.statusCode}');
      print('📥 GET Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// POST request
  Future<ApiResponse> post(String endpoint, {dynamic data, Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final token = await getToken();
      
      print('🌐 POST Request to: $url');
      print('📤 POST Data: $data');
      
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          ...?headers,
        },
        body: data != null ? jsonEncode(data) : null,
      );
      
      print('📥 POST Response Status: ${response.statusCode}');
      print('📥 POST Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse> put(String endpoint, {dynamic data, Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final token = await getToken();
      
      print('🌐 PUT Request to: $url');
      print('📤 PUT Data: $data');
      
      final response = await _client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          ...?headers,
        },
        body: data != null ? jsonEncode(data) : null,
      );
      
      print('📥 PUT Response Status: ${response.statusCode}');
      print('📥 PUT Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ PUT Error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final token = await getToken();
      
      print('🌐 DELETE Request to: $url');
      
      final response = await _client.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          ...?headers,
        },
      );
      
      print('📥 DELETE Response Status: ${response.statusCode}');
      print('📥 DELETE Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ DELETE Error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// PATCH request
  Future<ApiResponse> patch(String endpoint, {dynamic data, Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final token = await getToken();
      
      print('🌐 PATCH Request to: $url');
      print('📤 PATCH Data: $data');
      
      final response = await _client.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          ...?headers,
        },
        body: data != null ? jsonEncode(data) : null,
      );
      
      print('📥 PATCH Response Status: ${response.statusCode}');
      print('📥 PATCH Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ PATCH Error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ==================== RESPONSE HANDLING ====================

  /// Handle HTTP response with proper error handling
  ApiResponse _handleResponse(http.Response response) {
    try {
      print('🔍 Parsing response...');
      
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ApiResponse.success(null, message: 'Success');
        } else {
          return ApiResponse.error('Empty response with status: ${response.statusCode}');
        }
      }
      
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('📊 Parsed JSON: $jsonResponse');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Check if the response has a 'data' field
        if (jsonResponse.containsKey('data')) {
          return ApiResponse.success(
            jsonResponse['data'],
            message: jsonResponse['message'] ?? 'Success',
          );
        } else {
          // If no 'data' field, return the entire response
          return ApiResponse.success(
            jsonResponse,
            message: jsonResponse['message'] ?? 'Success',
          );
        }
      } else {
        // Error response
        final errorMsg = jsonResponse['message'] ?? 
                        jsonResponse['error'] ?? 
                        'Request failed with status: ${response.statusCode}';
        return ApiResponse.error(errorMsg);
      }
    } catch (e) {
      print('❌ Parse error: $e');
      // If response body is not JSON
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null, message: 'Success');
      } else {
        return ApiResponse.error(
          'Request failed with status: ${response.statusCode}',
        );
      }
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}