// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get user => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadUser();
  }

  /// Load user from secure storage
  Future<bool> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('🔄 AuthProvider: Loading user...');
      final user = await _authService.getUser();
      if (user != null) {
        _currentUser = user;
        _error = null;
        print('✅ AuthProvider: User loaded: ${user.name}');
        notifyListeners();
        return true;
      }
      print('ℹ️ AuthProvider: No user found');
      _currentUser = null;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _getErrorMessage(e);
      _currentUser = null;
      print('❌ AuthProvider: Load user error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 AuthProvider: Login attempt for: $email');
      final success = await _authService.login(email, password);
      
      if (success) {
        _currentUser = _authService.currentUser;
        _error = null;
        print('✅ AuthProvider: Login successful for: ${_currentUser?.name}');
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed. Please check your credentials.';
        print('❌ AuthProvider: Login failed');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('❌ AuthProvider: Login error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 AuthProvider: Google sign in attempt');
      final success = await _authService.signInWithGoogle();
      
      if (success) {
        _currentUser = _authService.currentUser;
        _error = null;
        print('✅ AuthProvider: Google sign in successful');
        notifyListeners();
        return true;
      } else {
        _error = 'Google sign in failed';
        print('❌ AuthProvider: Google sign in failed');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('❌ AuthProvider: Google sign in error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user
  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 AuthProvider: Register attempt for: ${request.email}');
      final success = await _authService.register(request);
      
      if (success) {
        _currentUser = _authService.currentUser;
        _error = null;
        print('✅ AuthProvider: Register successful');
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        print('❌ AuthProvider: Register failed');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('❌ AuthProvider: Register error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🚪 AuthProvider: Logout attempt');
      await _authService.logout();
      _currentUser = null;
      _error = null;
      print('✅ AuthProvider: Logout successful');
    } catch (e) {
      _error = _getErrorMessage(e);
      print('❌ AuthProvider: Logout error: $e');
      await _authService.clearSession();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user role
  Future<bool> updateRole(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 AuthProvider: Update role attempt: $role');
      final success = await _authService.updateRole(role);
      
      if (success) {
        _currentUser = _authService.currentUser;
        _error = null;
        print('✅ AuthProvider: Role updated successfully');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update role';
        print('❌ AuthProvider: Update role failed');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('❌ AuthProvider: Update role error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user data from server
  Future<bool> refreshUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 AuthProvider: Refresh user attempt');
      final success = await _authService.refreshUser();
      
      if (success) {
        _currentUser = _authService.currentUser;
        _error = null;
        print('✅ AuthProvider: User refreshed successfully');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to refresh user';
        print('❌ AuthProvider: Refresh user failed');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('❌ AuthProvider: Refresh user error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get user's display name (with fallback)
  String get displayName => _currentUser?.name ?? 'Student';

  /// Get user's initials (with fallback)
  String get initials {
    final name = _currentUser?.name ?? 'Student';
    if (name.isEmpty) return 'S';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  /// Get user's profile image URL
  String? get profileImage => _currentUser?.profileImage;

  /// Get user's email
  String? get email => _currentUser?.email;

  /// Get user's role
  String? get role => _currentUser?.role;

  /// Helper method to extract readable error messages
  String _getErrorMessage(Object error) {
    final errorString = error.toString();
    
    // Remove 'Exception: ' prefix if present
    String message = errorString.replaceFirst('Exception: ', '');
    
    // Handle specific error messages from backend
    if (message.toLowerCase().contains('invalid')) {
      return 'Invalid email or password';
    } else if (message.toLowerCase().contains('not found')) {
      return 'User not found';
    } else if (message.toLowerCase().contains('already')) {
      return 'User already exists';
    } else if (message.toLowerCase().contains('unauthorized')) {
      return 'Unauthorized. Please login again.';
    } else if (message.toLowerCase().contains('network')) {
      return 'Network error. Please check your connection.';
    }
    
    return message;
  }
}