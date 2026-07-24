import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/providers/auth_provider.dart';
import 'package:buildacad/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _soundEnabled = true;
  bool _autoPlay = false;
  bool _offlineMode = false;
  String _language = 'English';
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _autoPlay = prefs.getBool('autoplay') ?? false;
      _offlineMode = prefs.getBool('offline_mode') ?? false;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() => _language = language);
  }

  Future<void> _toggleTheme(bool value) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.setTheme(value);
  }

  bool _isWeb() {
    return identical(0, 0.0) ||
        Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS ||
        const bool.fromEnvironment('dart.library.js_util') ||
        const bool.fromEnvironment('dart.library.js');
  }

  bool _isIOS() => Platform.isIOS;

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
        title: Text('Logout', style: AppTypography.headlineSmMobile),
        content: Text('Are you sure you want to logout?',
            style: AppTypography.bodyMd.copyWith(
                color: AppColors.textOnSurface(Theme.of(ctx).brightness))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTypography.labelCaps.copyWith(
              color: AppColors.outline(Theme.of(ctx).brightness),
            )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: AppTypography.labelCaps.copyWith(
              color: AppColors.brandRed, fontWeight: FontWeight.w700,
            )),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoggingOut = true);
    await authProvider.logout();
    setState(() => _isLoggingOut = false);
  }

  Future<void> _handleClearCache(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
        title: Text('Clear Cache', style: AppTypography.headlineSmMobile),
        content: Text('This will clear all cached data. Are you sure?',
            style: AppTypography.bodyMd.copyWith(
                color: AppColors.textOnSurface(Theme.of(ctx).brightness))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTypography.labelCaps.copyWith(
              color: AppColors.outline(Theme.of(ctx).brightness),
            )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear', style: AppTypography.labelCaps.copyWith(
              color: AppColors.brandRed, fontWeight: FontWeight.w700,
            )),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cache cleared successfully', style: AppTypography.bodySm.copyWith(color: Colors.white)),
          backgroundColor: AppColors.brandGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to clear cache', style: AppTypography.bodySm.copyWith(color: Colors.white)),
          backgroundColor: AppColors.brandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ));
      }
    }
  }

  Future<void> _handleShareApp() async {
    try {
      await Share.share(
        'Check out BuildAcad - Learn. Build. Achieve.\n\nDownload now and start learning!',
        subject: 'Share BuildAcad',
      );
    } catch (_) {}
  }

  Future<void> _handleRateApp() async {
    final url = _isWeb()
        ? 'https://buildacad.com'
        : _isIOS()
            ? 'https://apps.apple.com/app/id123456789'
            : 'market://details?id=com.buildacad.app';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _handlePrivacyPolicy() async {
    final url = Uri.parse('https://buildacad.com/privacy');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _handleTermsOfService() async {
    final url = Uri.parse('https://buildacad.com/terms');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _handleHelpSupport() {
    showDialog(
      context: context,
      builder: (ctx) {
        final b = Theme.of(ctx).brightness;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
          title: Text('Help & Support', style: AppTypography.headlineSmMobile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _helpRow(Icons.email_outlined, 'support@buildacad.com', b),
              const SizedBox(height: 12),
              _helpRow(Icons.phone_outlined, '+1 (555) 123-4567', b),
              const SizedBox(height: 12),
              _helpRow(Icons.schedule_outlined, '9:00 AM - 6:00 PM (EST)', b),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: AppTypography.labelCaps.copyWith(
                color: AppColors.primary,
              )),
            ),
          ],
        );
      },
    );
  }

  Widget _helpRow(IconData icon, String text, Brightness b) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(text, style: AppTypography.bodySm.copyWith(
        color: AppColors.textOnSurfaceVariant(b),
      )),
    ]);
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final b = Theme.of(ctx).brightness;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
          title: Text('Send Feedback', style: AppTypography.headlineSmMobile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('We value your feedback!', style: AppTypography.bodySm.copyWith(
                color: AppColors.textOnSurfaceVariant(b),
              )),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant(b),
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: AppColors.border(b)),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write your feedback here...',
                    hintStyle: AppTypography.bodySm.copyWith(color: AppColors.outline(b)),
                    border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: AppTypography.bodyMd.copyWith(color: AppColors.textOnSurface(b)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTypography.labelCaps.copyWith(
                color: AppColors.outline(b),
              )),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Thank you for your feedback!',
                      style: AppTypography.bodySm.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.brandGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
              ),
              child: Text('Submit', style: AppTypography.labelCaps.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700,
              )),
            ),
          ],
        );
      },
    );
  }

  void _showReportProblemDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final b = Theme.of(ctx).brightness;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
          title: Text('Report a Problem', style: AppTypography.headlineSmMobile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Describe the problem you encountered:', style: AppTypography.bodySm.copyWith(
                color: AppColors.textOnSurfaceVariant(b),
              )),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant(b),
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: AppColors.border(b)),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe the issue...',
                    hintStyle: AppTypography.bodySm.copyWith(color: AppColors.outline(b)),
                    border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: AppTypography.bodyMd.copyWith(color: AppColors.textOnSurface(b)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTypography.labelCaps.copyWith(
                color: AppColors.outline(b),
              )),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Problem reported successfully!',
                      style: AppTypography.bodySm.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.brandGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
              ),
              child: Text('Submit', style: AppTypography.labelCaps.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700,
              )),
            ),
          ],
        );
      },
    );
  }

  void _showFAQDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final b = Theme.of(ctx).brightness;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
          title: Text('FAQ', style: AppTypography.headlineSmMobile),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _faqItem('Q: How do I enroll in a course?',
                    'A: Browse courses and click the "Enroll Now" button.'),
                const SizedBox(height: 12),
                _faqItem('Q: Can I access courses offline?',
                    'A: Yes, download courses for offline viewing in My Learning.'),
                const SizedBox(height: 12),
                _faqItem('Q: How do I get a certificate?',
                    'A: Complete all course requirements and pass the final exam.'),
                const SizedBox(height: 12),
                _faqItem('Q: What payment methods are accepted?',
                    'A: We accept credit cards, PayPal, and local payment methods.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: AppTypography.labelCaps.copyWith(
                color: AppColors.primary,
              )),
            ),
          ],
        );
      },
    );
  }

  Widget _faqItem(String q, String a) {
    final b = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(q, style: AppTypography.bodyMd.copyWith(
          fontWeight: FontWeight.w600, color: AppColors.textOnSurface(b),
        )),
        const SizedBox(height: 2),
        Text(a, style: AppTypography.bodySm.copyWith(
          color: AppColors.textOnSurfaceVariant(b),
        )),
      ],
    );
  }

  Future<void> _handleLanguageSelect() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final b = Theme.of(ctx).brightness;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
          title: Text('Select Language', style: AppTypography.headlineSmMobile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['English', 'Spanish', 'French', 'German', 'Chinese', 'Hindi'].map((lang) =>
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(lang, style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textOnSurface(b),
                )),
                trailing: _language == lang
                    ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                    : null,
                onTap: () => Navigator.pop(ctx, lang),
              ),
            ).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTypography.labelCaps.copyWith(
                color: AppColors.outline(b),
              )),
            ),
          ],
        );
      },
    );
    if (selected != null) await _saveLanguage(selected);
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final b = Theme.of(ctx).brightness;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
          title: Text('Delete Account', style: AppTypography.headlineSmMobile),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textOnSurfaceVariant(b),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: AppTypography.labelCaps.copyWith(
                color: AppColors.outline(b),
              )),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete', style: AppTypography.labelCaps.copyWith(
                color: AppColors.brandRed, fontWeight: FontWeight.w700,
              )),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      setState(() => _isLoggingOut = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoggingOut = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Account deleted successfully',
              style: AppTypography.bodySm.copyWith(color: Colors.white)),
          backgroundColor: AppColors.brandGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.user;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'user@email.com';
    final initials = user?.initials ?? 'U';
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text('Settings', style: AppTypography.headlineMdMobile.copyWith(
                  color: AppColors.textOnSurface(brightness),
                  fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 24),
                // Profile card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest(brightness),
                    borderRadius: AppRadius.cardAll,
                    border: Border.all(color: AppColors.border(brightness)),
                    boxShadow: AppShadow.card,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.surfaceVariant(brightness),
                        child: user?.profileImageUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user!.profileImageUrl!,
                                  width: 64, height: 64, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Text(initials,
                                      style: AppTypography.headlineMdMobile.copyWith(
                                        color: AppColors.primary, fontWeight: FontWeight.w700,
                                      )),
                                ),
                              )
                            : Text(initials, style: AppTypography.headlineMdMobile.copyWith(
                                color: AppColors.primary, fontWeight: FontWeight.w700,
                              )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: AppTypography.headlineSmMobile.copyWith(
                              color: AppColors.textOnSurface(brightness),
                              fontWeight: FontWeight.w700,
                            )),
                            const SizedBox(height: 2),
                            Text(email, style: AppTypography.bodySm.copyWith(
                              color: AppColors.outline(brightness),
                            )),
                            if (user?.role != null && user!.role.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                ),
                                child: Text(user!.displayRole, style: AppTypography.labelCaps.copyWith(
                                  color: AppColors.primary, fontSize: 10,
                                )),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Preferences
                _sectionHeader('PREFERENCES', brightness),
                const SizedBox(height: 8),
                _settingsGroup(brightness, [
                  _toggleItem(Icons.dark_mode_rounded, 'Dark Mode', isDarkMode, _toggleTheme, brightness),
                  _navItem(Icons.language_rounded, 'Language', subtitle: _language,
                      onTap: _handleLanguageSelect, brightness: brightness),
                  _toggleItem(Icons.notifications_rounded, 'Push Notifications', _notifications,
                      (v) { setState(() => _notifications = v); _savePreference('notifications', v); }, brightness),
                  _toggleItem(Icons.volume_up_rounded, 'Sound Effects', _soundEnabled,
                      (v) { setState(() => _soundEnabled = v); _savePreference('sound_enabled', v); }, brightness),
                  _toggleItem(Icons.play_circle_rounded, 'Auto-Play Videos', _autoPlay,
                      (v) { setState(() => _autoPlay = v); _savePreference('autoplay', v); }, brightness),
                  _toggleItem(Icons.cloud_download_rounded, 'Offline Mode', _offlineMode,
                      (v) { setState(() => _offlineMode = v); _savePreference('offline_mode', v); }, brightness),
                ]),
                const SizedBox(height: 20),
                // Account
                _sectionHeader('ACCOUNT', brightness),
                const SizedBox(height: 8),
                _settingsGroup(brightness, [
                  _navItem(Icons.person_outline_rounded, 'Edit Profile', brightness: brightness,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit Profile coming soon!')),
                      )),
                  _navItem(Icons.lock_outline_rounded, 'Change Password', brightness: brightness,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change Password coming soon!')),
                      )),
                  _navItem(Icons.payment_rounded, 'Payment Methods', brightness: brightness,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment Methods coming soon!')),
                      )),
                  _navItem(Icons.shield_outlined, 'Privacy & Security', brightness: brightness,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy & Security coming soon!')),
                      )),
                ]),
                const SizedBox(height: 20),
                // Support
                _sectionHeader('SUPPORT', brightness),
                const SizedBox(height: 8),
                _settingsGroup(brightness, [
                  _navItem(Icons.help_outline_rounded, 'Help & Support', brightness: brightness,
                      onTap: _handleHelpSupport),
                  _navItem(Icons.chat_bubble_outline_rounded, 'Send Feedback', brightness: brightness,
                      onTap: _showFeedbackDialog),
                  _navItem(Icons.flag_outlined, 'Report a Problem', brightness: brightness,
                      onTap: _showReportProblemDialog),
                  _navItem(Icons.info_outline_rounded, 'FAQ', brightness: brightness,
                      onTap: _showFAQDialog),
                ]),
                const SizedBox(height: 20),
                // App
                _sectionHeader('APP', brightness),
                const SizedBox(height: 8),
                _settingsGroup(brightness, [
                  _navItem(Icons.delete_outline_rounded, 'Clear Cache', brightness: brightness,
                      onTap: () => _handleClearCache(context), destructive: true),
                  _navItem(Icons.share_outlined, 'Share App', brightness: brightness,
                      onTap: _handleShareApp),
                  _navItem(Icons.star_outline_rounded, 'Rate App', brightness: brightness,
                      onTap: _handleRateApp),
                  _navItem(Icons.info_outline_rounded, 'About', brightness: brightness,
                      onTap: () => _handleAbout(brightness)),
                ]),
                const SizedBox(height: 20),
                // Legal
                _sectionHeader('LEGAL', brightness),
                const SizedBox(height: 8),
                _settingsGroup(brightness, [
                  _navItem(Icons.description_outlined, 'Privacy Policy', brightness: brightness,
                      onTap: _handlePrivacyPolicy),
                  _navItem(Icons.article_outlined, 'Terms of Service', brightness: brightness,
                      onTap: _handleTermsOfService),
                ]),
                const SizedBox(height: 24),
                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoggingOut ? null : () => _handleLogout(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.brandRed, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                    ),
                    child: _isLoggingOut
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandRed),
                              ),
                              const SizedBox(width: 8),
                              Text('Logging out...', style: AppTypography.labelCaps.copyWith(
                                color: AppColors.brandRed, fontWeight: FontWeight.w700,
                              )),
                            ],
                          )
                        : Text('Log Out', style: AppTypography.labelCaps.copyWith(
                            color: AppColors.brandRed, fontWeight: FontWeight.w700,
                          )),
                  ),
                ),
                const SizedBox(height: 12),
                // Delete account
                Center(
                  child: TextButton(
                    onPressed: () => _handleDeleteAccount(context),
                    child: Text('Delete Account', style: AppTypography.bodySm.copyWith(
                      color: AppColors.outline(brightness),
                      decoration: TextDecoration.underline,
                    )),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text('Version 1.0.0', style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline(brightness),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Brightness b) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(title, style: AppTypography.labelCaps.copyWith(
        color: AppColors.outline(b), fontWeight: FontWeight.w700,
      )),
    );
  }

  Widget _settingsGroup(Brightness b, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(b),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.border(b)),
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleItem(IconData icon, String label, bool value, ValueChanged<bool> onChanged, Brightness brightness) {
    final b = brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border(b), width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: AppTypography.bodyMd.copyWith(
            color: AppColors.textOnSurface(b),
          ))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.outline(b),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {String? subtitle, VoidCallback? onTap,
    required Brightness brightness, bool destructive = false}) {
    final b = brightness;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border(b), width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: destructive ? AppColors.brandRed : AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodyMd.copyWith(
                  color: destructive ? AppColors.brandRed : AppColors.textOnSurface(b),
                )),
                if (subtitle != null) Text(subtitle, style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(b), fontSize: 12,
                )),
              ],
            )),
            Icon(Icons.chevron_right_rounded,
              color: AppColors.outline(b), size: 22),
          ],
        ),
      ),
    );
  }

  void _handleAbout(Brightness b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
        title: Text('About BuildAcad', style: AppTypography.headlineSmMobile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.mdAll,
              ),
              child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text('BuildAcad', style: AppTypography.headlineMdMobile.copyWith(
              fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 4),
            Text('Learn. Build. Achieve.', style: AppTypography.bodySm.copyWith(
              color: AppColors.outline(b),
            )),
            const SizedBox(height: 8),
            Text('Version 1.0.0', style: AppTypography.bodySm.copyWith(
              color: AppColors.outline(b),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: AppTypography.labelCaps.copyWith(
              color: AppColors.primary,
            )),
          ),
        ],
      ),
    );
  }
}
