import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/core/widgets/app_button.dart';
import 'package:buildacad/core/widgets/app_text_field.dart';
import 'package:buildacad/core/widgets/app_divider.dart';
import 'package:buildacad/core/widgets/app_bottom_auth_link.dart';
import 'package:buildacad/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _emailError;
  String? _passError;
  String? _generalError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _emailError = _emailCtrl.text.isEmpty ? 'Email is required'
          : (!_emailCtrl.text.contains('@') ? 'Invalid email' : null);
      _passError = _passCtrl.text.isEmpty ? 'Password is required'
          : (_passCtrl.text.length < 6 ? 'Minimum 6 characters' : null);
    });
  }

  Future<void> _login() async {
    _validate();
    if (_emailError != null || _passError != null) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _generalError = auth.error ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: Column(
        children: [
          // Header illustration area
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryContainer],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Welcome Back',
                      style: AppTypography.displayLgMobile.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text('Sign in to continue learning',
                      style: AppTypography.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Form area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background(brightness),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -16, 0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_generalError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: AppRadius.mdAll,
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_generalError!, style: AppTypography.bodySm.copyWith(color: AppColors.error))),
                        ]),
                      ),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      error: _emailError,
                      prefix: const Icon(Icons.email_outlined, size: 20),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      controller: _passCtrl,
                      isPassword: true,
                      error: _passError,
                      prefix: const Icon(Icons.lock_outlined, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                        child: Text('Forgot Password?', style: AppTypography.bodySm.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w600,
                        )),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Log In',
                      loading: isLoading,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 24),
                    const OrDivider(),
                    const SizedBox(height: 24),
                    AppSocialButton(
                      label: 'Continue with Google',
                      icon: const Icon(Icons.g_mobiledata, size: 24, color: AppColors.error),
                      onPressed: () async {
                        final auth = context.read<AuthProvider>();
                        final success = await auth.signInWithGoogle();
                        if (success && mounted) Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),
                    const SizedBox(height: 24),
                    AppBottomAuthLink(
                      label: "Don't have an account? ",
                      actionText: 'Sign up',
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
