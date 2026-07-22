// lib/screens/settings/settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buildacad/models/auth_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

// Types
enum SettingItemType {
  toggle,
  button,
  link,
  navigation,
}

class SettingItem {
  final String id;
  final IconData icon;
  final String label;
  final dynamic value;
  final SettingItemType type;
  final VoidCallback? onPress;
  final ValueChanged<bool>? onToggle;
  final bool destructive;
  final String? badge;

  SettingItem({
    required this.id,
    required this.icon,
    required this.label,
    this.value,
    required this.type,
    this.onPress,
    this.onToggle,
    this.destructive = false,
    this.badge,
  });
}

class SettingsSection {
  final String id;
  final String title;
  final List<SettingItem> items;

  SettingsSection({
    required this.id,
    required this.title,
    required this.items,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables
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
    setState(() {
      _language = language;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.setTheme(value);
  }

  // Helper to check if running on web
  bool _isWeb() {
    return identical(0, 0.0) || 
           Platform.isWindows || 
           Platform.isLinux || 
           Platform.isMacOS ||
           const bool.fromEnvironment('dart.library.js_util') ||
           const bool.fromEnvironment('dart.library.js');
  }

  // Helper to check if running on iOS
  bool _isIOS() {
    return Platform.isIOS;
  }

  // Clear localStorage for web
  Future<void> _clearWebCache() async {
    const isWeb = identical(0, 0.0);
    if (!isWeb) return;
    
    try {
      // ignore: undefined_prefixed_name
      final html = await _getHtmlLibrary();
      if (html != null) {
        // ignore: avoid_dynamic_calls
        final localStorage = html.window.localStorage;
        if (localStorage != null) {
          // ignore: avoid_dynamic_calls
          localStorage.clear();
          debugPrint('✅ Web localStorage cleared');
        }
      }
    } catch (e) {
      debugPrint('❌ Error clearing web localStorage: $e');
    }
  }

  // Helper to dynamically get html library
  Future<dynamic> _getHtmlLibrary() async {
    if (!identical(0, 0.0)) return null;
    
    try {
      final html = await Future.delayed(const Duration(milliseconds: 1), () {
        return null;
      });
      return html;
    } catch (e) {
      return null;
    }
  }

  // Logout handler
  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_isWeb()) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );
      
      if (confirm != true) return;
      
      setState(() => _isLoggingOut = true);
      await authProvider.logout();
      setState(() => _isLoggingOut = false);
      return;
    }

    // Native platforms
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoggingOut = true);
              await authProvider.logout();
              setState(() => _isLoggingOut = false);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Clear cache handler
  Future<void> _handleClearCache(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (_isWeb()) {
        await _clearWebCache();
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Share app handler
  Future<void> _handleShareApp() async {
    try {
      await Share.share(
        'Check out this amazing learning platform! 🚀\n\n'
        'Download now and start learning: [App Link]',
        subject: 'Share Learning Platform',
      );
    } catch (e) {
      debugPrint('Error sharing app: $e');
    }
  }

  // Rate app handler
  Future<void> _handleRateApp() async {
    final url = _isWeb()
        ? 'https://your-website.com'
        : _isIOS()
            ? 'https://apps.apple.com/app/id123456789'
            : 'market://details?id=com.yourapp.learning';
    
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Privacy policy handler
  Future<void> _handlePrivacyPolicy() async {
    final Uri url = Uri.parse('https://your-website.com/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // Terms of service handler
  Future<void> _handleTermsOfService() async {
    final Uri url = Uri.parse('https://your-website.com/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // Cookie policy handler
  Future<void> _handleCookiePolicy() async {
    final Uri url = Uri.parse('https://your-website.com/cookies');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // Help & support handler
  void _handleHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: support@buildacad.com'),
            SizedBox(height: 8),
            Text('📱 Phone: +1 (555) 123-4567'),
            SizedBox(height: 8),
            Text('🕐 Hours: 9:00 AM - 6:00 PM (EST)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // About handler
  void _handleAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About LearnHub'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 48, color: Colors.blue),
            SizedBox(height: 12),
            Text(
              'LearnHub',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Your gateway to quality education',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Built with ❤️',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Language selection handler
  Future<void> _handleLanguageSelect() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Spanish'),
            _buildLanguageOption('French'),
            _buildLanguageOption('German'),
            _buildLanguageOption('Chinese'),
            _buildLanguageOption('Hindi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null) {
      await _saveLanguage(selected);
    }
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _language == language ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () => Navigator.pop(context, language),
    );
  }

  // Check updates handler
  Future<void> _handleCheckUpdates(BuildContext context) async {
    if (_isWeb()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updates are available automatically on web'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are using the latest version'),
      ),
    );
  }

  // Delete account handler
  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoggingOut = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoggingOut = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Build settings sections with isDarkMode parameter
  List<SettingsSection> _buildSections(BuildContext context, bool isDarkMode) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAuthenticated = authProvider.isAuthenticated;

    return [
      SettingsSection(
        id: 'preferences',
        title: 'Preferences',
        items: [
          SettingItem(
            id: 'theme',
            icon: isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
            label: 'Dark Mode',
            type: SettingItemType.toggle,
            value: isDarkMode,
            onToggle: _toggleTheme,
          ),
          SettingItem(
            id: 'language',
            icon: Icons.language,
            label: 'Language',
            value: _language,
            type: SettingItemType.button,
            onPress: _handleLanguageSelect,
          ),
          SettingItem(
            id: 'notifications',
            icon: Icons.notifications,
            label: 'Push Notifications',
            type: SettingItemType.toggle,
            value: _notifications,
            onToggle: (value) {
              setState(() => _notifications = value);
              _savePreference('notifications', value);
            },
          ),
          SettingItem(
            id: 'sound',
            icon: Icons.volume_up,
            label: 'Sound Effects',
            type: SettingItemType.toggle,
            value: _soundEnabled,
            onToggle: (value) {
              setState(() => _soundEnabled = value);
              _savePreference('sound_enabled', value);
            },
          ),
          SettingItem(
            id: 'autoplay',
            icon: Icons.play_circle,
            label: 'Auto-Play Videos',
            type: SettingItemType.toggle,
            value: _autoPlay,
            onToggle: (value) {
              setState(() => _autoPlay = value);
              _savePreference('autoplay', value);
            },
          ),
          SettingItem(
            id: 'offline',
            icon: Icons.cloud_download,
            label: 'Offline Mode',
            type: SettingItemType.toggle,
            value: _offlineMode,
            onToggle: (value) {
              setState(() => _offlineMode = value);
              _savePreference('offline_mode', value);
            },
          ),
        ],
      ),
      SettingsSection(
        id: 'account',
        title: 'Account',
        items: [
          SettingItem(
            id: 'profile',
            icon: Icons.person,
            label: 'Edit Profile',
            type: SettingItemType.navigation,
            onPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile coming soon!')),
              );
            },
          ),
          SettingItem(
            id: 'security',
            icon: Icons.shield,
            label: 'Privacy & Security',
            type: SettingItemType.navigation,
            onPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy & Security coming soon!')),
              );
            },
          ),
          SettingItem(
            id: 'notifications_settings',
            icon: Icons.notifications_active,
            label: 'Notification Settings',
            type: SettingItemType.navigation,
            onPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification Settings coming soon!')),
              );
            },
          ),
          SettingItem(
            id: 'change_password',
            icon: Icons.key,
            label: 'Change Password',
            type: SettingItemType.navigation,
            onPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Password coming soon!')),
              );
            },
          ),
        ],
      ),
      SettingsSection(
        id: 'support',
        title: 'Support',
        items: [
          SettingItem(
            id: 'help',
            icon: Icons.help,
            label: 'Help & Support',
            type: SettingItemType.navigation,
            onPress: _handleHelpSupport,
          ),
          SettingItem(
            id: 'feedback',
            icon: Icons.chat_bubble,
            label: 'Send Feedback',
            type: SettingItemType.navigation,
            onPress: _showFeedbackDialog,
          ),
          SettingItem(
            id: 'report',
            icon: Icons.flag,
            label: 'Report a Problem',
            type: SettingItemType.navigation,
            onPress: _showReportProblemDialog,
          ),
          SettingItem(
            id: 'faq',
            icon: Icons.info,
            label: 'FAQ',
            type: SettingItemType.navigation,
            onPress: _showFAQDialog,
          ),
        ],
      ),
      SettingsSection(
        id: 'app',
        title: 'App',
        items: [
          SettingItem(
            id: 'cache',
            icon: Icons.delete,
            label: 'Clear Cache',
            type: SettingItemType.button,
            onPress: () => _handleClearCache(context),
            destructive: true,
          ),
          SettingItem(
            id: 'updates',
            icon: Icons.cloud_upload,
            label: 'Check for Updates',
            type: SettingItemType.button,
            onPress: () => _handleCheckUpdates(context),
          ),
          SettingItem(
            id: 'rate',
            icon: Icons.star,
            label: 'Rate App',
            type: SettingItemType.button,
            onPress: _handleRateApp,
          ),
          SettingItem(
            id: 'share',
            icon: Icons.share,
            label: 'Share App',
            type: SettingItemType.button,
            onPress: _handleShareApp,
          ),
          SettingItem(
            id: 'about',
            icon: Icons.info_outline,
            label: 'About',
            type: SettingItemType.navigation,
            onPress: _handleAbout,
          ),
        ],
      ),
      SettingsSection(
        id: 'legal',
        title: 'Legal',
        items: [
          SettingItem(
            id: 'privacy',
            icon: Icons.description,
            label: 'Privacy Policy',
            type: SettingItemType.link,
            onPress: _handlePrivacyPolicy,
          ),
          SettingItem(
            id: 'terms',
            icon: Icons.article,
            label: 'Terms of Service',
            type: SettingItemType.link,
            onPress: _handleTermsOfService,
          ),
          SettingItem(
            id: 'cookies',
            icon: Icons.description_outlined,
            label: 'Cookie Policy',
            type: SettingItemType.link,
            onPress: _handleCookiePolicy,
          ),
        ],
      ),
    ];
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We value your feedback!'),
            const SizedBox(height: 8),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your feedback here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showReportProblemDialog() {
    final TextEditingController reportController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Problem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe the problem you encountered:'),
            const SizedBox(height: 8),
            TextField(
              controller: reportController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Problem reported successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showFAQDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q: How do I enroll in a course?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('A: Browse courses and click the "Enroll" button.'),
            SizedBox(height: 12),
            Text(
              'Q: Can I access courses offline?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('A: Yes, download courses for offline viewing.'),
            SizedBox(height: 12),
            Text(
              'Q: How do I get a certificate?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('A: Complete all course requirements and pass the final exam.'),
            SizedBox(height: 12),
            Text(
              'Q: What payment methods are accepted?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('A: We accept credit cards, PayPal, and more.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.user;
    final isAuthenticated = authProvider.isAuthenticated;
    final displayName = user?.displayName ?? 'User';
    final initials = user?.initials ?? 'U';
    final sections = _buildSections(context, isDarkMode);
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;

    // Get colors using existing AppColors methods
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh settings data
          },
          color: primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),

                // User Profile Section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: backgroundElementColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.1 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit Profile coming soon!')),
                          );
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: backgroundElementColor,
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: user?.profileImageUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.profileImageUrl!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          initials,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              user?.email ?? 'user@email.com',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: textSecondaryColor,
                              ),
                            ),
                            if (user?.role != null && user!.role.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user.displayRole,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Edit Button
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit Profile coming soon!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundElementColor,
                          foregroundColor: textColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: backgroundSelectedColor,
                            ),
                          ),
                        ),
                        child: Text(
                          'Edit',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Settings Sections
                ...sections.map((section) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              section.title.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: textSecondaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: backgroundElementColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: section.items.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final isLast = index == section.items.length - 1;
                                return _buildSettingsItem(
                                  item,
                                  isLast,
                                  brightness,
                                  context,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    )),

                // Version Info
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        'Version 1.0.0',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                      Text(
                        'Built with ❤️',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoggingOut ? null : () => _handleLogout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoggingOut
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Logging out...',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout),
                              const SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Delete Account Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _handleDeleteAccount(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Delete Account',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    SettingItem item,
    bool isLast,
    Brightness brightness,
    BuildContext context,
  ) {
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return GestureDetector(
      onTap: item.type != SettingItemType.toggle ? item.onPress : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: backgroundSelectedColor,
                  ),
                ),
        ),
        child: Row(
          children: [
            // Icon
            SizedBox(
              width: 32,
              child: Icon(
                item.icon,
                size: 22,
                color: item.destructive ? Colors.red.shade400 : textSecondaryColor,
              ),
            ),
            
            // Label
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: item.destructive ? Colors.red.shade400 : textColor,
                ),
              ),
            ),
            
            // Right Side Content
            Row(
              children: [
                // Badge
                if (item.badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: textColor,
                    ),
                    child: Text(
                      item.badge!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: backgroundColor,
                      ),
                    ),
                  ),
                ],
                
                // Value (for button type)
                if (item.value != null && item.type == SettingItemType.button) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      item.value.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                  ),
                ],
                
                // Toggle - Fixed to show properly
                if (item.type == SettingItemType.toggle) ...[
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: item.value as bool,
                      onChanged: item.onToggle,
                      activeThumbColor: primaryColor,
                      activeTrackColor: primaryColor.withValues(alpha: 0.5),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
                
                // Navigation/Button/Link arrow
                if (item.type == SettingItemType.button ||
                    item.type == SettingItemType.link ||
                    item.type == SettingItemType.navigation) ...[
                  Icon(
                    item.type == SettingItemType.link
                        ? Icons.open_in_new
                        : Icons.chevron_right,
                    size: 20,
                    color: textSecondaryColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}