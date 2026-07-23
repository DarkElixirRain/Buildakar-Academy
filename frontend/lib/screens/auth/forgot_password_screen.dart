import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../widgets/splash_logo.dart'; 
import '../../providers/theme_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // State
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password
  
  // Errors
  String? _emailError;
  String? _otpError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  String? _generalError;
  
  // OTP Timer
  int _otpTimer = 60;
  bool _canResendOTP = false;
  Timer? _timer;
  
  // Validation helpers
  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) return 'Please enter a valid email address';
    return null;
  }

  String? _validateOTP(String otp) {
    if (otp.isEmpty) return 'OTP is required';
    if (otp.length < 6) return 'OTP must be 6 digits';
    if (!RegExp(r'^[0-9]+$').hasMatch(otp)) return 'OTP must contain only numbers';
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

  // Step 1: Send OTP
  Future<void> _sendOTP() async {
    setState(() {
      _emailError = null;
      _generalError = null;
    });

    final emailErr = _validateEmail(_emailController.text);
    if (emailErr != null) {
      setState(() => _emailError = emailErr);
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);

    // Simulate success
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

  // Step 2: Verify OTP
  Future<void> _verifyOTP() async {
    setState(() {
      _otpError = null;
      _generalError = null;
    });

    final otpErr = _validateOTP(_otpController.text);
    if (otpErr != null) {
      setState(() => _otpError = otpErr);
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);

    // Simulate success - always true for demo
    if (mounted) {
      setState(() {
        _currentStep = 2;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Step 3: Reset Password
  Future<void> _resetPassword() async {
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });

    final newPassErr = _validateNewPassword(_newPasswordController.text);
    final confirmPassErr = _validateConfirmPassword(
      _newPasswordController.text, 
      _confirmPasswordController.text
    );

    if (newPassErr != null || confirmPassErr != null) {
      setState(() {
        _newPasswordError = newPassErr;
        _confirmPasswordError = confirmPassErr;
      });
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);

    // Success
    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('Password Reset!'),
          ],
        ),
        content: const Text(
          'Your password has been successfully reset. You can now login with your new password.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Back to Login',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
    final cardPadding = isSmallDevice ? 16.0 : isTablet ? 32.0 : 24.0;

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
        child: Stack(
          children: [
            // Main Content
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: isSmallDevice ? 16 : 24,
                horizontal: 16,
              ),
              child: Column(
                children: [
                  // Logo
                  const SplashLogo(),
                  const SizedBox(height: 24),

                  // Progress Indicator
                  _buildProgressIndicator(isDark),
                  const SizedBox(height: 32),

                  // Step Content
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.darkBackgroundElement.withValues(alpha: 0.8)
                          : AppColors.lightBackgroundElement.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.grey.withValues(alpha: 0.1),
                          offset: const Offset(0, 8),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
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

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Please wait...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
            ? AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light)
            : isDark ? Colors.grey[800] : Colors.grey[300],
        border: Border.all(
          color: isActive 
              ? AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light)
              : isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
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
          ? AppColors.getPrimaryColor(isDark ? Brightness.dark : Brightness.light)
          : isDark ? Colors.grey[800] : Colors.grey[300],
    );
  }

  Widget _buildEmailStep(bool isDark, bool isSmallDevice) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    return Column(
      children: [
        // Icon
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.getPrimaryColor(brightness).withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.email_outlined,
            size: 32,
            color: AppColors.getPrimaryColor(brightness),
          ),
        ),
        const SizedBox(height: 20),

        // Title
        Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: isSmallDevice ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(brightness),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you an OTP to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallDevice ? 13 : 15,
            color: AppColors.getTextSecondaryColor(brightness),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Email Input
        CustomInput(
          label: 'Email Address',
          placeholder: 'Enter your email',
          controller: _emailController,
          error: _emailError,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          onChanged: () {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          isDark: isDark,
        ),

        const SizedBox(height: 8),

        // Send OTP Button
        CustomButton(
          title: 'Send OTP',
          onPressed: _sendOTP,
          isLoading: _isLoading,
          isDark: isDark,
        ),

        const SizedBox(height: 16),

        // Back to Login
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
              color: AppColors.getTextSecondaryColor(brightness),
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
        // Icon
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.getPrimaryColor(brightness).withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.security_outlined,
            size: 32,
            color: AppColors.getPrimaryColor(brightness),
          ),
        ),
        const SizedBox(height: 20),

        // Title
        Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: isSmallDevice ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(brightness),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit OTP to your email. Enter it below to verify.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallDevice ? 13 : 15,
            color: AppColors.getTextSecondaryColor(brightness),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // OTP Input
        CustomInput(
          label: 'OTP Code',
          placeholder: 'Enter 6-digit OTP',
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
          isDark: isDark,
        ),

        const SizedBox(height: 8),

        // Timer / Resend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _canResendOTP ? 'Didn\'t receive OTP?' : 'Resend in ${_otpTimer}s',
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

        // Verify Button
        CustomButton(
          title: 'Verify OTP',
          onPressed: _verifyOTP,
          isLoading: _isLoading,
          isDark: isDark,
        ),

        const SizedBox(height: 12),

        // Back button
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
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    return Column(
      children: [
        // Icon
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.getPrimaryColor(brightness).withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 32,
            color: AppColors.getPrimaryColor(brightness),
          ),
        ),
        const SizedBox(height: 20),

        // Title
        Text(
          'Reset Password',
          style: TextStyle(
            fontSize: isSmallDevice ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(brightness),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a new secure password for your account.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallDevice ? 13 : 15,
            color: AppColors.getTextSecondaryColor(brightness),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // New Password
        CustomInput(
          label: 'New Password',
          placeholder: 'Enter new password',
          controller: _newPasswordController,
          error: _newPasswordError,
          obscureText: _obscureNewPassword,
          prefixIcon: Icons.lock_outlined,
          onToggleObscure: () {
            setState(() => _obscureNewPassword = !_obscureNewPassword);
          },
          onChanged: () {
            if (_newPasswordError != null) {
              setState(() => _newPasswordError = null);
            }
          },
          isDark: isDark,
          showPasswordRequirements: true,
        ),

        // Confirm Password
        CustomInput(
          label: 'Confirm Password',
          placeholder: 'Confirm new password',
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
          isDark: isDark,
        ),

        const SizedBox(height: 16),

        // Reset Password Button
        CustomButton(
          title: 'Reset Password',
          onPressed: _resetPassword,
          isLoading: _isLoading,
          isDark: isDark,
        ),

        const SizedBox(height: 12),

        // Back button
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
                color: AppColors.getTextSecondaryColor(brightness),
              ),
              const SizedBox(width: 4),
              Text(
                'Back to OTP',
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
}

// Custom Input Widget (Reused from login)
class CustomInput extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final String? error;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final VoidCallback? onToggleObscure;
  final VoidCallback? onChanged;
  final bool isDark;
  final bool showPasswordRequirements;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInput({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.error,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.onToggleObscure,
    this.onChanged,
    required this.isDark,
    this.showPasswordRequirements = false,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(brightness),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.darkBackgroundElement
                  : AppColors.lightBackgroundElement,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: error != null 
                    ? const Color(0xFFEF4444)
                    : AppColors.getBackgroundSelectedColor(brightness),
                width: error != null ? 2 : 1,
              ),
              boxShadow: [
                if (error == null)
                  BoxShadow(
                    color: isDark 
                        ? Colors.transparent
                        : Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                if (prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Icon(
                      prefixIcon,
                      size: 20,
                      color: error != null 
                          ? const Color(0xFFEF4444)
                          : AppColors.getTextSecondaryColor(brightness),
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    style: TextStyle(
                      color: AppColors.getTextColor(brightness),
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: TextStyle(
                        color: AppColors.getTextSecondaryColor(brightness),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: prefixIcon != null ? 10 : 14,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (text) {
                      if (onChanged != null) onChanged!();
                    },
                  ),
                ),
                if (onToggleObscure != null)
                  IconButton(
                    icon: Icon(
                      obscureText 
                          ? Icons.visibility_off_outlined 
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.getTextSecondaryColor(brightness),
                    ),
                    onPressed: onToggleObscure,
                    padding: const EdgeInsets.only(right: 8),
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 14,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    error!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          if (showPasswordRequirements && controller.text.isNotEmpty && error == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  _buildRequirement(
                    'At least 8 characters',
                    controller.text.length >= 8,
                  ),
                  _buildRequirement(
                    'At least one uppercase letter',
                    RegExp(r'(?=.*[A-Z])').hasMatch(controller.text),
                  ),
                  _buildRequirement(
                    'At least one lowercase letter',
                    RegExp(r'(?=.*[a-z])').hasMatch(controller.text),
                  ),
                  _buildRequirement(
                    'At least one number',
                    RegExp(r'(?=.*\d)').hasMatch(controller.text),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Button Widget (Reused from login)
class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDark;

  const CustomButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final isEnabled = !isLoading;
    final primaryColor = AppColors.getPrimaryColor(brightness);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? primaryColor : AppColors.getTextSecondaryColor(brightness),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: isEnabled ? 4 : 0,
          shadowColor: isEnabled ? primaryColor.withValues(alpha: 0.3) : Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}