// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_model.dart';
import 'base_api_service.dart';
import '../types/api_response.dart';
import '../config/app_config.dart';

// AuthApiService - Handles API calls for authentication
class AuthApiService extends BaseApiService {
  // Login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      print('🔐 AuthApiService: Login request started');
      final response = await post(
        '/auth/login',
        data: request.toJson(),
        requireAuth: false,
      );
      print('📦 AuthApiService: Login response received');
      print('📊 AuthApiService: Response success: ${response.success}');
      print('📊 AuthApiService: Response data: ${response.data}');

      if (!response.success) {
        throw Exception(response.error ?? response.message ?? 'Login failed');
      }
      
      if (response.data == null) {
        print('❌ AuthApiService: Response data is null');
        throw Exception('No data received from server');
      }
      
      final rawData = response.data as Map<String, dynamic>;
      
      if (rawData.containsKey('user') && rawData.containsKey('accessToken')) {
        final transformedData = {
          'success': true,
          'message': response.message ?? 'Login successful',
          'data': {
            'user': rawData['user'],
            'token': rawData['accessToken'],
            'refreshToken': rawData['refreshToken'],
            'expiresAt': rawData['accessTokenExpiresAt'],
          }
        };
        return AuthResponse.fromJson(transformedData);
      } else {
        return AuthResponse.fromJson(rawData);
      }
    } catch (e) {
      print('❌ AuthApiService: Login error: $e');
      rethrow;
    }
  }

  // Register
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await post(
        '/auth/register',
        data: request.toJson(),
        requireAuth: false,
      );

      if (!response.success) {
        throw Exception(response.error ?? response.message ?? 'Registration failed');
      }
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      
      final rawData = response.data as Map<String, dynamic>;
      
      final transformedData = {
        'success': true,
        'message': response.message ?? 'Registration successful',
        'data': {
          'user': rawData['user'],
          'token': rawData['accessToken'],
          'refreshToken': rawData['refreshToken'],
          'expiresAt': rawData['accessTokenExpiresAt'],
        }
      };
      
      return AuthResponse.fromJson(transformedData);
    } catch (e) {
      print('❌ AuthApiService: Register error: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      GoogleSignInAccount account;

      if (kIsWeb) {
        throw Exception('Google Sign-In is not supported on web. Please sign in with email and password.');
      }

      await googleSignIn.initialize(
        clientId: AppConfig.googleAndroidClientId,
        serverClientId: AppConfig.googleWebClientId,
      );
      account = await googleSignIn.authenticate();

      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      final response = await post(
        '/auth/google',
        data: {'idToken': auth.idToken},
        requireAuth: false,
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final rawData = response.data as Map<String, dynamic>;

      final transformedData = {
        'success': true,
        'message': response.message ?? 'Google sign in successful',
        'data': {
          'user': rawData['user'],
          'token': rawData['accessToken'],
          'refreshToken': rawData['refreshToken'],
          'expiresAt': rawData['accessTokenExpiresAt'],
        }
      };

      return AuthResponse.fromJson(transformedData);
    } catch (e) {
      print('❌ AuthApiService: Google sign in error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await post('/auth/logout', requireAuth: true);
    } catch (e) {
      // Ignore logout errors
      print('⚠️ AuthApiService: Logout error: $e');
    }
  }

  // Get current user - FIXED
  Future<User> getMe() async {
    try {
      print('📡 AuthApiService: Getting current user');
      final response = await get('/auth/me', requireAuth: true);
      print('📊 AuthApiService: getMe response status: ${response.success}');
      print('📊 AuthApiService: getMe response data: ${response.data}');
      
      if (!response.success) {
        print('❌ AuthApiService: getMe failed: ${response.error}');
        throw Exception(response.error ?? 'Failed to get user');
      }
      
      if (response.data == null) {
        print('❌ AuthApiService: getMe response data is null');
        throw Exception('No user data received');
      }
      
      // The backend returns user data directly in the 'data' field
      // response.data is already the user object
      if (response.data is Map) {
        final userData = response.data as Map<String, dynamic>;
        
        // If it has an 'id' field, it's the user object
        if (userData.containsKey('id')) {
          print('✅ AuthApiService: User found with id: ${userData['id']}');
          return User.fromJson(userData);
        } 
        // If it has a 'data' field (nested), use that
        else if (userData.containsKey('data') && userData['data'] is Map) {
          print('✅ AuthApiService: User found in nested data');
          return User.fromJson(userData['data']);
        }
      }
      
      throw Exception('Invalid user data format: ${response.data}');
    } catch (e) {
      print('❌ AuthApiService: getMe error: $e');
      rethrow;
    }
  }

  // Update role
  Future<User> updateRole(String role) async {
    try {
      final response = await put(
        '/auth/role',
        data: {'role': role},
        requireAuth: true,
      );
      
      if (!response.success || response.data == null) {
        throw Exception(response.error ?? 'Failed to update role');
      }
      
      final rawData = response.data as Map<String, dynamic>;
      
      // Check if user is in 'data' field or directly
      if (rawData.containsKey('data') && rawData['data'] is Map) {
        return User.fromJson(rawData['data']);
      } else {
        return User.fromJson(rawData);
      }
    } catch (e) {
      print('❌ AuthApiService: Update role error: $e');
      rethrow;
    }
  }

  // Verify email with 6-digit code
  Future<ApiResponse> verifyEmail(String email, String code) async {
    try {
      final response = await post(
        '/auth/verify-email',
        data: {'email': email, 'code': code},
        requireAuth: false,
      );
      return response;
    } catch (e) {
      print('❌ AuthApiService: verifyEmail error: $e');
      rethrow;
    }
  }

  // Resend verification code
  Future<ApiResponse> resendVerification(String email) async {
    try {
      final response = await post(
        '/auth/resend-verification',
        data: {'email': email},
        requireAuth: false,
      );
      return response;
    } catch (e) {
      print('❌ AuthApiService: resendVerification error: $e');
      rethrow;
    }
  }

  // Check if authenticated
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

// AuthService - Handles local storage and business logic
class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthApiService _authApiService = AuthApiService();
  
  static const String _keyUser = 'user';
  static const String _keyToken = 'token';
  static const String _keyRefreshToken = 'refreshToken';
  static const String _keyTokenExpiry = 'tokenExpiresAt';
  
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  /// Initialize auth service
  Future<void> init() async {
    try {
      final userJson = await _storage.read(key: _keyUser);
      if (userJson != null) {
        final Map<String, dynamic> userMap = Map<String, dynamic>.from(
          json.decode(userJson) as Map<String, dynamic>
        );
        _currentUser = User.fromJson(userMap);
        print('✅ AuthService: User loaded from storage: ${_currentUser?.name}');
      }
    } catch (e) {
      print('❌ AuthService: Error initializing: $e');
    }
  }
  
  /// Save user to secure storage
  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _storage.write(key: _keyUser, value: json.encode(userData));
      _currentUser = User.fromJson(userData);
      print('✅ AuthService: User saved: ${_currentUser?.name}');
    } catch (e) {
      print('❌ AuthService: Error saving user: $e');
    }
  }
  
  /// Save token to secure storage
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _keyToken, value: token);
      print('✅ AuthService: Token saved');
    } catch (e) {
      print('❌ AuthService: Error saving token: $e');
    }
  }
  
  /// Save refresh token to secure storage
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
    } catch (e) {
      print('❌ AuthService: Error saving refresh token: $e');
    }
  }
  
  /// Save token expiry to secure storage
  Future<void> saveTokenExpiry(String expiry) async {
    try {
      await _storage.write(key: _keyTokenExpiry, value: expiry);
    } catch (e) {
      print('❌ AuthService: Error saving token expiry: $e');
    }
  }
  
  /// Get stored token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      print('❌ AuthService: Error getting token: $e');
      return null;
    }
  }
  
  /// Login user
  Future<bool> login(String email, String password) async {
    try {
      print('🔐 AuthService: Login attempt for: $email');
      
      final response = await _authApiService.login(
        LoginRequest(email: email, password: password)
      );
      
      print('📦 AuthService: Login response received');
      print('📊 AuthService: Response success: ${response.success}');
      print('📊 AuthService: Response message: ${response.message}');
      
      if (response.success && response.data != null) {
        print('👤 AuthService: User data: ${response.data!.user.toJson()}');
        await saveUser(response.data!.user.toJson());
        
        if (response.data!.token != null && response.data!.token!.isNotEmpty) {
          print('🔑 AuthService: Token received');
          await saveToken(response.data!.token!);
          if (response.data!.refreshToken != null) {
            await saveRefreshToken(response.data!.refreshToken!);
          }
          if (response.data!.expiresAt != null) {
            await saveTokenExpiry(response.data!.expiresAt!);
          }
          print('✅ AuthService: Token saved successfully');
        } else {
          print('⚠️ AuthService: No token received');
          return false;
        }
        
        print('✅ AuthService: Login successful for: ${response.data!.user.name}');
        return true;
      } else {
        final errMsg = response.message ?? response.error ?? 'Login failed';
        print('❌ AuthService: Login failed: $errMsg');
        throw Exception(errMsg);
      }
    } catch (e) {
      print('❌ AuthService: Login error: $e');
      rethrow;
    }
  }
  
  /// Register user
  Future<bool> register(RegisterRequest request) async {
    try {
      print('🔐 AuthService: Register attempt');
      
      final response = await _authApiService.register(request);
      
      print('📦 AuthService: Register response received');
      print('📊 AuthService: Response success: ${response.success}');
      
      if (response.success && response.data != null) {
        await saveUser(response.data!.user.toJson());
        if (response.data!.token != null && response.data!.token!.isNotEmpty) {
          await saveToken(response.data!.token!);
          if (response.data!.refreshToken != null) {
            await saveRefreshToken(response.data!.refreshToken!);
          }
          if (response.data!.expiresAt != null) {
            await saveTokenExpiry(response.data!.expiresAt!);
          }
        }
        print('✅ AuthService: Register successful for: ${response.data!.user.name}');
        return true;
      }
      print('❌ AuthService: Register failed: ${response.message ?? response.error}');
      return false;
    } catch (e) {
      print('❌ AuthService: Register error: $e');
      return false;
    }
  }
  
  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      print('🔐 AuthService: Google sign in attempt');
      
      final response = await _authApiService.signInWithGoogle();
      
      print('📦 AuthService: Google sign in response received');
      print('📊 AuthService: Response success: ${response.success}');
      
      if (response.success && response.data != null) {
        await saveUser(response.data!.user.toJson());
        if (response.data!.token != null && response.data!.token!.isNotEmpty) {
          await saveToken(response.data!.token!);
          if (response.data!.refreshToken != null) {
            await saveRefreshToken(response.data!.refreshToken!);
          }
          if (response.data!.expiresAt != null) {
            await saveTokenExpiry(response.data!.expiresAt!);
          }
        }
        print('✅ AuthService: Google sign in successful for: ${response.data!.user.name}');
        return true;
      }
      print('❌ AuthService: Google sign in failed: ${response.message ?? response.error}');
      return false;
    } catch (e) {
      print('❌ AuthService: Google sign in error: $e');
      return false;
    }
  }
  
  /// Update user role
  Future<bool> updateRole(String role) async {
    try {
      print('🔄 AuthService: Update role attempt: $role');
      
      final user = await _authApiService.updateRole(role);
      await saveUser(user.toJson());
      print('✅ AuthService: Role updated successfully');
      return true;
    } catch (e) {
      print('❌ AuthService: Update role error: $e');
      return false;
    }
  }
  
  /// Refresh user data
  Future<bool> refreshUser() async {
    try {
      print('🔄 AuthService: Refresh user attempt');
      
      // Check if token exists first
      final token = await getToken();
      if (token == null || token.isEmpty) {
        print('❌ AuthService: No token found to refresh');
        return false;
      }
      
      final user = await _authApiService.getMe();
      await saveUser(user.toJson());
      print('✅ AuthService: User refreshed successfully');
      return true;
    } catch (e) {
      print('❌ AuthService: Refresh user error: $e');
      return false;
    }
  }
  
  /// Logout
  Future<void> logout() async {
    try {
      print('🚪 AuthService: Logout attempt');
      await _authApiService.logout();
    } catch (e) {
      print('⚠️ AuthService: Logout API error: $e');
    } finally {
      await _storage.delete(key: _keyUser);
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyTokenExpiry);
      _currentUser = null;
      print('✅ AuthService: Logout completed');
    }
  }
  
  /// Clear session
  Future<void> clearSession() async {
    await _storage.deleteAll();
    _currentUser = null;
    print('✅ AuthService: Session cleared');
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _keyToken);
    return token != null && token.isNotEmpty;
  }
  
  /// Get stored user
  Future<User?> getUser() async {
    try {
      final userJson = await _storage.read(key: _keyUser);
      if (userJson != null) {
        final Map<String, dynamic> userMap = Map<String, dynamic>.from(
          json.decode(userJson) as Map<String, dynamic>
        );
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('❌ AuthService: Error getting user: $e');
      return null;
    }
  }
  
  /// Debug method to check token
  Future<void> debugToken() async {
    final token = await getToken();
    print('🔍 DEBUG - Token exists: ${token != null}');
    if (token != null) {
      print('🔍 DEBUG - Token preview: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      print('🔍 DEBUG - Token length: ${token.length}');
    } else {
      print('🔍 DEBUG - No token found');
    }
  }
}