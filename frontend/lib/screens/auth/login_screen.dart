import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../widgets/splash_logo.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../models/auth_model.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_error_banner.dart';
import '../../core/widgets/app_divider.dart';
import '../../core/widgets/app_bottom_auth_link.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!Validators.isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final emailErr = _validateEmail(_emailController.text);
    final passErr = _validatePassword(_passwordController.text);

    if (emailErr != null || passErr != null) {
      setState(() {
        _emailError = emailErr;
        _passwordError = passErr;
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome back!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      final errorMsg = authProvider.error ?? 'Invalid email or password';
      final isUnverified =
          errorMsg.toLowerCase().contains('verify') ||
          errorMsg.toLowerCase().contains('verified') ||
          errorMsg.toLowerCase().contains('not verified');
      if (isUnverified) {
        _showVerifyEmailDialog(errorMsg);
      } else {
        _showErrorDialog('Login Failed', errorMsg);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).clearError();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showVerifyEmailDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.email_outlined, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Email Not Verified'),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(
                context,
                '/verify-email',
                arguments: _emailController.text.trim(),
              );
            },
            child: const Text(
              'Verify Email',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  Future<void> _handleGoogleSignInSuccess(AuthResponse response) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUser();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/home');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In successful!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleGoogleSignInError(Object error) {
    if (!mounted) return;
    _showErrorDialog(
      'Google Sign-In Failed',
      'Unable to sign in with Google. Please try again.',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
                'Welcome Back!',
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
                  'Continue your high-performance learning journey with Buildakar.',
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
                    if (authProvider.error != null)
                      AppErrorBanner(message: authProvider.error!),
                    AppTextField(
                      label: 'Email Address',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      error: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      focusNode: _emailFocus,
                      textInputAction: TextInputAction.next,
                      onChanged: () {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                      onSubmitted: () {
                        _passwordFocus.requestFocus();
                      },
                    ),
                    AppTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      error: _passwordError,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      focusNode: _passwordFocus,
                      onToggleObscure: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onChanged: () {
                        if (_passwordError != null) {
                          setState(() => _passwordError = null);
                        }
                      },
                      onSubmitted: () {
                        _handleSignIn();
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 20),
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.getPrimaryColor(brightness),
                              fontSize: isSmallDevice ? 13 : 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: AppButton(
                        title: 'Sign In',
                        onPressed: _handleSignIn,
                        isLoading: authProvider.isLoading,
                      ),
                    ),
                    const OrDivider(text: 'or continue with'),
                    const SizedBox(height: 20),
                    GoogleSignInButton(
                      onSuccess: _handleGoogleSignInSuccess,
                      onError: _handleGoogleSignInError,
                      isDark: isDark,
                      isSmallDevice: isSmallDevice,
                    ),
                  ],
                ),
              ),
              AppBottomAuthLink(
                text: "Don't have an account?",
                linkText: 'Create Account',
                onLinkTap: () {
                  Navigator.pushReplacementNamed(context, '/signup');
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
