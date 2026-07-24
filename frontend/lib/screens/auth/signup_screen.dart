import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/core/widgets/app_button.dart';
import 'package:buildacad/core/widgets/app_text_field.dart';
import 'package:buildacad/core/widgets/app_divider.dart';
import 'package:buildacad/core/widgets/app_bottom_auth_link.dart';
import 'package:buildacad/providers/auth_provider.dart';
import 'package:buildacad/models/auth_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _generalError;

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    setState(() => _generalError = null);
    if (_firstCtrl.text.trim().length < 2) { setState(() => _generalError = 'First name is required'); return; }
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) { setState(() => _generalError = 'Valid email is required'); return; }
    if (_passCtrl.text.length < 8) { setState(() => _generalError = 'Password must be at least 8 characters'); return; }
    if (_passCtrl.text != _confirmCtrl.text) { setState(() => _generalError = 'Passwords do not match'); return; }

    final auth = context.read<AuthProvider>();
    final request = RegisterRequest(
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    final success = await auth.register(request);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/verify-email', arguments: _emailCtrl.text.trim());
    } else {
      setState(() => _generalError = auth.error ?? 'Registration failed');
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
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
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
                    Text('Create Account', style: AppTypography.displayLgMobile.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Start your learning journey', style: AppTypography.bodyMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    )),
                  ],
                ),
              ),
            ),
          ),
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
                        child: Text(_generalError!, style: AppTypography.bodySm.copyWith(color: AppColors.error)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(children: [
                      Expanded(child: AppTextField(label: 'First Name', controller: _firstCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: AppTextField(label: 'Last Name', controller: _lastCtrl)),
                    ]),
                    const SizedBox(height: 16),
                    AppTextField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    AppTextField(label: 'Password', controller: _passCtrl, isPassword: true),
                    const SizedBox(height: 16),
                    AppTextField(label: 'Confirm Password', controller: _confirmCtrl, isPassword: true),
                    const SizedBox(height: 24),
                    AppButton(label: 'Sign Up', loading: isLoading, onPressed: _signup),
                    const SizedBox(height: 24),
                    const OrDivider(),
                    const SizedBox(height: 24),
                    AppSocialButton(
                      label: 'Continue with Google',
                      icon: const Icon(Icons.g_mobiledata, size: 24, color: AppColors.error),
                      onPressed: () async {
                        final auth = context.read<AuthProvider>();
                        final s = await auth.signInWithGoogle();
                        if (s && mounted) Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),
                    const SizedBox(height: 24),
                    AppBottomAuthLink(
                      label: 'Already have an account? ',
                      actionText: 'Sign in',
                      onTap: () => Navigator.pop(context),
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
