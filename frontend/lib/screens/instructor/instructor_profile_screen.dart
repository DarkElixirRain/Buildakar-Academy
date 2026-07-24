import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/widgets/common/rating_stars.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

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
        title: Text('BuildAcad', style: AppTypography.headlineSmMobile.copyWith(
          color: AppColors.primary, fontWeight: FontWeight.w700,
        )),
        actions: [
          IconButton(icon: Icon(Icons.share, color: AppColors.textOnSurfaceVariant(brightness)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.surface(brightness),
                border: Border(bottom: BorderSide(color: AppColors.border(brightness))),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surfaceVariant(brightness),
                        child: Icon(Icons.person, size: 48, color: AppColors.outline(brightness)),
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.brandGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Dr. Elena Volkov', style: AppTypography.headlineLgMobile.copyWith(
                    color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 4),
                  Text('Lead Robotics Engineer | AI Researcher', style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline(brightness),
                  )),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(value: '12', label: 'Courses'),
                      _statDivider(brightness),
                      _StatItem(value: '85k', label: 'Students'),
                      _statDivider(brightness),
                      _StatItem(value: '4.9', label: 'Rating'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: Size.fromHeight(48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                          ),
                          child: Text('Follow', style: AppTypography.headlineSmMobile.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700,
                          )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant(brightness),
                          borderRadius: AppRadius.buttonAll,
                        ),
                        child: Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tabs
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.outline(brightness),
                    indicatorColor: AppColors.primary,
                    labelStyle: AppTypography.labelCaps.copyWith(fontWeight: FontWeight.w700),
                    unselectedLabelStyle: AppTypography.labelCaps.copyWith(fontWeight: FontWeight.w500),
                    tabs: const [Tab(text: 'COURSES'), Tab(text: 'REVIEWS'), Tab(text: 'ABOUT')],
                  ),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      children: [
                        // Courses tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _InstructorCourseCard(
                                title: 'Advanced Autonomous Robotics',
                                students: '85,230', rating: 4.9, reviews: '12.4k',
                                isBestseller: true,
                              ),
                              const SizedBox(height: 12),
                              _InstructorCourseCard(
                                title: 'AI for Sustainable Engineering',
                                students: '62,100', rating: 4.8, reviews: '9.8k',
                                isBestseller: true,
                              ),
                            ],
                          ),
                        ),
                        // Reviews tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _ReviewSummary(rating: 4.9, total: '12,400', breakdown: [0.92, 0.06, 0.015, 0.005, 0]),
                              const SizedBox(height: 24),
                              _ReviewCard(name: 'Binod K.', rating: 5, comment: 'Exceptional instructor!', date: '2 days ago'),
                              const SizedBox(height: 12),
                              _ReviewCard(name: 'Sarah M.', rating: 4, comment: 'Very clear explanations.', date: '1 week ago'),
                            ],
                          ),
                        ),
                        // About tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Biography', style: AppTypography.headlineSm.copyWith(
                                color: AppColors.textOnSurface(brightness),
                              )),
                              const SizedBox(height: 12),
                              Text(
                                'Dr. Elena Volkov is a lead robotics engineer with over 15 years of experience in autonomous systems. She holds a Ph.D. from MIT and has published over 50 papers in top-tier journals.',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textOnSurfaceVariant(brightness), height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text('Specializations', style: AppTypography.headlineSm.copyWith(
                                color: AppColors.textOnSurface(brightness),
                              )),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                children: ['Robotics', 'AI/ML', 'Computer Vision', 'SLAM'].map((s) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                                    borderRadius: AppRadius.chipAll,
                                  ),
                                  child: Text(s, style: AppTypography.bodySm.copyWith(color: AppColors.primary)),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statDivider(Brightness brightness) => Container(
    width: 1, height: 32,
    color: AppColors.border(brightness),
  );
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(value, style: AppTypography.headlineMdMobile.copyWith(
            color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.bodySm.copyWith(
            color: AppColors.outline(brightness),
          )),
        ],
      ),
    );
  }
}

class _InstructorCourseCard extends StatelessWidget {
  final String title, students, reviews;
  final double rating;
  final bool isBestseller;
  const _InstructorCourseCard({required this.title, required this.students,
    required this.rating, required this.reviews, this.isBestseller = false});

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
      child: Row(
        children: [
          Container(
            width: 80, height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant(brightness),
              borderRadius: AppRadius.smAll,
            ),
            child: const Icon(Icons.play_circle_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(title, style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnSurface(brightness),
                  ))),
                  if (isBestseller) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.brandOrange,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Text('BESTSELLER', style: AppTypography.labelCaps.copyWith(
                        color: Colors.white, fontSize: 8,
                      )),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),
                Text('$students students', style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness), fontSize: 12,
                )),
                const SizedBox(height: 4),
                Row(children: [
                  Text(rating.toStringAsFixed(1), style: AppTypography.numericTabular.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.textOnSurface(brightness), fontSize: 13,
                  )),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                  const SizedBox(width: 4),
                  Text('($reviews)', style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline(brightness), fontSize: 11,
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  final double rating;
  final String total;
  final List<double> breakdown;
  const _ReviewSummary({required this.rating, required this.total, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Text(rating.toStringAsFixed(1), style: AppTypography.displayLgMobile.copyWith(
            color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 4),
          const RatingStars(rating: 4.9, showNumber: false, size: 16),
          const SizedBox(height: 4),
          Text('$total reviews', style: AppTypography.bodySm.copyWith(
            color: AppColors.outline(brightness),
          )),
        ]),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: List.generate(5, (i) {
              final star = 5 - i;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  Text('$star', style: AppTypography.bodySm.copyWith(color: AppColors.outline(brightness))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: breakdown[i],
                      backgroundColor: AppColors.border(brightness),
                      valueColor: const AlwaysStoppedAnimation(AppColors.brandAmber),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ]),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name, comment, date;
  final int rating;
  const _ReviewCard({required this.name, required this.rating, required this.comment, required this.date});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(radius: 16, backgroundColor: AppColors.surfaceVariant(brightness),
              child: Text(name[0], style: AppTypography.bodySm.copyWith(color: AppColors.primary))),
            const SizedBox(width: 8),
            Text(name, style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.textOnSurface(brightness),
            )),
            const Spacer(),
            Text(date, style: AppTypography.bodySm.copyWith(
              color: AppColors.outline(brightness), fontSize: 12,
            )),
          ]),
          const SizedBox(height: 8),
          RatingStars(rating: rating.toDouble(), showNumber: false, size: 14),
          const SizedBox(height: 8),
          Text(comment, style: AppTypography.bodySm.copyWith(
            color: AppColors.textOnSurfaceVariant(brightness),
          )),
        ],
      ),
    );
  }
}
