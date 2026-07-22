// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:buildacad/models/auth_model.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/splash_logo.dart';
import '../../widgets/google_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  final ApiService _apiService = ApiService();

  // Validation helpers
  String? _validateFirstName(String firstName) {
    if (firstName.isEmpty) return 'First name is required';
    if (firstName.length < 2) return 'First name must be at least 2 characters';
    return null;
  }

  String? _validateLastName(String lastName) {
    if (lastName.isEmpty) return 'Last name is required';
    if (lastName.length < 2) return 'Last name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String password) {
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

  Future<void> _handleSignUp() async {
    // Reset errors
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });

    // Validate all fields
    final firstNameErr = _validateFirstName(_firstNameController.text);
    final lastNameErr = _validateLastName(_lastNameController.text);
    final emailErr = _validateEmail(_emailController.text);
    final passErr = _validatePassword(_passwordController.text);
    final confirmPassErr = _validateConfirmPassword(
      _passwordController.text, 
      _confirmPasswordController.text
    );

    if (firstNameErr != null || lastNameErr != null || emailErr != null || 
        passErr != null || confirmPassErr != null) {
      setState(() {
        _firstNameError = firstNameErr;
        _lastNameError = lastNameErr;
        _emailError = emailErr;
        _passwordError = passErr;
        _confirmPasswordError = confirmPassErr;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create RegisterRequest with firstName and lastName
      final request = RegisterRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: 'STUDENT',
      );

      // Call the actual API to register
      final response = await _apiService.register(request);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response.success && response.data != null) {
        // Registration successful
        print('✅ Registration successful!');
        _showSuccessDialog();
      } else {
        // Registration failed - show the error message from the API
        print('❌ Registration failed: ${response.message}');
        
        // FIX: Check if message is not null before using contains
        if (response.message != null && response.message!.contains('Validation failed')) {
          setState(() {
            _generalError = 'Please check your input fields.';
          });
        } else {
          setState(() {
            _generalError = response.message ?? 'Registration failed. Please try again.';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      setState(() {
        _generalError = 'An error occurred: ${e.toString()}';
      });
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
            Text('Success!'),
          ],
        ),
        content: const Text(
          'Your account has been created successfully! Please login to continue.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Continue to Login',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _generalError = null;
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithGoogle();
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      // Navigate to home on success
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      setState(() {
        _generalError = 'Google sign-in failed: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final size = MediaQuery.of(context).size.width;
    final isSmallDevice = size < 375;
    final isTablet = size >= 768;
    final cardPadding = isSmallDevice ? 16.0 : isTablet ? 32.0 : 24.0;

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
              // Logo
              const SplashLogo(),
              const SizedBox(height: 32),

              // Title & Subtitle
              Text(
                'Create Account',
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
                  'Join Buildakar and start your high-performance learning journey today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(brightness),
                    fontSize: isSmallDevice ? 14 : 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Main Card Container
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
                child: Column(
                  children: [
                    // General Error
                    if (_generalError != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.red.withValues(alpha: 0.12)
                              : const Color(0xFFFEF2F2),
                          border: Border.all(
                            color: isDark 
                                ? Colors.red.withValues(alpha: 0.25)
                                : const Color(0xFFFECACA),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _generalError!,
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // First Name
                    CustomInput(
                      label: 'First Name',
                      placeholder: 'Enter your first name',
                      controller: _firstNameController,
                      error: _firstNameError,
                      prefixIcon: Icons.person_outline,
                      onChanged: () {
                        if (_firstNameError != null) {
                          setState(() => _firstNameError = null);
                        }
                      },
                      isDark: isDark,
                    ),

                    // Last Name
                    CustomInput(
                      label: 'Last Name',
                      placeholder: 'Enter your last name',
                      controller: _lastNameController,
                      error: _lastNameError,
                      prefixIcon: Icons.person_outline,
                      onChanged: () {
                        if (_lastNameError != null) {
                          setState(() => _lastNameError = null);
                        }
                      },
                      isDark: isDark,
                    ),

                    // Email
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

                    // Password
                    CustomInput(
                      label: 'Password',
                      placeholder: 'Create a strong password',
                      controller: _passwordController,
                      error: _passwordError,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      onToggleObscure: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onChanged: () {
                        if (_passwordError != null) {
                          setState(() => _passwordError = null);
                        }
                      },
                      isDark: isDark,
                      showPasswordRequirements: true,
                    ),

                    // Confirm Password
                    CustomInput(
                      label: 'Confirm Password',
                      placeholder: 'Confirm your password',
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

                    // Terms and Conditions
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: Text(
                        'By creating an account, you agree to our Terms of Service and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.getTextSecondaryColor(brightness),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Sign Up Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: CustomButton(
                        title: 'Create Account',
                        onPressed: _handleSignUp,
                        isLoading: _isLoading,
                        isDark: isDark,
                      ),
                    ),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.getBackgroundSelectedColor(brightness),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or sign up with',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.getTextSecondaryColor(brightness),
                              letterSpacing: 0.5,
                              fontSize: isSmallDevice ? 10 : 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.getBackgroundSelectedColor(brightness),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Google Sign Up
                    GoogleButton(
                      onPressed: _handleGoogleSignUp,
                      isLoading: _isLoading,
                      isDark: isDark,
                      isSmallDevice: isSmallDevice,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Apple Sign Up
                    SocialLoginButton(
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      color: isDark ? Colors.white : Colors.black,
                      backgroundColor: isDark 
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Apple Sign-Up coming soon!')),
                        );
                      },
                      isDark: isDark,
                      isSmallDevice: isSmallDevice,
                    ),
                  ],
                ),
              ),

              // Bottom Link to Login
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(brightness),
                        fontSize: isSmallDevice ? 14 : 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
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
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Input Widget with Password Requirements
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

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

// Custom Button Widget
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
    final brightness = MediaQuery.of(context).platformBrightness;
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

// Social Login Button Widget
class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isSmallDevice;

  const SocialLoginButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.backgroundColor,
    required this.onPressed,
    required this.isDark,
    required this.isSmallDevice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.getBackgroundElementColor(brightness),
          foregroundColor: AppColors.getTextColor(brightness),
          padding: EdgeInsets.symmetric(
            vertical: isSmallDevice ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: AppColors.getBackgroundSelectedColor(brightness),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmallDevice ? 20 : 22,
              color: color,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallDevice ? 13 : 15,
                color: AppColors.getTextColor(brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }
}