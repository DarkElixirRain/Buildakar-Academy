import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../services/api_service.dart';
import 'google_button.dart';

/// A Google Sign-In button that uses dummy implementation for now.
/// TODO: Replace with actual Google Sign-In when ready
class GoogleSignInButton extends StatefulWidget {
  final void Function(AuthResponse response) onSuccess;
  final void Function(Object error) onError;
  final bool isDark;
  final bool isSmallDevice;

  const GoogleSignInButton({
    Key? key,
    required this.onSuccess,
    required this.onError,
    this.isDark = false,
    this.isSmallDevice = false,
  }) : super(key: key);

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final ApiService _apiService = ApiService();
  bool _loading = false;

  Future<void> _handleSignIn() async {
    // Don't allow multiple sign-in attempts
    if (_loading) return;
    
    setState(() => _loading = true);
    
    try {
      // Call the dummy sign-in method
      final result = await _apiService.signInWithGoogle();
      
      // Check if the result was successful
      if (result.success) {
        widget.onSuccess(result);
      } else {
        widget.onError(Exception(result.message ?? 'Google sign-in failed'));
      }
    } catch (e) {
      widget.onError(e);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleButton(
      onPressed: _handleSignIn,
      isLoading: _loading,
      isDark: widget.isDark,
      isSmallDevice: widget.isSmallDevice,
    );
  }
}