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
        print('✅ AuthProvider: User loaded: ${user.displayName}');
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
        _currentUser = await _authService.getUser();
        _error = null;
        print('✅ AuthProvider: Login successful for: ${_currentUser?.displayName}');
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
        _currentUser = await _authService.getUser();
        _error = null;
        print('✅ AuthProvider: Google sign in successful');
        notifyListeners();
        return true;
      } else {
        _error = 'Google sign in failed. Please try again.';
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
        _currentUser = await _authService.getUser();
        _error = null;
        print('✅ AuthProvider: Register successful');
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed. Please try again.';
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
      // Even if logout fails, clear local session
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
        _currentUser = await _authService.getUser();
        _error = null;
        print('✅ AuthProvider: Role updated successfully');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update role. Please try again.';
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
      
      // Check if we have a token first
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ AuthProvider: No token to refresh');
        _isLoading = false;
        _error = 'No session found. Please login again.';
        notifyListeners();
        return false;
      }
      
      final success = await _authService.refreshUser();
      
      if (success) {
        _currentUser = await _authService.getUser();
        _error = null;
        print('✅ AuthProvider: User refreshed successfully');
        notifyListeners();
        return true;
      } else {
        // If refresh failed, clear everything
        await _authService.clearSession();
        _currentUser = null;
        _error = 'Session expired. Please login again.';
        print('❌ AuthProvider: Refresh user failed - session cleared');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      _currentUser = null;
      print('❌ AuthProvider: Refresh user error: $e');
      await _authService.clearSession();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force logout (called when session expires from BaseApiService)
  /// This is called from BaseApiService.onSessionExpired callback
  void forceLogout() {
    print('🚨 AuthProvider: Force logout called - session expired');
    // Clear current user
    _currentUser = null;
    _error = 'Your session has expired. Please login again.';
    
    // Also clear tokens via AuthService
    _authService.clearSession().then((_) {
      print('✅ AuthProvider: Session cleared during force logout');
    }).catchError((e) {
      print('⚠️ AuthProvider: Error clearing session during force logout: $e');
    });
    
    notifyListeners();
  }

  /// Clear session (called during normal logout or session cleanup)
  Future<void> clearSession() async {
    try {
      print('🧹 AuthProvider: Clearing session');
      await _authService.clearSession();
      _currentUser = null;
      _error = null;
      notifyListeners();
      print('✅ AuthProvider: Session cleared successfully');
    } catch (e) {
      print('❌ AuthProvider: Error clearing session: $e');
      // Even if error, clear local state
      _currentUser = null;
      _error = 'Failed to clear session. Please try again.';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get user's display name (with fallback)
  String get displayName => _currentUser?.displayName ?? 'Student';

  /// Get user's initials (with fallback)
  String get initials => _currentUser?.initials ?? 'S';

  /// Get user's profile image URL
  String? get profileImage => _currentUser?.profileImage;

  /// Get user's email
  String? get email => _currentUser?.email;

  /// Get user's role
  String? get role => _currentUser?.role;

  /// Check if user has a specific role
  bool hasRole(String role) {
    return _currentUser?.role?.toLowerCase() == role.toLowerCase();
  }

  /// Check if user is instructor
  bool get isInstructor => hasRole('instructor') || hasRole('teacher');

  /// Check if user is student
  bool get isStudent => hasRole('student') || _currentUser?.role == null;

  /// Check if user is admin
  bool get isAdmin => hasRole('admin') || hasRole('administrator');

  /// Helper method to extract readable error messages
  String _getErrorMessage(Object error) {
    final errorString = error.toString();
    
    // Remove 'Exception: ' prefix if present
    String message = errorString.replaceFirst('Exception: ', '');
    
    // Handle specific error messages from backend
    if (message.toLowerCase().contains('invalid') || 
        message.toLowerCase().contains('incorrect')) {
      return 'Invalid email or password. Please try again.';
    } else if (message.toLowerCase().contains('not found')) {
      return 'User not found. Please check your email.';
    } else if (message.toLowerCase().contains('already exists') ||
               message.toLowerCase().contains('already used')) {
      return 'This email is already registered. Please login instead.';
    } else if (message.toLowerCase().contains('unauthorized')) {
      return 'Unauthorized. Please login again.';
    } else if (message.toLowerCase().contains('network') ||
               message.toLowerCase().contains('connection') ||
               message.toLowerCase().contains('timeout')) {
      return 'Network error. Please check your internet connection.';
    } else if (message.toLowerCase().contains('session expired')) {
      return 'Your session has expired. Please login again.';
    } else if (message.toLowerCase().contains('token')) {
      return 'Authentication error. Please login again.';
    } else if (message.toLowerCase().contains('password')) {
      return 'Invalid password. Please try again.';
    } else if (message.toLowerCase().contains('email')) {
      return 'Invalid email address. Please check and try again.';
    } else if (message.toLowerCase().contains('weak')) {
      return 'Password is too weak. Please use a stronger password.';
    } else if (message.toLowerCase().contains('required')) {
      return 'Please fill in all required fields.';
    }
    
    // Return a user-friendly message if error is long
    if (message.length > 100) {
      return 'An error occurred. Please try again.';
    }
    
    return message;
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}