import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/core/widgets/app_button.dart';
import 'package:buildacad/core/widgets/app_text_field.dart';
import 'package:buildacad/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose(); _codeCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() { _loading = true; _error = null; });
    try {
      final service = AuthService();
      await service.sendVerificationCode(_emailCtrl.text.trim());
      setState(() => _step = 2);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeCtrl.text.length < 6) { setState(() => _error = 'Enter the 6-digit code'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      setState(() => _step = 3);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_passCtrl.text.length < 8) { setState(() => _error = 'Minimum 8 characters'); return; }
    if (_passCtrl.text != _confirmCtrl.text) { setState(() => _error = 'Passwords do not match'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final service = AuthService();
      await service.resetPassword(_emailCtrl.text.trim(), _codeCtrl.text, _passCtrl.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _step > 1 ? () => setState(() => _step--) : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(_step == 1 ? 'Forgot Password' : _step == 2 ? 'Verify Code' : 'New Password',
                style: AppTypography.headlineMd.copyWith(color: AppColors.textOnSurface(brightness)),
              ),
              const SizedBox(height: 8),
              Text(
                _step == 1 ? 'Enter your email to receive a reset code'
                    : _step == 2 ? 'Enter the 6-digit code sent to your email'
                    : 'Create a new password',
                style: AppTypography.bodyMd.copyWith(color: AppColors.textOnSurfaceVariant(brightness)),
              ),
              const SizedBox(height: 32),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.error)),
                ),
                const SizedBox(height: 16),
              ],
              if (_step == 1) ...[
                AppTextField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 24),
                AppButton(label: 'Send Code', loading: _loading, onPressed: _sendCode),
              ] else if (_step == 2) ...[
                AppTextField(label: 'Verification Code', controller: _codeCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                AppButton(label: 'Verify', loading: _loading, onPressed: _verifyCode),
              ] else ...[
                AppTextField(label: 'New Password', controller: _passCtrl, isPassword: true),
                const SizedBox(height: 16),
                AppTextField(label: 'Confirm Password', controller: _confirmCtrl, isPassword: true),
                const SizedBox(height: 24),
                AppButton(label: 'Reset Password', loading: _loading, onPressed: _resetPassword),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
