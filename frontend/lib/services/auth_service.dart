// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_model.dart';
import 'base_api_service.dart';
import '../types/api_response.dart';

// AuthApiService - Handles API calls for authentication
class AuthApiService extends BaseApiService {
  // Login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      print('🔐 AuthApiService: Login request started');
      final response = await post(
        '/auth/login',
        data: request.toJson(),
      );
      print('📦 AuthApiService: Login response received');
      print('📊 AuthApiService: Response data: ${response.data}');
      
      if (response.data == null) {
        print('❌ AuthApiService: Response data is null');
        throw Exception('No data received from server');
      }
      
      return AuthResponse.fromJson(response.data);
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
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final response = await post('/auth/google');
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await post('/auth/logout');
    } catch (e) {
      // Ignore logout errors
    }
  }

  // Get current user
  Future<User> getMe() async {
    try {
      final response = await get('/auth/me');
      print('📊 getMe response: ${response.data}');
      return User.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Update role
  Future<User> updateRole(String role) async {
    try {
      final response = await put(
        '/auth/role',
        data: {'role': role},
      );
      return User.fromJson(response.data['data']);
    } catch (e) {
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
      print('📊 AuthService: Response data: ${response.data}');
      
      if (response.success && response.data != null) {
        print('👤 AuthService: User data: ${response.data!.user.toJson()}');
        await saveUser(response.data!.user.toJson());
        
        if (response.data!.token != null) {
          print('🔑 AuthService: Token: ${response.data!.token}');
          await saveToken(response.data!.token!);
        } else {
          print('⚠️ AuthService: No token received');
        }
        
        print('✅ AuthService: Login successful for: ${response.data!.user.name}');
        return true;
      } else {
        print('❌ AuthService: Login failed: ${response.message ?? response.error}');
        return false;
      }
    } catch (e) {
      print('❌ AuthService: Login error: $e');
      return false;
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
        if (response.data!.token != null) {
          await saveToken(response.data!.token!);
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
        if (response.data!.token != null) {
          await saveToken(response.data!.token!);
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
      if (user != null) {
        await saveUser(user.toJson());
        print('✅ AuthService: Role updated successfully');
        return true;
      }
      print('❌ AuthService: Update role failed');
      return false;
    } catch (e) {
      print('❌ AuthService: Update role error: $e');
      return false;
    }
  }
  
  /// Refresh user data
  Future<bool> refreshUser() async {
    try {
      print('🔄 AuthService: Refresh user attempt');
      
      final user = await _authApiService.getMe();
      if (user != null) {
        await saveUser(user.toJson());
        print('✅ AuthService: User refreshed successfully');
        return true;
      }
      print('❌ AuthService: Refresh user failed');
      return false;
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
}