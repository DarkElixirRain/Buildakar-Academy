import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../types/api_response.dart';
import '../config/app_config.dart';
import '../models/auth_model.dart';

class BaseApiService {
  final http.Client _client = http.Client();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Called when the refresh token is permanently invalid/expired
  /// so the app can perform a centralized logout.
  static void Function()? onSessionExpired;

  // ----- token management -----
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'token');
    } catch (e) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'token', value: token);
    } catch (e) {
      // Log error
    }
  }

  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: 'token');
    } catch (e) {
      // Log error
    }
  }

  // ----- refresh token management -----
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: 'refreshToken');
    } catch (e) {
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: 'refreshToken', value: token);
    } catch (e) {
      // Log error
    }
  }

  Future<void> clearRefreshToken() async {
    try {
      await _secureStorage.delete(key: 'refreshToken');
    } catch (e) {
      // Log error
    }
  }

  // ----- token expiry -----
  Future<String?> getTokenExpiry() async {
    try {
      return await _secureStorage.read(key: 'tokenExpiresAt');
    } catch (e) {
      return null;
    }
  }

  Future<void> saveTokenExpiry(String expiry) async {
    try {
      await _secureStorage.write(key: 'tokenExpiresAt', value: expiry);
    } catch (e) {
      // Log error
    }
  }

  Future<void> clearTokenExpiry() async {
    try {
      await _secureStorage.delete(key: 'tokenExpiresAt');
    } catch (e) {
      // Log error
    }
  }

  // ----- user management -----
  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _secureStorage.write(
        key: 'user',
        value: jsonEncode(userData),
      );
    } catch (e) {
      // Log error
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final userData = await _secureStorage.read(key: 'user');
      if (userData != null) return jsonDecode(userData);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      await _secureStorage.delete(key: 'user');
    } catch (e) {
      // Log error
    }
  }

  // ----- session management -----
  Future<void> clearSession() async {
    await clearToken();
    await clearRefreshToken();
    await clearTokenExpiry();
    await clearUser();
  }

  // Google Sign Out
  Future<void> signOutFromGoogle() async {
    await clearSession();
  }

  // ==================== REFRESH TOKEN ROTATION ====================
  
  static bool _refreshInProgress = false;
  static Completer<String?>? _refreshCompleter;
  static int _refreshAttempts = 0;
  static const int _maxRefreshAttempts = 3;

  /// Check if token is about to expire and refresh if needed
  Future<bool> _ensureValidToken() async {
    try {
      final expiryStr = await getTokenExpiry();
      if (expiryStr == null) return true;

      final expiry = DateTime.parse(expiryStr);
      final timeUntilExpiry = expiry.difference(DateTime.now());
      
      // Refresh if token expires in 5 minutes or less
      if (timeUntilExpiry.inMinutes <= 5) {
        print('🔄 Token expires in ${timeUntilExpiry.inMinutes} minutes, refreshing proactively...');
        final newToken = await refreshAccessToken();
        return newToken != null;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Attempt to refresh the access token with rotation
  Future<String?> refreshAccessToken() async {
    // If a refresh is already in progress, wait for it
    if (_refreshInProgress) {
      return _refreshCompleter?.future;
    }

    _refreshInProgress = true;
    _refreshCompleter = Completer<String?>();
    _refreshAttempts = 0;

    try {
      String? refreshToken = await getRefreshToken();
      
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ No refresh token available');
        _refreshCompleter!.complete(null);
        return null;
      }

      while (_refreshAttempts < _maxRefreshAttempts) {
        _refreshAttempts++;
        print('🔄 Refresh attempt $_refreshAttempts/$_maxRefreshAttempts');
        
        try {
          final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/refresh');
          final response = await _client.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          );

          print('📡 Refresh response status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final result = await _handleRefreshResponse(response);
            if (result != null) {
              _refreshCompleter!.complete(result);
              return result;
            }
          } 
          else if (response.statusCode == 401) {
            // Refresh token itself is expired or invalid
            print('⚠️ Refresh token is invalid/expired, attempting to get new one...');
            
            // Try to get a new refresh token using the old one if server supports rotation
            final refreshResult = await _attemptRefreshTokenRotation();
            if (refreshResult != null) {
              _refreshCompleter!.complete(refreshResult);
              return refreshResult;
            }
            
            // If rotation fails, we need to log out
            print('❌ Refresh token rotation failed');
            await _handleRefreshFailure();
            return null;
          }
          else if (response.statusCode >= 500) {
            // Server error, wait and retry
            print('⚠️ Server error, waiting before retry...');
            await Future.delayed(Duration(seconds: _refreshAttempts * 2));
            continue;
          }
          else {
            // Other errors
            print('❌ Refresh failed with status: ${response.statusCode}');
            await _handleRefreshFailure();
            return null;
          }
        } catch (e) {
          print('⚠️ Refresh attempt $_refreshAttempts failed: $e');
          if (_refreshAttempts < _maxRefreshAttempts) {
            await Future.delayed(Duration(seconds: _refreshAttempts));
            continue;
          }
          await _handleRefreshFailure();
          return null;
        }
      }

      // All attempts exhausted
      await _handleRefreshFailure();
      return null;
      
    } catch (e) {
      print('❌ Refresh token error: $e');
      await _handleRefreshFailure();
      return null;
    } finally {
      _refreshInProgress = false;
      _refreshAttempts = 0;
      _refreshCompleter = null;
    }
  }

  /// Handle the refresh response and extract tokens
  Future<String?> _handleRefreshResponse(http.Response response) async {
    try {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Try multiple response formats
      String? newToken;
      String? newRefreshToken;
      String? newExpiresAt;

      // Format 1: Direct response with token
      if (jsonResponse.containsKey('token')) {
        newToken = jsonResponse['token'] as String?;
        newRefreshToken = jsonResponse['refreshToken'] as String?;
        newExpiresAt = jsonResponse['expiresAt'] as String?;
      }
      // Format 2: Response with data wrapper
      else if (jsonResponse.containsKey('data')) {
        final data = jsonResponse['data'] as Map<String, dynamic>?;
        if (data != null) {
          newToken = data['accessToken'] as String? ?? data['token'] as String?;
          newRefreshToken = data['refreshToken'] as String?;
          newExpiresAt = data['accessTokenExpiresAt'] as String? ?? data['expiresAt'] as String?;
        }
      }
      // Format 3: Try AuthData.fromJson
      else {
        try {
          final authData = AuthData.fromJson(jsonResponse);
          newToken = authData.token;
          newRefreshToken = authData.refreshToken;
          newExpiresAt = authData.expiresAt;
        } catch (e) {
          print('⚠️ AuthData.fromJson parsing failed: $e');
        }
      }

      if (newToken != null && newToken.isNotEmpty) {
        // Save the new tokens
        await saveToken(newToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await saveRefreshToken(newRefreshToken);
        }
        if (newExpiresAt != null && newExpiresAt.isNotEmpty) {
          await saveTokenExpiry(newExpiresAt);
        }
        
        print('✅ Token refreshed successfully');
        return newToken;
      }
      
      return null;
    } catch (e) {
      print('❌ Error parsing refresh response: $e');
      return null;
    }
  }

  /// Attempt to rotate the refresh token using a special endpoint
  Future<String?> _attemptRefreshTokenRotation() async {
    try {
      // If your API supports refresh token rotation, call a specific endpoint
      // This is optional - only use if your backend supports it
      
      // Option 1: Try to refresh using the old refresh token with rotation
      final oldRefreshToken = await getRefreshToken();
      if (oldRefreshToken == null) return null;
      
      final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/rotate-refresh');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': oldRefreshToken}),
      );
      
      if (response.statusCode == 200) {
        return await _handleRefreshResponse(response);
      }
      
      return null;
    } catch (e) {
      print('❌ Refresh token rotation error: $e');
      return null;
    }
  }

  /// Handle refresh failure - only log out if absolutely necessary
  Future<void> _handleRefreshFailure() async {
    // Only clear session and logout if refresh token is permanently invalid
    // This should only happen if the user manually logs out or the refresh token is revoked
    
    // Check if we have a valid refresh token before clearing
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      // No refresh token means we can't recover
      await clearSession();
      if (onSessionExpired != null) {
        // Use Future.microtask instead of WidgetsBinding
        Future.microtask(() {
          onSessionExpired!();
        });
      }
      return;
    }
    
    // Try one more time with a different approach
    try {
      // Wait a bit and retry
      await Future.delayed(const Duration(seconds: 2));
      final result = await refreshAccessToken();
      if (result != null) {
        print('✅ Recovery successful after delay');
        return;
      }
    } catch (e) {
      print('❌ Recovery attempt failed: $e');
    }
    
    // If all recovery attempts fail, clear session
    await clearSession();
    if (onSessionExpired != null) {
      // Use Future.microtask instead of WidgetsBinding
      Future.microtask(() {
        onSessionExpired!();
      });
    }
  }

  // ----- headers -----
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

  Future<Map<String, String>?> getAuthHeadersWithValidation() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ----- low-level request with 401 retry -----
  Future<ApiResponse> _request(
    String method,
    String endpoint, {
    dynamic data,
    Map<String, String>? extraHeaders,
    bool requireAuth = false,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

    // Ensure valid token before making request
    if (requireAuth) {
      final isValid = await _ensureValidToken();
      if (!isValid) {
        // If we can't get a valid token, continue anyway - the server will handle it
        print('⚠️ Could not ensure valid token, proceeding anyway');
      }
    }

    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty && requireAuth) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extraHeaders != null) headers.addAll(extraHeaders);

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client.get(url, headers: headers);
          break;
        case 'POST':
          response = await _client.post(
            url,
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        case 'PUT':
          response = await _client.put(
            url,
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        case 'DELETE':
          response = await _client.delete(url, headers: headers);
          break;
        case 'PATCH':
          response = await _client.patch(
            url,
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        default:
          return ApiResponse.error('Unsupported HTTP method: $method');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }

    // Handle 401 with retry
    if (response.statusCode == 401 && requireAuth) {
      print('⚠️ Received 401, attempting token refresh...');
      
      final newToken = await refreshAccessToken();

      if (newToken != null && newToken.isNotEmpty) {
        // Retry the original request with new token
        headers['Authorization'] = 'Bearer $newToken';
        try {
          switch (method) {
            case 'GET':
              response = await _client.get(url, headers: headers);
              break;
            case 'POST':
              response = await _client.post(
                url,
                headers: headers,
                body: data != null ? jsonEncode(data) : null,
              );
              break;
            case 'PUT':
              response = await _client.put(
                url,
                headers: headers,
                body: data != null ? jsonEncode(data) : null,
              );
              break;
            case 'DELETE':
              response = await _client.delete(url, headers: headers);
              break;
            case 'PATCH':
              response = await _client.patch(
                url,
                headers: headers,
                body: data != null ? jsonEncode(data) : null,
              );
              break;
          }
          print('✅ Retry successful with new token');
          return _handleResponse(response);
        } catch (e) {
          return ApiResponse.error(e.toString());
        }
      } else {
        // Only return session expired if refresh token is truly invalid
        // Don't logout immediately - let the request fail gracefully
        return ApiResponse.error('Unable to refresh token. Please try again.');
      }
    }

    return _handleResponse(response);
  }

  // ==================== LOW-LEVEL AUTHENTICATED HTTP ====================

  Future<http.Response> sendAuthenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, String>? extraHeaders,
    dynamic body,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

    // Ensure valid token before making request
    final isValid = await _ensureValidToken();
    if (!isValid) {
      print('⚠️ Could not ensure valid token, continuing anyway');
    }

    final token = await getToken();
    var currentHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };
    if (token != null && token.isNotEmpty) {
      currentHeaders['Authorization'] = 'Bearer $token';
    }

    var response = await _sendHttpRequest(method, url, currentHeaders, body);

    // If 401, try to refresh and retry once
    if (response.statusCode == 401) {
      print('⚠️ Received 401 in sendAuthenticatedRequest, refreshing...');
      
      final newToken = await refreshAccessToken();
      if (newToken != null && newToken.isNotEmpty) {
        currentHeaders['Authorization'] = 'Bearer $newToken';
        response = await _sendHttpRequest(method, url, currentHeaders, body);
        print('✅ Retry successful in sendAuthenticatedRequest');
      } else {
        // Don't throw exception - let the caller handle the 401
        print('⚠️ Unable to refresh token in sendAuthenticatedRequest');
      }
    }

    return response;
  }

  Future<http.Response> _sendHttpRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    dynamic body,
  ) async {
    switch (method) {
      case 'GET':
        return await _client.get(url, headers: headers);
      case 'POST':
        return await _client.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await _client.put(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PATCH':
        return await _client.patch(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await _client.delete(url, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // ==================== PUBLIC HTTP METHODS ====================

  Future<ApiResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    bool requireAuth = false,
  }) {
    return _request('GET', endpoint,
        extraHeaders: headers, requireAuth: requireAuth);
  }

  Future<ApiResponse> post(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    bool requireAuth = false,
  }) {
    return _request('POST', endpoint,
        data: data, extraHeaders: headers, requireAuth: requireAuth);
  }

  Future<ApiResponse> put(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    bool requireAuth = false,
  }) {
    return _request('PUT', endpoint,
        data: data, extraHeaders: headers, requireAuth: requireAuth);
  }

  Future<ApiResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool requireAuth = false,
  }) {
    return _request('DELETE', endpoint,
        extraHeaders: headers, requireAuth: requireAuth);
  }

  Future<ApiResponse> patch(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    bool requireAuth = false,
  }) {
    return _request('PATCH', endpoint,
        data: data, extraHeaders: headers, requireAuth: requireAuth);
  }

  // ==================== RESPONSE HANDLING ====================

  ApiResponse _handleResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ApiResponse.success(null, message: 'Success');
        }
        return ApiResponse.error(
            'Empty response with status: ${response.statusCode}');
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse.containsKey('data')) {
          return ApiResponse.success(
            jsonResponse['data'],
            message: jsonResponse['message'] ?? 'Success',
          );
        }
        return ApiResponse.success(
          jsonResponse,
          message: jsonResponse['message'] ?? 'Success',
        );
      }

      final errorMsg = jsonResponse['message'] ??
          jsonResponse['error'] ??
          'Request failed with status: ${response.statusCode}';
      return ApiResponse.error(errorMsg);
    } catch (e) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null, message: 'Success');
      }
      return ApiResponse.error(
          'Request failed with status: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}