import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/screens/course/course_detail_screen.dart';
import 'package:buildacad/screens/course/course_learning.dart';
import 'package:buildacad/widgets/common/rating_stars.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background(brightness),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text('My Learning', style: AppTypography.headlineMdMobile.copyWith(
                  color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                )),
              ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border(brightness))),
                ),
                child: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.outline(brightness),
                  indicatorColor: AppColors.primary,
                  labelStyle: AppTypography.labelCaps.copyWith(fontWeight: FontWeight.w700),
                  unselectedLabelStyle: AppTypography.labelCaps.copyWith(fontWeight: FontWeight.w500),
                  tabs: const [Tab(text: 'IN PROGRESS'), Tab(text: 'COMPLETED')],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // In progress
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _LearningCard(
                          title: 'Advanced Autonomous Robotics',
                          instructor: 'Dr. Elena Volkov',
                          progress: 0.65,
                          lastAccessed: '2 hours ago',
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const CourseLearningScreen(courseId: '1'),
                          )),
                        ),
                        const SizedBox(height: 12),
                        _LearningCard(
                          title: 'AI for Sustainable Engineering',
                          instructor: 'Prof. James Chen',
                          progress: 0.30,
                          lastAccessed: '1 day ago',
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const CourseLearningScreen(courseId: '2'),
                          )),
                        ),
                      ],
                    ),
                    // Completed
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _CompletedCard(
                          title: 'Foundations of Machine Learning',
                          instructor: 'Dr. Aisha Patel',
                          rating: 4.8,
                          certificate: true,
                        ),
                        const SizedBox(height: 12),
                        _CompletedCard(
                          title: 'Flutter Development Bootcamp',
                          instructor: 'Sarah Johnson',
                          rating: 4.9,
                          certificate: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningCard extends StatelessWidget {
  final String title, instructor, lastAccessed;
  final double progress;
  final VoidCallback onTap;
  const _LearningCard({required this.title, required this.instructor, required this.progress,
    required this.lastAccessed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest(brightness),
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: AppColors.border(brightness)),
          boxShadow: AppShadow.card,
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 60,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(brightness),
                borderRadius: AppRadius.smAll,
              ),
              child: const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600, color: AppColors.textOnSurface(brightness),
                  )),
                  const SizedBox(height: 4),
                  Text(instructor, style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline(brightness), fontSize: 12,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border(brightness),
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(progress * 100).toInt()}%', style: AppTypography.numericTabular.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 12,
                      )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Last accessed $lastAccessed', style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline(brightness), fontSize: 10,
                  )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: AppColors.outline(brightness)),
          ],
        ),
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final String title, instructor;
  final double rating;
  final bool certificate;
  const _CompletedCard({required this.title, required this.instructor, required this.rating,
    required this.certificate});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.2)),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.brandGreen.withValues(alpha: 0.1),
                borderRadius: AppRadius.smAll,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.brandGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600, color: AppColors.textOnSurface(brightness),
                  )),
                  Text(instructor, style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline(brightness), fontSize: 12,
                  )),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              RatingStars(rating: rating, showNumber: true, size: 14),
              const Spacer(),
              if (certificate)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandAmber.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.emoji_events_rounded, color: AppColors.brandAmber, size: 14),
                    const SizedBox(width: 4),
                    Text('Certificate', style: AppTypography.labelCaps.copyWith(
                      color: AppColors.brandAmber, fontSize: 10,
                    )),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
