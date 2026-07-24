import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/screens/home/home_screen.dart';
import 'package:buildacad/screens/instructor/instructor_profile_screen.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                  child: Row(children: [
                    Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textOnSurfaceVariant(brightness)),
                    const SizedBox(width: 4),
                    Text('BuildAcad', style: AppTypography.headlineSmMobile.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700,
                    )),
                  ]),
                ),
                const Spacer(),
                Text('Instructor Panel', style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textOnSurface(brightness),
                )),
                const Spacer(),
                IconButton(icon: Icon(Icons.notifications_outlined, color: AppColors.textOnSurfaceVariant(brightness)), onPressed: () {}),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstructorProfileScreen())),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceVariant(brightness),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.cardAll,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome, Dr. Volkov!", style: AppTypography.headlineMdMobile.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(height: 8),
                        Text('You have 3 upcoming live sessions today', style: AppTypography.bodySm.copyWith(
                          color: Colors.white70,
                        )),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            minimumSize: Size.fromHeight(44),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                          ),
                          child: Text('Start Live Session', style: AppTypography.labelCaps.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w700,
                          )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats
                  Text('Overview', style: AppTypography.headlineSmMobile.copyWith(
                    color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _StatCard(title: 'Total Students', value: '85,230', icon: Icons.group_rounded, color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(title: 'Active Courses', value: '12', icon: Icons.menu_book_rounded, color: AppColors.brandOrange)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(title: 'Revenue', value: '\$45,280', icon: Icons.attach_money_rounded, color: AppColors.brandGreen)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(title: 'Avg. Rating', value: '4.9', icon: Icons.star_rounded, color: AppColors.brandAmber)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Recent activity
                  Text('Recent Activity', style: AppTypography.headlineSmMobile.copyWith(
                    color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 16),
                  _ActivityItem(
                    icon: Icons.person_add_rounded,
                    title: 'New enrollment',
                    subtitle: 'Sarah M. enrolled in Advanced Robotics',
                    time: '2m ago',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  _ActivityItem(
                    icon: Icons.star_rounded,
                    title: 'New review',
                    subtitle: 'Binod K. left a 5-star review',
                    time: '15m ago',
                    color: AppColors.brandAmber,
                  ),
                  const SizedBox(height: 8),
                  _ActivityItem(
                    icon: Icons.comment_rounded,
                    title: 'New question',
                    subtitle: 'Sarah asked about Kalman filtering',
                    time: '1h ago',
                    color: AppColors.brandGreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
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
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const Spacer(),
            Icon(Icons.trending_up_rounded, color: AppColors.brandGreen, size: 16),
          ]),
          const SizedBox(height: 12),
          Text(value, style: AppTypography.headlineMdMobile.copyWith(
            color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 4),
          Text(title, style: AppTypography.bodySm.copyWith(
            color: AppColors.outline(brightness),
          )),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, time;
  final Color color;
  const _ActivityItem({required this.icon, required this.title, required this.subtitle,
    required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textOnSurface(brightness),
                )),
                Text(subtitle, style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness), fontSize: 12,
                )),
              ],
            ),
          ),
          Text(time, style: AppTypography.bodySm.copyWith(
            color: AppColors.outline(brightness), fontSize: 11,
          )),
        ],
      ),
    );
  }
}
