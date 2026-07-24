import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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
        title: Text('Notifications', style: AppTypography.headlineSmMobile.copyWith(
          color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
        )),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Mark all read', style: AppTypography.labelCaps.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _SectionHeader(title: 'NEW'),
          _NotificationItem(
            icon: Icons.play_circle_rounded,
            title: 'Live class starting soon',
            subtitle: 'Advanced Sensor Fusion Workshop starts in 15 minutes',
            time: '15m ago', isNew: true, color: AppColors.brandRed,
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.star_rounded,
            title: 'New review on your course',
            subtitle: 'Binod K. left a 5-star review on Advanced Robotics',
            time: '1h ago', isNew: true, color: AppColors.brandAmber,
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.person_add_rounded,
            title: 'New student enrolled',
            subtitle: 'Sarah M. enrolled in AI for Sustainable Engineering',
            time: '3h ago', isNew: true, color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'EARLIER'),
          _NotificationItem(
            icon: Icons.comment_rounded,
            title: 'New question on your course',
            subtitle: 'Someone asked about Kalman filtering in Lesson 3',
            time: '1 day ago', isNew: false, color: AppColors.brandGreen,
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.emoji_events_rounded,
            title: 'Achievement unlocked!',
            subtitle: 'You earned the "Top Instructor" badge',
            time: '2 days ago', isNew: false, color: AppColors.brandAmber,
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.payment_rounded,
            title: 'Payment processed',
            subtitle: 'Your withdrawal of \$5,000 has been processed',
            time: '5 days ago', isNew: false, color: AppColors.brandGreen,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: AppTypography.labelCaps.copyWith(
        color: AppColors.outline(Theme.of(context).brightness),
        fontWeight: FontWeight.w700,
      )),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, time;
  final bool isNew;
  final Color color;
  const _NotificationItem({required this.icon, required this.title, required this.subtitle,
    required this.time, required this.isNew, required this.color});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? color.withValues(alpha: 0.04) : AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: isNew ? color.withValues(alpha: 0.2) : AppColors.border(brightness)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(title, style: AppTypography.bodyMd.copyWith(
                    fontWeight: isNew ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.textOnSurface(brightness),
                  ))),
                  if (isNew) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness), fontSize: 12,
                )),
                const SizedBox(height: 4),
                Text(time, style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness), fontSize: 11,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
