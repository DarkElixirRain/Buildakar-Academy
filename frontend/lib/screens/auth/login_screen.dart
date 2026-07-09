import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../widgets/splash_logo.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../models/auth_model.dart';

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
      _showErrorDialog('Login Failed', authProvider.error ?? 'Invalid email or password');
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

  void _handleForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  // Called by GoogleSignInButton once a Google sign-in has actually
  // completed and the backend has issued our own token — works the same
  // whether that happened via the native authenticate() flow or via
  // Google's web button + authenticationEvents.
  Future<void> _handleGoogleSignInSuccess(AuthResponse response) async {
    // ApiService already persisted the token/user to secure storage.
    // Refresh AuthProvider's in-memory state from that storage so the
    // rest of the app (e.g. isAuthenticated) reflects the new session.
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
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.width < 375;
    final isTablet = size.width >= 768;
    final cardPadding = isSmallDevice ? 16.0 : isTablet ? 32.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(brightness),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                        if (authProvider.error != null)
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
                                    authProvider.error!,
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
                        _buildEmailField(isDark),
                        _buildPasswordField(isDark),
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
                          child: _buildSignInButton(isDark, authProvider.isLoading),
                        ),
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
                                'or continue with',
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
                        GoogleSignInButton(
                          onSuccess: _handleGoogleSignInSuccess,
                          onError: _handleGoogleSignInError,
                          isDark: isDark,
                          isSmallDevice: isSmallDevice,
                        ),
                        const SizedBox(height: 12),
                        _buildAppleButton(isDark, isSmallDevice),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: AppColors.getTextSecondaryColor(brightness),
                            fontSize: isSmallDevice ? 14 : 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Create Account',
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
            if (authProvider.isLoading)
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
                        'Signing in...',
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

  Widget _buildEmailField(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Address',
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
                color: _emailError != null 
                    ? const Color(0xFFEF4444)
                    : AppColors.getBackgroundSelectedColor(brightness),
                width: _emailError != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: _emailError != null 
                        ? const Color(0xFFEF4444)
                        : AppColors.getTextSecondaryColor(brightness),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: AppColors.getTextColor(brightness),
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        color: AppColors.getTextSecondaryColor(brightness),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (text) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                    onSubmitted: (_) {
                      _passwordFocus.requestFocus();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_emailError != null)
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
                    _emailError!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password',
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
                color: _passwordError != null 
                    ? const Color(0xFFEF4444)
                    : AppColors.getBackgroundSelectedColor(brightness),
                width: _passwordError != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Icon(
                    Icons.lock_outlined,
                    size: 20,
                    color: _passwordError != null 
                        ? const Color(0xFFEF4444)
                        : AppColors.getTextSecondaryColor(brightness),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      color: AppColors.getTextColor(brightness),
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        color: AppColors.getTextSecondaryColor(brightness),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (text) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    onSubmitted: (_) {
                      _handleSignIn();
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _obscurePassword 
                        ? Icons.visibility_off_outlined 
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.getTextSecondaryColor(brightness),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  padding: const EdgeInsets.only(right: 8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          if (_passwordError != null)
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
                    _passwordError!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(bool isDark, bool isLoading) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final isEnabled = !isLoading;
    final primaryColor = AppColors.getPrimaryColor(brightness);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleSignIn : null,
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
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildAppleButton(bool isDark, bool isSmallDevice) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apple Sign-In coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark 
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white,
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
              Icons.apple,
              size: isSmallDevice ? 20 : 22,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Apple',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallDevice ? 13 : 15,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}