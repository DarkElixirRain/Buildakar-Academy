import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/instructor_dashboard_provider.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final cardColor = AppColors.getBackgroundElementColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Instructor Profile', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor, elevation: 0, automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<InstructorDashboardProvider>(
            builder: (context, provider, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
                          child: user.profileImageUrl == null
                              ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                  style: GoogleFonts.inter(fontSize: 32, color: Colors.white))
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(user.name, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                        Text(user.email, style: GoogleFonts.inter(color: textSecondaryColor)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Instructor', style: GoogleFonts.inter(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    backgroundColor: cardColor,
                    child: Column(
                      children: [
                        _ProfileTile(icon: Icons.school, label: 'Total Courses', value: '${provider.totalCourses}', textColor: textColor, textSecondaryColor: textSecondaryColor),
                        const Divider(height: 1, indent: 56),
                        _ProfileTile(icon: Icons.people, label: 'Total Students', value: '${provider.totalStudents}', textColor: textColor, textSecondaryColor: textSecondaryColor),
                        const Divider(height: 1, indent: 56),
                        _ProfileTile(icon: Icons.attach_money, label: 'Total Revenue', value: 'रु ${provider.totalRevenue.toStringAsFixed(0)}', textColor: textColor, textSecondaryColor: textSecondaryColor),
                        const Divider(height: 1, indent: 56),
                        _ProfileTile(icon: Icons.star, label: 'Average Rating', value: provider.averageRating.toStringAsFixed(1), textColor: textColor, textSecondaryColor: textSecondaryColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Account Settings', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    backgroundColor: cardColor,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit, color: primaryColor),
                          title: Text('Edit Profile', style: GoogleFonts.inter(color: textColor)),
                          trailing: Icon(Icons.chevron_right, color: textSecondaryColor),
                          onTap: () => _showComingSoon(context),
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: Icon(Icons.notifications, color: primaryColor),
                          title: Text('Notification Preferences', style: GoogleFonts.inter(color: textColor)),
                          trailing: Icon(Icons.chevron_right, color: textSecondaryColor),
                          onTap: () => _showComingSoon(context),
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: Icon(Icons.payment, color: primaryColor),
                          title: Text('Payment Settings', style: GoogleFonts.inter(color: textColor)),
                          trailing: Icon(Icons.chevron_right, color: textSecondaryColor),
                          onTap: () => _showComingSoon(context),
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: Icon(Icons.help, color: primaryColor),
                          title: Text('Help & Support', style: GoogleFonts.inter(color: textColor)),
                          trailing: Icon(Icons.chevron_right, color: textSecondaryColor),
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This feature is coming soon!'), backgroundColor: Colors.blue),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color textColor, textSecondaryColor;
  const _ProfileTile({required this.icon, required this.label, required this.value, required this.textColor, required this.textSecondaryColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textSecondaryColor),
      title: Text(label, style: GoogleFonts.inter(color: textColor)),
      trailing: Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}
