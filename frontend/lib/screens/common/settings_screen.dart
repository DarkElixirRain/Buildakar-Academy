import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: AppTypography.headlineSmMobile.copyWith(
          color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
        )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: Icon(Icons.person, size: 32, color: AppColors.outline(brightness)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alex Thompson', style: AppTypography.headlineSmMobile.copyWith(
                          color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                        )),
                        Text('alex@example.com', style: AppTypography.bodySm.copyWith(
                          color: AppColors.outline(brightness),
                        )),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.outline(brightness)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(title: 'ACCOUNT', items: [
              _SettingsTile(icon: Icons.person_outline_rounded, title: 'Edit Profile'),
              _SettingsTile(icon: Icons.lock_outline_rounded, title: 'Password'),
              _SettingsTile(icon: Icons.payment_rounded, title: 'Payment Methods'),
            ]),
            const SizedBox(height: 16),
            _SettingsSection(title: 'PREFERENCES', items: [
              _SettingsTile(icon: Icons.notifications_rounded, title: 'Notifications', trailing: Switch(
                value: true, onChanged: (_) {}, activeColor: AppColors.primary,
              )),
              _SettingsTile(icon: Icons.language_rounded, title: 'Language', subtitle: 'English'),
              _SettingsTile(icon: Icons.dark_mode_rounded, title: 'Dark Mode', trailing: Switch(
                value: false, onChanged: (_) {}, activeColor: AppColors.primary,
              )),
            ]),
            const SizedBox(height: 16),
            _SettingsSection(title: 'SUPPORT', items: [
              _SettingsTile(icon: Icons.help_outline_rounded, title: 'Help Center'),
              _SettingsTile(icon: Icons.gavel_rounded, title: 'Terms of Service'),
              _SettingsTile(icon: Icons.privacy_tip_rounded, title: 'Privacy Policy'),
            ]),
            const SizedBox(height: 24),
            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.brandRed, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                ),
                child: Text('Log Out', style: AppTypography.labelCaps.copyWith(
                  color: AppColors.brandRed, fontWeight: FontWeight.w700,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsTile> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: AppTypography.labelCaps.copyWith(
              color: AppColors.outline(brightness), fontWeight: FontWeight.w700,
            )),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border(brightness), width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textOnSurface(brightness),
                )),
                if (subtitle != null) Text(subtitle!, style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness), fontSize: 12,
                )),
              ],
            ),
          ),
          trailing ?? Icon(Icons.chevron_right_rounded, color: AppColors.outline(brightness), size: 22),
        ],
      ),
    );
  }
}
