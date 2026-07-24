import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class InstructorAnalyticsScreen extends StatelessWidget {
  const InstructorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics', style: AppTypography.headlineMdMobile.copyWith(
              color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 24),
            // Revenue chart placeholder
            Container(
              width: double.infinity,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Revenue Trend', style: AppTypography.headlineSm.copyWith(
                        color: AppColors.textOnSurface(brightness),
                      )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: AppRadius.chipAll,
                        ),
                        child: Text('Last 30 days', style: AppTypography.labelCaps.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w500,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Chart bars
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7, 0.65, 0.85, 0.55, 0.75, 0.6].map((v) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                          height: 120 * v,
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
                               'Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((d) =>
                      Text(d, style: AppTypography.labelCaps.copyWith(
                        color: AppColors.outline(brightness), fontSize: 9,
                      )),
                    ).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Key metrics row
            Row(
              children: [
                _AnalyticsCard(title: 'Enrollments', value: '85,230', change: '+12%', isUp: true, icon: Icons.school_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                _AnalyticsCard(title: 'Completion', value: '72%', change: '+5%', isUp: true, icon: Icons.check_circle_rounded, color: AppColors.brandGreen),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _AnalyticsCard(title: 'Avg. Watch', value: '28m', change: '-3%', isUp: false, icon: Icons.play_circle_rounded, color: AppColors.brandOrange),
                const SizedBox(width: 12),
                _AnalyticsCard(title: 'Revenue', value: '\$45.2k', change: '+18%', isUp: true, icon: Icons.attach_money_rounded, color: AppColors.brandAmber),
              ],
            ),
            const SizedBox(height: 24),
            // Top courses
            Text('Top Performing Courses', style: AppTypography.headlineSm.copyWith(
              color: AppColors.textOnSurface(brightness),
            )),
            const SizedBox(height: 12),
            _TopCourseRow(rank: '1', title: 'Advanced Autonomous Robotics', revenue: '\$32,180', growth: '+22%'),
            const SizedBox(height: 8),
            _TopCourseRow(rank: '2', title: 'AI for Sustainable Engineering', revenue: '\$18,420', growth: '+15%'),
            const SizedBox(height: 8),
            _TopCourseRow(rank: '3', title: 'Embedded Systems Mastery', revenue: '\$12,300', growth: '+8%'),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title, value, change;
  final bool isUp;
  final IconData icon;
  final Color color;
  const _AnalyticsCard({required this.title, required this.value, required this.change,
    required this.isUp, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Expanded(
      child: Container(
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
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 12),
            Text(value, style: AppTypography.headlineMdMobile.copyWith(
              color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 4),
            Row(children: [
              Text(title, style: AppTypography.bodySm.copyWith(
                color: AppColors.outline(brightness), fontSize: 11,
              )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: (isUp ? AppColors.brandGreen : AppColors.brandRed).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 10, color: isUp ? AppColors.brandGreen : AppColors.brandRed),
                  Text(change, style: AppTypography.labelCaps.copyWith(
                    color: isUp ? AppColors.brandGreen : AppColors.brandRed, fontSize: 9,
                  )),
                ]),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _TopCourseRow extends StatelessWidget {
  final String rank, title, revenue, growth;
  const _TopCourseRow({required this.rank, required this.title, required this.revenue, required this.growth});

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
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: rank == '1' ? AppColors.brandAmber.withValues(alpha: 0.15) : AppColors.surfaceVariant(brightness),
              borderRadius: AppRadius.smAll,
            ),
            child: Center(child: Text(rank, style: AppTypography.numericTabular.copyWith(
              fontWeight: FontWeight.w700,
              color: rank == '1' ? AppColors.brandAmber : AppColors.textOnSurfaceVariant(brightness),
              fontSize: 12,
            ))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w500, color: AppColors.textOnSurface(brightness),
          ))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(revenue, style: AppTypography.numericTabular.copyWith(
                fontWeight: FontWeight.w700, color: AppColors.textOnSurface(brightness), fontSize: 13,
              )),
              Text(growth, style: AppTypography.labelCaps.copyWith(
                color: AppColors.brandGreen, fontSize: 10,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
