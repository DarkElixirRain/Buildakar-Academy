import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/widgets/common/rating_stars.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  int _tabIndex = 0;

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
          IconButton(icon: Icon(Icons.notifications_outlined, color: AppColors.textOnSurfaceVariant(brightness)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Hero thumbnail
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: AppColors.surfaceVariant(brightness),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Center(child: Icon(Icons.play_circle_outline, color: AppColors.primary, size: 64)),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 100,
                      decoration: const BoxDecoration(gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)],
                      )),
                    ),
                  ),
                  Positioned(
                    bottom: 12, left: 16,
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.brandOrange,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle,
                          )),
                          const SizedBox(width: 4),
                          Text('LIVE', style: AppTypography.labelCaps.copyWith(color: Colors.white, fontSize: 10)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface(brightness).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('BESTSELLER', style: AppTypography.labelCaps.copyWith(
                          color: AppColors.primary, fontSize: 10,
                        )),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          // Header info
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Advanced Autonomous Robotics', style: AppTypography.displayLgMobile.copyWith(
                          color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(height: 16),
                        // Instructor row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.surfaceVariant(brightness),
                              child: Icon(Icons.person, color: AppColors.outline(brightness)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dr. Elena Volkov', style: AppTypography.bodyMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textOnSurface(brightness),
                                  )),
                                  Text('Lead Robotics Engineer', style: AppTypography.bodySm.copyWith(
                                    color: AppColors.outline(brightness),
                                  )),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.fromHeight(36),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                side: const BorderSide(color: AppColors.primary, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.chipAll),
                              ),
                              child: Text('FOLLOW', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Metadata
                        Row(children: [
                          const Icon(Icons.star, color: Color(0xFFF59E0B), size: 20),
                          const SizedBox(width: 4),
                          Text('4.9', style: AppTypography.numericTabular.copyWith(
                            fontWeight: FontWeight.w700, color: AppColors.textOnSurface(brightness),
                          )),
                          const SizedBox(width: 4),
                          Text('(12.4k reviews)', style: AppTypography.bodySm.copyWith(
                            color: AppColors.outline(brightness),
                          )),
                          const SizedBox(width: 16),
                          Icon(Icons.group_outlined, color: AppColors.outline(brightness), size: 20),
                          const SizedBox(width: 4),
                          Text('85,230', style: AppTypography.numericTabular.copyWith(
                            fontWeight: FontWeight.w700, color: AppColors.textOnSurface(brightness),
                          )),
                          Text(' students', style: AppTypography.bodySm.copyWith(
                            color: AppColors.outline(brightness),
                          )),
                        ]),
                      ],
                    ),
                  ),
                  // Tab bar
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border(brightness))),
                    ),
                    child: Row(
                      children: ['OVERVIEW', 'CURRICULUM', 'REVIEWS'].asMap().entries.map((e) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tabIndex = e.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _tabIndex == e.key ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(e.value, textAlign: TextAlign.center,
                              style: AppTypography.labelCaps.copyWith(
                                color: _tabIndex == e.key ? AppColors.primary : AppColors.outline(brightness),
                                fontWeight: _tabIndex == e.key ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  // Tab content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _tabIndex == 0 ? _OverviewTab() : _tabIndex == 1 ? _CurriculumTab() : _ReviewsTab(),
                  ),
                ],
              ),
            ),
          ),
          // Sticky bottom bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface(brightness),
              border: Border(top: BorderSide(color: AppColors.border(brightness))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL PRICE', style: AppTypography.labelCaps.copyWith(color: AppColors.outline(brightness))),
                      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                        Text('\$49.99', style: AppTypography.displayLgMobile.copyWith(
                          color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(width: 8),
                        Text('\$129.99', style: AppTypography.bodySm.copyWith(
                          color: AppColors.outline(brightness), decoration: TextDecoration.lineThrough,
                        )),
                      ]),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandOrange,
                      foregroundColor: Colors.white,
                      minimumSize: Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                    ),
                    child: Text('Enroll Now', style: AppTypography.headlineSmMobile.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700,
                    )),
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

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level chips
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant(brightness),
              borderRadius: AppRadius.smAll,
            ),
            child: Row(children: [
              Icon(Icons.bar_chart, size: 18, color: AppColors.textOnSurfaceVariant(brightness)),
              const SizedBox(width: 4),
              Text('Intermediate', style: AppTypography.bodySm.copyWith(color: AppColors.textOnSurfaceVariant(brightness))),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Row(children: [
              const Icon(Icons.schedule, size: 18, color: AppColors.primary),
              const SizedBox(width: 4),
              Text('42 Hours', style: AppTypography.bodySm.copyWith(color: AppColors.primary)),
            ]),
          ),
        ]),
        const SizedBox(height: 24),
        // What you'll learn
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest(brightness),
            borderRadius: AppRadius.cardAll,
            border: Border.all(color: AppColors.border(brightness)),
            boxShadow: AppShadow.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("What you'll learn", style: AppTypography.headlineSm.copyWith(
                color: AppColors.textOnSurface(brightness),
              )),
              const SizedBox(height: 16),
              ...['Design PID control loops for complex motion systems.',
                  'Integrate computer vision for object recognition.',
                  'Implement SLAM algorithms for autonomous navigation.',
                  'Optimize firmware for low-latency actuator response.',
              ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item, style: AppTypography.bodySm.copyWith(
                    color: AppColors.textOnSurfaceVariant(brightness),
                  ))),
                ]),
              )),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Prerequisites
        Text('Prerequisites', style: AppTypography.headlineSm.copyWith(
          color: AppColors.textOnSurface(brightness),
        )),
        const SizedBox(height: 12),
        _PrereqItem(icon: Icons.code, text: 'Intermediate proficiency in C++ or Python'),
        const SizedBox(height: 8),
        _PrereqItem(icon: Icons.functions, text: 'Basic understanding of Linear Algebra & Calculus'),
      ],
    );
  }
}

class _PrereqItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PrereqItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: AppRadius.smAll,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTypography.bodySm.copyWith(
          color: AppColors.textOnSurfaceVariant(brightness),
        ))),
      ]),
    );
  }
}

class _CurriculumTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final sections = [
      {'title': 'Section 1: Fundamentals of Mechatronics', 'lessons': '4 Lessons', 'duration': '2h 15m', 'expanded': true,
       'items': ['Introduction to the Course', 'Setting up your Workspace', 'Hardware Component Guide']},
      {'title': 'Section 2: Sensor Fusion & Data Processing', 'lessons': '8 Lessons', 'duration': '5h 45m', 'expanded': false},
      {'title': 'Section 3: Kinematics & Motion Planning', 'lessons': '12 Lessons', 'duration': '8h 10m', 'expanded': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('12 Sections \u2022 84 Lessons', style: AppTypography.bodySm.copyWith(color: AppColors.outline(brightness))),
          Text('EXPAND ALL', style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        ...sections.map((s) => _SectionAccordion(
          title: s['title'] as String, lessons: s['lessons'] as String, duration: s['duration'] as String,
          expanded: s['expanded'] as bool, items: (s['items'] as List<String>?) ?? [],
        )),
      ],
    );
  }
}

class _SectionAccordion extends StatelessWidget {
  final String title, lessons, duration;
  final bool expanded;
  final List<String> items;

  const _SectionAccordion({required this.title, required this.lessons, required this.duration,
    this.expanded = false, this.items = const []});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow(brightness),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(expanded ? 16 : 16),
                  bottom: Radius.circular(expanded ? 0 : 16),
                ),
              ),
              child: Row(children: [
                Icon(expanded ? Icons.expand_more : Icons.chevron_right,
                  color: AppColors.textOnSurfaceVariant(brightness)),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnSurface(brightness),
                ))),
                Text('$lessons \u2022 $duration', style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness),
                )),
              ]),
            ),
          ),
          if (expanded) ...items.map((item) => Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 16, 16),
            child: Row(children: [
              Icon(Icons.play_circle_outline, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(item, style: AppTypography.bodySm.copyWith(
                color: AppColors.textOnSurface(brightness),
              ))),
            ]),
          )),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating summary
        Row(
          children: [
            Text('4.9', style: AppTypography.displayLgMobile.copyWith(
              color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
            )),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RatingStars(rating: 4.9, showNumber: false, size: 20),
                const SizedBox(height: 4),
                Text('12,400 reviews', style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness),
                )),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Sample reviews
        _ReviewCard(name: 'Binod K.', rating: 5, comment: 'Best architectural guide in Nepal! The BIM module was exceptional.', date: '2 days ago'),
        const SizedBox(height: 12),
        _ReviewCard(name: 'Sarah M.', rating: 4, comment: 'Great course content. Would love more practical exercises.', date: '1 week ago'),
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
        boxShadow: AppShadow.card,
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
            Text(date, style: AppTypography.bodySm.copyWith(color: AppColors.outline(brightness), fontSize: 12)),
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
