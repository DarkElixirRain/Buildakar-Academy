import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../widgets/splash_logo.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_loading_overlay.dart';
import '../../core/widgets/app_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

  String? _emailError;
  String? _otpError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  int _otpTimer = 60;
  bool _canResendOTP = false;
  Timer? _timer;

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateOTP(String otp) {
    if (otp.isEmpty) return 'OTP is required';
    if (otp.length < 6) return 'OTP must be 6 digits';
    if (!RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  String? _validateNewPassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return 'Please confirm your password';
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  Future<void> _sendOTP() async {
    setState(() {
      _emailError = null;
    });

    final emailErr = _validateEmail(_emailController.text);
    if (emailErr != null) {
      setState(() => _emailError = emailErr);
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      setState(() {
        _currentStep = 1;
        _otpTimer = 60;
        _canResendOTP = false;
        _startTimer();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your email!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _otpError = null;
    });

    final otpErr = _validateOTP(_otpController.text);
    if (otpErr != null) {
      setState(() => _otpError = otpErr);
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      setState(() => _currentStep = 2);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    final newPassErr = _validateNewPassword(_newPasswordController.text);
    final confirmPassErr = _validateConfirmPassword(
      _newPasswordController.text,
      _confirmPasswordController.text,
    );

    if (newPassErr != null || confirmPassErr != null) {
      setState(() {
        _newPasswordError = newPassErr;
        _confirmPasswordError = confirmPassErr;
      });
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      showAppSuccessDialog(
        context: context,
        title: 'Password Reset!',
        message:
            'Your password has been successfully reset. You can now login with your new password.',
        buttonText: 'Back to Login',
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpTimer > 0) {
        setState(() => _otpTimer--);
      } else {
        setState(() {
          _canResendOTP = true;
          _timer?.cancel();
        });
      }
    });
  }

  void _resendOTP() {
    setState(() {
      _otpTimer = 60;
      _canResendOTP = false;
      _otpController.clear();
    });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.width < 375;
    final isTablet = size.width >= 768;
    final cardPadding = isSmallDevice
        ? 16.0
        : isTablet
        ? 32.0
        : 24.0;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(brightness),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.getTextColor(brightness),
          ),
          onPressed: _goBack,
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: AppColors.getTextColor(brightness),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AppLoadingOverlay(
          isLoading: _isLoading,
          message: 'Please wait...',
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: isSmallDevice ? 16 : 24,
              horizontal: 16,
            ),
            child: Column(
              children: [
                const SplashLogo(),
                const SizedBox(height: 24),
                _buildProgressIndicator(isDark),
                const SizedBox(height: 32),
                AppCard(
                  padding: EdgeInsets.all(cardPadding),
                  maxWidth: 480,
                  child: _currentStep == 0
                      ? _buildEmailStep(isDark, isSmallDevice)
                      : _currentStep == 1
                      ? _buildOTPStep(isDark, isSmallDevice)
                      : _buildResetPasswordStep(isDark, isSmallDevice),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(0, isDark),
        _buildStepLine(isDark),
        _buildStepCircle(1, isDark),
        _buildStepLine(isDark),
        _buildStepCircle(2, isDark),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isDark) {
    final isActive = step <= _currentStep;
    final isCompleted = step < _currentStep;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppColors.getPrimaryColor(
                isDark ? Brightness.dark : Brightness.light,
              )
            : isDark
            ? Colors.grey[800]
            : Colors.grey[300],
        border: Border.all(
          color: isActive
              ? AppColors.getPrimaryColor(
                  isDark ? Brightness.dark : Brightness.light,
                )
              : isDark
              ? Colors.grey[700]!
              : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(bool isDark) {
    final isActive = _currentStep > 0;
    return Container(
      width: 40,
      height: 2,
      color: isActive
          ? AppColors.getPrimaryColor(
              isDark ? Brightness.dark : Brightness.light,
            )
          : isDark
          ? Colors.grey[800]
          : Colors.grey[300],
    );
  }

  Widget _buildStepIcon(IconData icon, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.getPrimaryColor(brightness).withValues(alpha: 0.1),
      ),
      child: Icon(icon, size: 32, color: AppColors.getPrimaryColor(brightness)),
    );
  }

  Widget _buildStepTitle(String title, bool isSmallDevice, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return Text(
      title,
      style: TextStyle(
        fontSize: isSmallDevice ? 22 : 26,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextColor(brightness),
      ),
    );
  }

  Widget _buildStepSubtitle(String subtitle, bool isSmallDevice, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isSmallDevice ? 13 : 15,
          color: AppColors.getTextSecondaryColor(brightness),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildEmailStep(bool isDark, bool isSmallDevice) {
    return Column(
      children: [
        _buildStepIcon(Icons.email_outlined, isDark),
        const SizedBox(height: 20),
        _buildStepTitle('Forgot Password?', isSmallDevice, isDark),
        const SizedBox(height: 8),
        _buildStepSubtitle(
          'Enter your email address and we\'ll send you an OTP to reset your password.',
          isSmallDevice,
          isDark,
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Email Address',
          hintText: 'Enter your email',
          controller: _emailController,
          error: _emailError,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          onChanged: () {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
        ),
        const SizedBox(height: 8),
        AppButton(
          title: 'Send OTP',
          onPressed: _sendOTP,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(
                isDark ? Brightness.dark : Brightness.light,
              ),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPStep(bool isDark, bool isSmallDevice) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return Column(
      children: [
        _buildStepIcon(Icons.security_outlined, isDark),
        const SizedBox(height: 20),
        _buildStepTitle('Verify OTP', isSmallDevice, isDark),
        const SizedBox(height: 8),
        _buildStepSubtitle(
          'We sent a 6-digit OTP to your email. Enter it below to verify.',
          isSmallDevice,
          isDark,
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'OTP Code',
          hintText: 'Enter 6-digit OTP',
          controller: _otpController,
          error: _otpError,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.pin_outlined,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: () {
            if (_otpError != null) {
              setState(() => _otpError = null);
            }
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _canResendOTP
                  ? 'Didn\'t receive OTP?'
                  : 'Resend in ${_otpTimer}s',
              style: TextStyle(
                color: AppColors.getTextSecondaryColor(brightness),
                fontSize: 14,
              ),
            ),
            if (_canResendOTP)
              TextButton(
                onPressed: _resendOTP,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: AppColors.getPrimaryColor(brightness),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AppButton(
          title: 'Verify OTP',
          onPressed: _verifyOTP,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _currentStep = 0),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back,
                size: 16,
                color: AppColors.getTextSecondaryColor(brightness),
              ),
              const SizedBox(width: 4),
              Text(
                'Back to Email',
                style: TextStyle(
                  color: AppColors.getTextSecondaryColor(brightness),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordStep(bool isDark, bool isSmallDevice) {
    return Column(
      children: [
        _buildStepIcon(Icons.lock_reset, isDark),
        const SizedBox(height: 20),
        _buildStepTitle('Reset Password', isSmallDevice, isDark),
        const SizedBox(height: 8),
        _buildStepSubtitle(
          'Create a new secure password for your account.',
          isSmallDevice,
          isDark,
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'New Password',
          hintText: 'Enter new password',
          controller: _newPasswordController,
          error: _newPasswordError,
          obscureText: _obscureNewPassword,
          prefixIcon: Icons.lock_outlined,
          showPasswordRequirements: true,
          onToggleObscure: () {
            setState(() => _obscureNewPassword = !_obscureNewPassword);
          },
          onChanged: () {
            if (_newPasswordError != null) {
              setState(() => _newPasswordError = null);
            }
          },
        ),
        AppTextField(
          label: 'Confirm Password',
          hintText: 'Confirm new password',
          controller: _confirmPasswordController,
          error: _confirmPasswordError,
          obscureText: _obscureConfirmPassword,
          prefixIcon: Icons.lock_outline,
          onToggleObscure: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
          onChanged: () {
            if (_confirmPasswordError != null) {
              setState(() => _confirmPasswordError = null);
            }
          },
        ),
        const SizedBox(height: 16),
        AppButton(
          title: 'Reset Password',
          onPressed: _resetPassword,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _currentStep = 1),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back,
                size: 16,
                color: AppColors.getTextSecondaryColor(
                  isDark ? Brightness.dark : Brightness.light,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Back to OTP',
                style: TextStyle(
                  color: AppColors.getTextSecondaryColor(
                    isDark ? Brightness.dark : Brightness.light,
                  ),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
