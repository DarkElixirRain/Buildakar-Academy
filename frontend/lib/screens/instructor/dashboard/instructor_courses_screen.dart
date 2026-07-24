import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class InstructorCoursesScreen extends StatelessWidget {
  const InstructorCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Courses', style: AppTypography.headlineMdMobile.copyWith(
                  color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                )),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('New Course', style: AppTypography.labelCaps.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700,
                  )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size.fromHeight(40),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tab filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Published', 'Draft', 'Archived'].map((label) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: label == 'All' ? AppColors.primary : AppColors.surfaceVariant(brightness),
                  borderRadius: AppRadius.chipAll,
                ),
                child: Text(label, style: AppTypography.labelCaps.copyWith(
                  color: label == 'All' ? Colors.white : AppColors.textOnSurfaceVariant(brightness),
                  fontWeight: FontWeight.w500,
                )),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CourseManagementCard(
                  title: 'Advanced Autonomous Robotics',
                  students: '85,230', status: 'Published', revenue: '\$32,180',
                  rating: 4.9, lessons: 84,
                ),
                const SizedBox(height: 12),
                _CourseManagementCard(
                  title: 'AI for Sustainable Engineering',
                  students: '62,100', status: 'Published', revenue: '\$18,420',
                  rating: 4.8, lessons: 64,
                ),
                const SizedBox(height: 12),
                _CourseManagementCard(
                  title: 'Neural Network Architectures',
                  students: '0', status: 'Draft', revenue: '\$0',
                  rating: 0, lessons: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseManagementCard extends StatelessWidget {
  final String title, status, revenue;
  final String students;
  final double rating;
  final int lessons;
  const _CourseManagementCard({required this.title, required this.students,
    required this.status, required this.revenue, required this.rating, required this.lessons});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isPublished = status == 'Published';
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
              width: 56, height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(brightness),
                borderRadius: AppRadius.smAll,
              ),
              child: const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textOnSurface(brightness),
                )),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPublished ? AppColors.brandGreen.withValues(alpha: 0.1) : AppColors.brandAmber.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Text(status.toUpperCase(), style: AppTypography.labelCaps.copyWith(
                      color: isPublished ? AppColors.brandGreen : AppColors.brandAmber,
                      fontSize: 9,
                    )),
                  ),
                  const SizedBox(width: 8),
                  Text('$lessons lessons', style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline(brightness), fontSize: 11,
                  )),
                ]),
              ],
            )),
          ]),
          const SizedBox(height: 12),
          // Metrics row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant(brightness).withValues(alpha: 0.3),
              borderRadius: AppRadius.smAll,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Metric(label: 'Students', value: students),
                _Metric(label: 'Rating', value: rating > 0 ? rating.toStringAsFixed(1) : '-'),
                _Metric(label: 'Revenue', value: revenue),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text('Manage', style: AppTypography.labelCaps.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600,
                  )),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(36),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.chipAll),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: Text('Analytics', style: AppTypography.labelCaps.copyWith(
                    color: AppColors.textOnSurfaceVariant(brightness), fontWeight: FontWeight.w600,
                  )),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(36),
                    side: BorderSide(color: AppColors.border(brightness), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.chipAll),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      children: [
        Text(value, style: AppTypography.bodyMd.copyWith(
          fontWeight: FontWeight.w700, color: AppColors.textOnSurface(brightness),
        )),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySm.copyWith(
          color: AppColors.outline(brightness), fontSize: 10,
        )),
      ],
    );
  }
}
