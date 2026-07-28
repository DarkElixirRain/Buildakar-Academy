import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../types/api_response.dart';
import '../config/app_config.dart';

class BaseApiService {
  final http.Client _client = http.Client();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ----- token management -----
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'token');
    } catch (e) {
      print('❌ BaseApiService: Error getting token: $e');
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'token', value: token);
    } catch (e) {
      print('❌ BaseApiService: Error saving token: $e');
    }
  }

  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: 'token');
    } catch (e) {
      print('❌ BaseApiService: Error clearing token: $e');
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
      print('❌ BaseApiService: Error saving refresh token: $e');
    }
  }

  Future<void> clearRefreshToken() async {
    try {
      await _secureStorage.delete(key: 'refreshToken');
    } catch (e) {
      print('❌ BaseApiService: Error clearing refresh token: $e');
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
      print('❌ BaseApiService: Error saving token expiry: $e');
    }
  }

  Future<void> clearTokenExpiry() async {
    try {
      await _secureStorage.delete(key: 'tokenExpiresAt');
    } catch (e) {
      print('❌ BaseApiService: Error clearing token expiry: $e');
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
      print('❌ BaseApiService: Error saving user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final userData = await _secureStorage.read(key: 'user');
      if (userData != null) return jsonDecode(userData);
      return null;
    } catch (e) {
      print('❌ BaseApiService: Error getting user: $e');
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      await _secureStorage.delete(key: 'user');
    } catch (e) {
      print('❌ BaseApiService: Error clearing user: $e');
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

  // ----- token refresh (internal, no 401 loop) -----
  static bool _refreshInProgress = false;
  static Completer<String?>? _refreshCompleter;

  /// Attempt to refresh the access token by calling POST /auth/refresh
  /// with the stored refresh token.  Uses a lock so only one refresh
  /// runs at a time; concurrent callers await the same result.
  Future<String?> refreshAccessToken() async {
    // If a refresh is already in flight, wait for it
    if (_refreshInProgress) {
      return await _refreshCompleter?.future;
    }

    _refreshInProgress = true;
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('⚠️ BaseApiService: No refresh token stored');
        _refreshCompleter!.complete(null);
        return null;
      }

      print('🔄 BaseApiService: Refreshing access token...');
      final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/refresh');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as Map<String, dynamic>?;

        if (data != null) {
          final newToken = data['accessToken'] as String?;
          final newRefreshToken = data['refreshToken'] as String?;
          final newExpiresAt = data['accessTokenExpiresAt'] as String?;

          if (newToken != null && newToken.isNotEmpty) {
            await saveToken(newToken);
            if (newRefreshToken != null) {
              await saveRefreshToken(newRefreshToken);
            }
            if (newExpiresAt != null) {
              await saveTokenExpiry(newExpiresAt);
            }
            print('✅ BaseApiService: Token refreshed successfully');
            _refreshCompleter!.complete(newToken);
            return newToken;
          }
        }
      }

      // Refresh failed – clear everything
      print('❌ BaseApiService: Token refresh failed (${response.statusCode})');
      await clearSession();
      _refreshCompleter!.complete(null);
      return null;
    } catch (e) {
      print('❌ BaseApiService: Token refresh error: $e');
      await clearSession();
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshInProgress = false;
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
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty && requireAuth) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extraHeaders != null) headers.addAll(extraHeaders);

    print('🌐 $method Request to: $url');
    print('🔐 requireAuth: $requireAuth');
    if (data != null && method != 'GET') {
      print('📤 $method Data: $data');
    }

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
      print('❌ $method Error: $e');
      return ApiResponse.error(e.toString());
    }

    print('📥 $method Response Status: ${response.statusCode}');

    // ── 401 → try token refresh once ──
    if (response.statusCode == 401 && requireAuth) {
      print('🔄 BaseApiService: Got 401, attempting token refresh...');
      final newToken = await refreshAccessToken();

      if (newToken != null) {
        // Retry with the new token
        headers['Authorization'] = 'Bearer $newToken';
        print('🔄 BaseApiService: Retrying $method request after refresh...');
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
        } catch (e) {
          print('❌ $method Error (retry): $e');
          return ApiResponse.error(e.toString());
        }
        print('📥 $method Retry Response Status: ${response.statusCode}');
      } else {
        // Refresh failed – return a clear error so the caller can redirect
        return ApiResponse.error('Session expired. Please login again.');
      }
    }

    return _handleResponse(response);
  }

  // ==================== LOW-LEVEL AUTHENTICATED HTTP ====================

  /// Sends an authenticated HTTP request with automatic 401 token refresh.
  /// Returns the raw [http.Response] so callers can handle parsing themselves.
  /// The 401 retry uses the same lock as [_request] via [refreshAccessToken].
  Future<http.Response> sendAuthenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, String>? extraHeaders,
    dynamic body,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

    var currentHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      currentHeaders['Authorization'] = 'Bearer $token';
    }

    var response = await _sendHttpRequest(method, url, currentHeaders, body);

    if (response.statusCode == 401) {
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        currentHeaders['Authorization'] = 'Bearer $newToken';
        response = await _sendHttpRequest(method, url, currentHeaders, body);
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
