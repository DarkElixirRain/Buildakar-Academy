import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class InstructorSettingsScreen extends StatelessWidget {
  const InstructorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTypography.headlineMdMobile.copyWith(
              color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 24),
            // Profile section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest(brightness),
                borderRadius: AppRadius.cardAll,
                border: Border.all(color: AppColors.border(brightness)),
                boxShadow: AppShadow.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
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
                          Text('Dr. Elena Volkov', style: AppTypography.headlineSmMobile.copyWith(
                            color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                          )),
                          Text('Lead Robotics Engineer', style: AppTypography.bodySm.copyWith(
                            color: AppColors.outline(brightness),
                          )),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.outline(brightness)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Settings options
            _SettingsSection(title: 'ACCOUNT', items: [
              _SettingsItem(icon: Icons.person_outline_rounded, title: 'Edit Profile', subtitle: 'Name, bio, photo'),
              _SettingsItem(icon: Icons.lock_outline_rounded, title: 'Password', subtitle: 'Change password'),
              _SettingsItem(icon: Icons.payment_rounded, title: 'Payment Methods', subtitle: 'Manage payouts'),
            ]),
            const SizedBox(height: 16),
            _SettingsSection(title: 'INSTRUCTOR', items: [
              _SettingsItem(icon: Icons.school_rounded, title: 'Course Guidelines', subtitle: 'Best practices'),
              _SettingsItem(icon: Icons.gavel_rounded, title: 'Terms for Instructors', subtitle: 'Legal agreement'),
              _SettingsItem(icon: Icons.support_agent_rounded, title: 'Instructor Support', subtitle: 'Get help'),
            ]),
            const SizedBox(height: 16),
            _SettingsSection(title: 'PREFERENCES', items: [
              _SettingsItem(icon: Icons.notifications_rounded, title: 'Notifications', subtitle: 'Email & push'),
              _SettingsItem(icon: Icons.language_rounded, title: 'Language', subtitle: 'English'),
              _SettingsItem(icon: Icons.dark_mode_rounded, title: 'Dark Mode', subtitle: 'Off', trailing: Switch(
                value: false, onChanged: (_) {},
                activeColor: AppColors.primary,
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
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

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;
  const _SettingsItem({required this.icon, required this.title, required this.subtitle, this.trailing});

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
                Text(subtitle, style: AppTypography.bodySm.copyWith(
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
