import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/instructor_dashboard_provider.dart';
import '../../providers/theme_provider.dart';
import '../instructor/course_creation_screen.dart';
import 'instructor_dashboard_screens.dart' show setSubScreen;

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);

    return Consumer<InstructorDashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.stats == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: textSecondaryColor),
                const SizedBox(height: 16),
                Text('Error loading dashboard',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Text(provider.error!, style: GoogleFonts.inter(color: textSecondaryColor), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.loadAll(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadAll(),
          color: primaryColor,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              _HeaderSection(textColor: textColor, textSecondaryColor: textSecondaryColor),
              const SizedBox(height: 12),
              _StatsRow(
                stats: [
                  _StatItem(label: 'Courses', value: '${provider.totalCourses}', icon: Icons.video_library_outlined, color: Colors.indigo),
                  _StatItem(label: 'Students', value: '${provider.totalStudents}', icon: Icons.groups_outlined, color: Colors.orange),
                  _StatItem(label: 'Revenue', value: 'रु ${provider.totalRevenue.toStringAsFixed(0)}', icon: Icons.attach_money, color: Colors.green),
                  _StatItem(label: 'Rating', value: provider.averageRating.toStringAsFixed(1), icon: Icons.star_half, color: Colors.amber),
                ],
                isDark: isDark, cardColor: AppColors.getBackgroundElementColor(brightness),
                textSecondaryColor: textSecondaryColor, textColor: textColor,
              ),
              const SizedBox(height: 20),
              _QuickActions(primaryColor: primaryColor, isDark: isDark, context: context),
              const SizedBox(height: 20),
              _DashboardMenuSection(isDark: isDark, textColor: textColor, textSecondaryColor: textSecondaryColor, context: context),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Color textColor;
  final Color textSecondaryColor;
  const _HeaderSection({required this.textColor, required this.textSecondaryColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instructor Dashboard', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 4),
        Text('Your teaching overview at a glance', style: GoogleFonts.inter(fontSize: 14, color: textSecondaryColor)),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.icon, required this.color});
}

class _StatsRow extends StatelessWidget {
  final List<_StatItem> stats;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color textSecondaryColor;

  const _StatsRow({
    required this.stats, required this.isDark, required this.cardColor,
    required this.textColor, required this.textSecondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((stat) => Expanded(
        child: Container(
          margin: EdgeInsets.only(left: stats.first == stat ? 0 : 8),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(stat.icon, color: stat.color, size: 24),
              const SizedBox(height: 8),
              Text(stat.value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
              const SizedBox(height: 2),
              Text(stat.label, style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor)),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final Color primaryColor;
  final bool isDark;
  final BuildContext context;

  const _QuickActions({required this.primaryColor, required this.isDark, required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: [
            _ActionChip(label: 'New Course', icon: Icons.add_circle_outline, onTap: () => _openCreateCourse(context), color: Colors.green, isDark: isDark),
            _ActionChip(label: 'New Live Class', icon: Icons.videocam, onTap: () => _openCreateLiveClass(context), color: Colors.red, isDark: isDark),
            _ActionChip(label: 'View Courses', icon: Icons.list_alt, onTap: () => setSubScreen( 'courses'), color: Colors.blue, isDark: isDark),
            _ActionChip(label: 'Analytics', icon: Icons.analytics, onTap: () => setSubScreen( 'analytics'), color: Colors.purple, isDark: isDark),
            _ActionChip(label: 'Students', icon: Icons.people, onTap: () => setSubScreen( 'students'), color: Colors.orange, isDark: isDark),
            _ActionChip(label: 'Earnings', icon: Icons.account_balance_wallet, onTap: () => setSubScreen( 'earnings'), color: Colors.teal, isDark: isDark),
          ],
        ),
      ],
    );
  }

  Future<void> _openCreateCourse(BuildContext context) async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const CourseCreationScreen()));
    if (result == true && context.mounted) {
      context.read<InstructorDashboardProvider>().loadAll();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course created successfully!'), backgroundColor: Colors.green));
    }
  }

  Future<void> _openCreateLiveClass(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live class creation coming soon!')));
    }
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool isDark;
  const _ActionChip({required this.label, required this.icon, required this.onTap, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

class _DashboardMenuSection extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color textSecondaryColor;
  final BuildContext context;

  const _DashboardMenuSection({required this.isDark, required this.textColor, required this.textSecondaryColor, required this.context});

  @override
  Widget build(BuildContext context) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final cardColor = AppColors.getBackgroundElementColor(brightness);

    final items = [
      const _MenuItem(icon: Icons.video_library, label: 'My Courses', subtitle: 'Manage your courses', route: 'courses', color: Colors.blue),
      const _MenuItem(icon: Icons.people, label: 'Students', subtitle: 'View enrolled students', route: 'students', color: Colors.orange),
      const _MenuItem(icon: Icons.analytics, label: 'Analytics', subtitle: 'Course performance data', route: 'analytics', color: Colors.purple),
      const _MenuItem(icon: Icons.account_balance_wallet, label: 'Earnings', subtitle: 'Revenue and payouts', route: 'earnings', color: Colors.teal),
      const _MenuItem(icon: Icons.videocam, label: 'Live Classes', subtitle: 'Manage live sessions', route: 'live', color: Colors.red),
      const _MenuItem(icon: Icons.rate_review, label: 'Reviews', subtitle: 'Student feedback', route: 'reviews', color: Colors.amber),
      const _MenuItem(icon: Icons.person, label: 'Profile', subtitle: 'Update your profile', route: 'profile', color: Colors.green),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard Sections', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 12),
        ...items.map((item) => AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.zero,
          borderRadius: 12,
          backgroundColor: cardColor,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(item.icon, color: item.color),
            ),
            title: Text(item.label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor)),
            subtitle: Text(item.subtitle, style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor)),
            trailing: Icon(Icons.chevron_right, color: textSecondaryColor),
            onTap: () => setSubScreen( item.route),
          ),
        )),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final Color color;
  const _MenuItem({required this.icon, required this.label, required this.subtitle, required this.route, required this.color});
}
