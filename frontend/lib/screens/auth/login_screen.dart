import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
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
import '../../theme/stitch_colors.dart';
import '../../theme/stitch_theme.dart';

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
    if (!Validators.isValidEmail(email)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Future<void> _handleSignIn() async {
    setState(() { _emailError = null; _passwordError = null; });

    final emailErr = _validateEmail(_emailController.text);
    final passErr = _validatePassword(_passwordController.text);

    if (emailErr != null || passErr != null) {
      setState(() { _emailError = emailErr; _passwordError = passErr; });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      final errorMsg = authProvider.error ?? 'Invalid email or password';
      if (errorMsg.toLowerCase().contains('verify') || errorMsg.toLowerCase().contains('verified')) {
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
        title: Text(title),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            Icon(Icons.email_outlined, color: StitchColors.warningLight, size: 28),
            SizedBox(width: 12),
            Text('Email Not Verified'),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/verify-email', arguments: _emailController.text.trim());
            },
            child: const Text('Verify Email', style: TextStyle(fontWeight: FontWeight.bold)),
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
  }

  void _handleGoogleSignInError(Object error) {
    if (!mounted) return;
    _showErrorDialog('Google Sign-In Failed', 'Unable to sign in with Google. Please try again.');
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
    final brightness = Theme.of(context).brightness;
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.width < 375;
    final isTablet = size.width >= 768;

    return Scaffold(
      backgroundColor: StitchColors.surface(brightness),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Logo
              Container(
                width: 72,
                height: 72,
                child: Image.asset(
                  'assets/favicon.png',
                  width: 56, height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.school, size: 48, color: StitchColors.primary(brightness),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome Back!',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w700,
                  color: StitchColors.textPrimary(brightness),
                  fontSize: isSmallDevice ? 28 : 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Continue your learning journey with BuildAcad.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: StitchColors.textSecondary(brightness),
                  fontSize: isSmallDevice ? 14 : 16,
                ),
              ),
              const SizedBox(height: 32),
              AppCard(
                padding: EdgeInsets.all(isSmallDevice ? 16 : isTablet ? 32 : 24),
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
                      onChanged: () { if (_emailError != null) setState(() => _emailError = null); },
                      onSubmitted: () => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      error: _passwordError,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      focusNode: _passwordFocus,
                      onToggleObscure: () { setState(() => _obscurePassword = !_obscurePassword); },
                      onChanged: () { if (_passwordError != null) setState(() => _passwordError = null); },
                      onSubmitted: () => _handleSignIn(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: StitchColors.primary(brightness),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppButton(
                      title: 'Sign In',
                      onPressed: _handleSignIn,
                      isLoading: authProvider.isLoading,
                    ),
                    const SizedBox(height: 24),
                    const OrDivider(text: 'or continue with'),
                    const SizedBox(height: 20),
                    GoogleSignInButton(
                      onSuccess: _handleGoogleSignInSuccess,
                      onError: _handleGoogleSignInError,
                      isSmallDevice: isSmallDevice,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppBottomAuthLink(
                text: "Don't have an account?",
                linkText: 'Create Account',
                onLinkTap: () => Navigator.pushReplacementNamed(context, '/signup'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
