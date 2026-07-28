import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';
import 'google_button.dart';

class GoogleSignInButton extends StatefulWidget {
  final void Function(AuthResponse response) onSuccess;
  final void Function(Object error) onError;
  final bool isSmallDevice;

  const GoogleSignInButton({
    Key? key,
    required this.onSuccess,
    required this.onError,
    this.isSmallDevice = false,
  }) : super(key: key);

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final AuthService _authService = AuthService();
  bool _loading = false;

  Future<void> _handleSignIn() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final success = await _authService.signInWithGoogle();
      if (success) {
        final user = _authService.currentUser;
        if (user != null) {
          widget.onSuccess(AuthResponse(
            success: true,
            message: 'Google sign in successful',
            data: AuthData(user: user),
          ));
        } else {
          widget.onError(Exception('Failed to get user data'));
        }
      } else {
        widget.onError(Exception('Google sign-in failed'));
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
      isSmallDevice: widget.isSmallDevice,
    );
  }
}
