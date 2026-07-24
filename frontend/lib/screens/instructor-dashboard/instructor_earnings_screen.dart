import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/instructor_dashboard_provider.dart';
import '../../providers/theme_provider.dart';

class InstructorEarningsScreen extends StatefulWidget {
  const InstructorEarningsScreen({super.key});

  @override
  State<InstructorEarningsScreen> createState() => _InstructorEarningsScreenState();
}

class _InstructorEarningsScreenState extends State<InstructorEarningsScreen> {
  String _timeRange = 'all';

  final _ranges = [
    ('week', 'This Week'),
    ('month', 'This Month'),
    ('quarter', 'This Quarter'),
    ('year', 'This Year'),
    ('all', 'All Time'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorDashboardProvider>().loadEarnings(timeRange: _timeRange);
    });
  }

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
    final successColor = AppColors.getSuccessColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Earnings', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor, elevation: 0, automaticallyImplyLeading: false,
      ),
      body: Consumer<InstructorDashboardProvider>(
        builder: (context, provider, _) {
          final e = provider.earnings;
          final totalEarnings = (e?['totalEarnings'] as num?)?.toDouble() ?? provider.totalEarnings;
          final monthlyEarnings = (e?['monthlyEarnings'] as num?)?.toDouble() ?? 0.0;
          final pendingPayout = (e?['pendingPayout'] as num?)?.toDouble() ?? 0.0;
          final totalCourses = (e?['totalCourses'] as num?)?.toInt() ?? provider.totalCourses;
          final transactions = e?['transactions'] as List<dynamic>? ?? [];

          return RefreshIndicator(
            onRefresh: () => provider.loadEarnings(timeRange: _timeRange),
            color: primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryColor, primaryColor.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text('Total Earnings', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('रु ${totalEarnings.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('${totalCourses > 0 ? totalCourses : '...'} course${totalCourses == 1 ? '' : 's'}', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Icon(Icons.monetization_on, color: successColor, size: 24),
                            const SizedBox(height: 8),
                            Text('रु ${monthlyEarnings.toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
                            Text('Monthly', style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 12,
                        backgroundColor: cardColor,
                        child: Column(
                          children: [
                            const Icon(Icons.hourglass_empty, color: Colors.orange, size: 24),
                            const SizedBox(height: 8),
                            Text('रु ${pendingPayout.toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
                            Text('Pending', style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _ranges.map((r) {
                      final selected = _timeRange == r.$1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _timeRange = r.$1);
                            provider.loadEarnings(timeRange: r.$1);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? primaryColor : cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: selected ? primaryColor : textColor.withValues(alpha: 0.1)),
                            ),
                            child: Text(r.$2, style: GoogleFonts.inter(fontSize: 13, color: selected ? Colors.white : textColor)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                if (transactions.isNotEmpty) ...[
                  Text('Recent Transactions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 12),
                  ...transactions.take(20).map((t) {
                    final txn = t as Map<String, dynamic>;
                    final amount = (txn['amount'] as num?)?.toDouble() ?? 0.0;
                    final desc = txn['description'] ?? 'Course sale';
                    final date = txn['date'] ?? '';
                    final isCredit = (txn['type'] as String?)?.toLowerCase() == 'credit';
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      borderRadius: 12,
                      backgroundColor: cardColor,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isCredit ? Colors.green : Colors.red).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(isCredit ? Icons.arrow_upward : Icons.arrow_downward, color: isCredit ? Colors.green : Colors.red, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(desc.toString(), style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(date.toString(), style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor)),
                              ],
                            ),
                          ),
                          Text('${isCredit ? '+' : '-'}रु ${amount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isCredit ? Colors.green : Colors.red)),
                        ],
                      ),
                    );
                  }),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 64, color: textSecondaryColor.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('No transactions yet', style: GoogleFonts.inter(color: textSecondaryColor)),
                        ],
                      ),
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
