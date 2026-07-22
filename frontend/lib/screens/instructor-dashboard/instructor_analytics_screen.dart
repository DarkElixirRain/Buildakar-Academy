import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/instructor_dashboard_provider.dart';

class InstructorAnalyticsScreen extends StatefulWidget {
  const InstructorAnalyticsScreen({super.key});

  @override
  State<InstructorAnalyticsScreen> createState() => _InstructorAnalyticsScreenState();
}

class _InstructorAnalyticsScreenState extends State<InstructorAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorDashboardProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final cardColor = AppColors.getBackgroundElementColor(brightness);
    final successColor = AppColors.getSuccessColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Analytics', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor, elevation: 0, automaticallyImplyLeading: false,
      ),
      body: Consumer<InstructorDashboardProvider>(
        builder: (context, provider, _) {
          final a = provider.analytics;
          if (provider.isLoading && a == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAnalytics(),
            color: primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _AnalyticCard(label: 'Total Students', value: '${a?['totalStudents'] ?? provider.totalStudents}', icon: Icons.people, color: Colors.blue, cardColor: cardColor, textColor: textColor, textSecondaryColor: textSecondaryColor),
                    const SizedBox(width: 12),
                    _AnalyticCard(label: 'Avg Rating', value: (a?['avgRating'] ?? provider.averageRating).toStringAsFixed(1), icon: Icons.star, color: Colors.amber, cardColor: cardColor, textColor: textColor, textSecondaryColor: textSecondaryColor),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _AnalyticCard(label: 'Revenue', value: '\$${(a?['totalRevenue'] ?? provider.totalRevenue).toStringAsFixed(0)}', icon: Icons.trending_up, color: Colors.green, cardColor: cardColor, textColor: textColor, textSecondaryColor: textSecondaryColor),
                    const SizedBox(width: 12),
                    _AnalyticCard(label: 'Reviews', value: '${a?['totalReviews'] ?? provider.totalReviews}', icon: Icons.rate_review, color: Colors.purple, cardColor: cardColor, textColor: textColor, textSecondaryColor: textSecondaryColor),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Performance Metrics', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 12),
                _MetricRow(label: 'Completion Rate', value: '${a?['completionRate'] ?? 72}%', color: successColor, textColor: textColor, textSecondaryColor: textSecondaryColor),
                _MetricRow(label: 'Engagement Score', value: '${a?['engagement'] ?? 85}%', color: primaryColor, textColor: textColor, textSecondaryColor: textSecondaryColor),
                _MetricRow(label: 'Retention Rate', value: '${a?['retentionRate'] ?? 89}%', color: Colors.amber, textColor: textColor, textSecondaryColor: textSecondaryColor),
                _MetricRow(label: 'Monthly Growth', value: '+${a?['monthlyGrowth'] ?? 12}%', color: Colors.green, textColor: textColor, textSecondaryColor: textSecondaryColor),
                const SizedBox(height: 24),
                Text('Course Insights', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _InsightRow(label: 'Top Section', value: a?['topPerformingSection'] ?? 'N/A', textColor: textColor, textSecondaryColor: textSecondaryColor),
                      const Divider(height: 24),
                      _InsightRow(label: 'Avg Quiz Score', value: '${a?['avgQuizScore'] ?? 84}%', textColor: textColor, textSecondaryColor: textSecondaryColor),
                      const Divider(height: 24),
                      _InsightRow(label: 'Certificates Issued', value: '${a?['totalCertificates'] ?? 0}', textColor: textColor, textSecondaryColor: textSecondaryColor),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnalyticCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, cardColor, textColor, textSecondaryColor;
  const _AnalyticCard({required this.label, required this.value, required this.icon, required this.color, required this.cardColor, required this.textColor, required this.textSecondaryColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor)),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label, value;
  final Color color, textColor, textSecondaryColor;
  const _MetricRow({required this.label, required this.value, required this.color, required this.textColor, required this.textSecondaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.1))),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.inter(color: textColor))),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label, value;
  final Color textColor, textSecondaryColor;
  const _InsightRow({required this.label, required this.value, required this.textColor, required this.textSecondaryColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: textSecondaryColor)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor)),
      ],
    );
  }
}
