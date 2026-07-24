import 'package:flutter/material.dart';
import 'package:buildacad/models/auth_model.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/splash_logo.dart';
import '../../widgets/google_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_error_banner.dart';
import '../../core/widgets/app_divider.dart';
import '../../core/widgets/app_bottom_auth_link.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
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
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });

    final firstNameErr = _validateFirstName(_firstNameController.text);
    final lastNameErr = _validateLastName(_lastNameController.text);
    final emailErr = _validateEmail(_emailController.text);
    final passErr = _validatePassword(_passwordController.text);
    final confirmPassErr = _validateConfirmPassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (firstNameErr != null ||
        lastNameErr != null ||
        emailErr != null ||
        passErr != null ||
        confirmPassErr != null) {
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
      final request = RegisterRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: 'STUDENT',
      );

      final response = await _apiService.register(request);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response.success && response.data != null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/verify-email',
          arguments: _emailController.text.trim(),
        );
      } else {
        if (response.message != null &&
            response.message!.contains('Validation failed')) {
          setState(() => _generalError = 'Please check your input fields.');
        } else {
          setState(
            () => _generalError =
                response.message ?? 'Registration failed. Please try again.',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _generalError = 'An error occurred: ${e.toString()}';
      });
    }
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
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
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
              AppCard(
                padding: EdgeInsets.all(cardPadding),
                maxWidth: 480,
                child: Column(
                  children: [
                    if (_generalError != null)
                      AppErrorBanner(message: _generalError!),
                    AppTextField(
                      label: 'First Name',
                      hintText: 'Enter your first name',
                      controller: _firstNameController,
                      error: _firstNameError,
                      prefixIcon: Icons.person_outline,
                      onChanged: () {
                        if (_firstNameError != null) {
                          setState(() => _firstNameError = null);
                        }
                      },
                    ),
                    AppTextField(
                      label: 'Last Name',
                      hintText: 'Enter your last name',
                      controller: _lastNameController,
                      error: _lastNameError,
                      prefixIcon: Icons.person_outline,
                      onChanged: () {
                        if (_lastNameError != null) {
                          setState(() => _lastNameError = null);
                        }
                      },
                    ),
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
                    AppTextField(
                      label: 'Password',
                      hintText: 'Create a strong password',
                      controller: _passwordController,
                      error: _passwordError,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      showPasswordRequirements: true,
                      onToggleObscure: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onChanged: () {
                        if (_passwordError != null) {
                          setState(() => _passwordError = null);
                        }
                      },
                    ),
                    AppTextField(
                      label: 'Confirm Password',
                      hintText: 'Confirm your password',
                      controller: _confirmPasswordController,
                      error: _confirmPasswordError,
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outline,
                      onToggleObscure: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                      onChanged: () {
                        if (_confirmPasswordError != null) {
                          setState(() => _confirmPasswordError = null);
                        }
                      },
                    ),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: AppButton(
                        title: 'Create Account',
                        onPressed: _handleSignUp,
                        isLoading: _isLoading,
                      ),
                    ),
                    const OrDivider(text: 'or sign up with'),
                    const SizedBox(height: 20),
                    GoogleButton(
                      onPressed: _handleGoogleSignUp,
                      isLoading: _isLoading,
                      isDark: isDark,
                      isSmallDevice: isSmallDevice,
                    ),
                    const SizedBox(height: 12),
                    AppSocialButton(
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      iconColor: isDark ? Colors.white : Colors.black,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Apple Sign-Up coming soon!'),
                          ),
                        );
                      },
                      isSmallDevice: isSmallDevice,
                    ),
                  ],
                ),
              ),
              AppBottomAuthLink(
                text: 'Already have an account?',
                linkText: 'Sign In',
                onLinkTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
