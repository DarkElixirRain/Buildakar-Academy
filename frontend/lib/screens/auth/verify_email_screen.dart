import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/widgets/splash_logo.dart';
import 'package:buildacad/services/api_service.dart';
import 'package:buildacad/providers/auth_provider.dart';
import 'package:buildacad/providers/theme_provider.dart';
import 'package:buildacad/core/widgets/app_card.dart';
import 'package:buildacad/core/widgets/app_button.dart';
import 'package:buildacad/core/widgets/app_error_banner.dart';
import 'package:buildacad/core/widgets/app_dialog.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());
  final ApiService _apiService = ApiService();

  bool _isVerifying = false;
  bool _isResending = false;
  String? _error;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _canResend = false;
    _resendCountdown = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _canResend = true;
        }
      });
      return _resendCountdown > 0;
    });
  }

  String get _enteredCode => _codeControllers.map((c) => c.text).join();

  void _onCodeChanged(int index, String value) {
    setState(() => _error = null);
    if (value.isNotEmpty && index < 5) {
      _codeFocusNodes[index + 1].requestFocus();
    }
    if (_enteredCode.length == 6) {
      _verifyEmail();
    }
  }

  Future<void> _verifyEmail() async {
    if (_enteredCode.length != 6) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final response = await _apiService.verifyEmail(
        widget.email,
        _enteredCode,
      );
      if (!mounted) return;

      if (response.success) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null;

        if (data != null && data['accessToken'] != null) {
          if (data['user'] != null) {
            await _apiService.saveUser(data['user'] as Map<String, dynamic>);
          }
          await _apiService.saveToken(data['accessToken'] as String);
          if (data['refreshToken'] != null) {
            await _apiService.saveRefreshToken(data['refreshToken'] as String);
          }
          if (data['accessTokenExpiresAt'] != null) {
            await _apiService.saveTokenExpiry(
              data['accessTokenExpiresAt'] as String,
            );
          }

          if (!mounted) return;
          await Provider.of<AuthProvider>(context, listen: false).loadUser();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          showAppSuccessDialog(
            context: context,
            title: 'Email Verified!',
            message:
                'Your email has been verified successfully. Please login to continue.',
            buttonText: 'Continue to Login',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          );
        }
      } else {
        setState(() {
          _error =
              response.message ??
              'Invalid verification code. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
      _error = null;
    });

    try {
      final response = await _apiService.resendVerification(widget.email);
      if (!mounted) return;

      if (response.success) {
        for (final c in _codeControllers) {
          c.clear();
        }
        _codeFocusNodes[0].requestFocus();
        _startResendCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _error = response.message ?? 'Failed to resend code.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final size = MediaQuery.of(context).size.width;
    final isSmallDevice = size < 375;
    final isTablet = size >= 768;
    final cardPadding = isSmallDevice
        ? 16.0
        : isTablet
        ? 32.0
        : 24.0;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(brightness),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: isSmallDevice ? 16 : 32,
            horizontal: 16,
          ),
          child: Column(
            children: [
              const SplashLogo(),
              const SizedBox(height: 32),
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(brightness),
                  fontSize: isSmallDevice ? 28 : 34,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Enter the 6-digit code sent to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(brightness),
                    fontSize: isSmallDevice ? 14 : 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getPrimaryColor(brightness),
                  fontSize: isSmallDevice ? 15 : 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              AppCard(
                padding: EdgeInsets.all(cardPadding),
                maxWidth: 480,
                borderRadius: 28,
                child: Column(
                  children: [
                    if (_error != null) AppErrorBanner(message: _error!),
                    Text(
                      'Verification Code',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(brightness),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 48,
                          height: 56,
                          child: TextField(
                            controller: _codeControllers[index],
                            focusNode: _codeFocusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextColor(brightness),
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkBackgroundElement
                                  : AppColors.lightBackgroundElement,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _error != null
                                      ? const Color(0xFFEF4444)
                                      : AppColors.getBackgroundSelectedColor(
                                          brightness,
                                        ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.getBackgroundSelectedColor(
                                    brightness,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.getPrimaryColor(brightness),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) => _onCodeChanged(index, value),
                            onEditingComplete: index < 5
                                ? () =>
                                      _codeFocusNodes[index + 1].requestFocus()
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      title: 'Verify Email',
                      onPressed: (_isVerifying || _enteredCode.length != 6)
                          ? null
                          : _verifyEmail,
                      isLoading: _isVerifying,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: TextStyle(
                            color: AppColors.getTextSecondaryColor(brightness),
                            fontSize: isSmallDevice ? 13 : 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _canResend && !_isResending
                              ? _resendCode
                              : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: _isResending
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _canResend
                                      ? 'Resend Code'
                                      : 'Resend in ${_resendCountdown}s',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _canResend
                                        ? AppColors.getPrimaryColor(brightness)
                                        : AppColors.getTextSecondaryColor(
                                            brightness,
                                          ),
                                    fontSize: isSmallDevice ? 13 : 14,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already verified? ',
                    style: TextStyle(
                      color: AppColors.getTextSecondaryColor(brightness),
                      fontSize: isSmallDevice ? 14 : 15,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.getPrimaryColor(brightness),
                        fontSize: isSmallDevice ? 14 : 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
