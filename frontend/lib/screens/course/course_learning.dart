import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class CourseLearningScreen extends StatefulWidget {
  final String courseId;
  const CourseLearningScreen({super.key, required this.courseId});
  @override
  State<CourseLearningScreen> createState() => _CourseLearningScreenState();
}

class _CourseLearningScreenState extends State<CourseLearningScreen> {
  int _selectedTab = 0;
  bool _sidebarOpen = true;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface(brightness),
                border: Border(bottom: BorderSide(color: AppColors.border(brightness))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textOnSurfaceVariant(brightness),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Advanced Autonomous Robotics', style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textOnSurface(brightness),
                        )),
                        Text('Lesson 3: Sensor Fusion & Kalman Filtering', style: AppTypography.bodySm.copyWith(
                          color: AppColors.outline(brightness),
                        )),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu,
                      color: AppColors.textOnSurfaceVariant(brightness)),
                    onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: Row(
                children: [
                  // Main content
                  Expanded(
                    child: Column(
                      children: [
                        // Video player placeholder
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: AppColors.textOnSurface(brightness),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Center(child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.play_circle_outline, color: Colors.white, size: 72),
                                    const SizedBox(height: 16),
                                    Text('Video Player', style: AppTypography.bodyMd.copyWith(color: Colors.white70)),
                                  ],
                                )),
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: const BoxDecoration(gradient: LinearGradient(
                                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black54],
                                    )),
                                    child: Row(children: [
                                      const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 4,
                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                            activeTrackColor: AppColors.brandOrange,
                                            inactiveTrackColor: Colors.white24,
                                            thumbColor: AppColors.brandOrange,
                                            overlayColor: AppColors.brandOrange.withValues(alpha: 0.2),
                                          ),
                                          child: Slider(value: 0.35, onChanged: (_) {}),
                                        ),
                                      ),
                                      Text('12:45 / 35:20', style: AppTypography.labelCaps.copyWith(
                                        color: Colors.white, fontSize: 10,
                                      )),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tabs
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface(brightness),
                            border: Border(bottom: BorderSide(color: AppColors.border(brightness))),
                          ),
                          child: Row(
                            children: ['NOTES', 'MATERIALS', 'Q&A'].asMap().entries.map((e) => Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = e.key),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _selectedTab == e.key ? AppColors.primary : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(e.value, textAlign: TextAlign.center,
                                    style: AppTypography.labelCaps.copyWith(
                                      color: _selectedTab == e.key ? AppColors.primary : AppColors.outline(brightness),
                                      fontWeight: _selectedTab == e.key ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                        // Tab content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _selectedTab == 0 ? _NotesTab() : _selectedTab == 1 ? _MaterialsTab() : _QATab(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sidebar
                  if (_sidebarOpen)
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: AppColors.surface(brightness),
                        border: Border(left: BorderSide(color: AppColors.border(brightness))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.border(brightness))),
                            ),
                            child: Text('Course Content', style: AppTypography.headlineSmMobile.copyWith(
                              color: AppColors.textOnSurface(brightness),
                            )),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              children: [
                                _SidebarSection(title: 'Section 1: Fundamentals', lessons: [
                                  _SidebarLesson(title: 'Introduction to Course', duration: '8:30', completed: true),
                                  _SidebarLesson(title: 'Setting up Workspace', duration: '15:20', completed: true),
                                  _SidebarLesson(title: 'Hardware Components', duration: '22:10', completed: true),
                                  _SidebarLesson(title: 'First Robot Assembly', duration: '18:45', completed: true),
                                ]),
                                _SidebarSection(title: 'Section 2: Sensor Fusion', lessons: [
                                  _SidebarLesson(title: 'Introduction to Sensors', duration: '12:00', completed: true),
                                  _SidebarLesson(title: 'Kalman Filtering Basics', duration: '28:30', completed: true),
                                  _SidebarLesson(title: 'Sensor Fusion & Kalman Filtering', duration: '35:20', completed: false, active: true),
                                  _SidebarLesson(title: 'Advanced Sensor Processing', duration: '20:15', completed: false),
                                ]),
                                _SidebarSection(title: 'Section 3: Motion Planning', lessons: [
                                  _SidebarLesson(title: 'Kinematics Overview', duration: '18:00', completed: false),
                                  _SidebarLesson(title: 'Forward Kinematics', duration: '25:40', completed: false),
                                  _SidebarLesson(title: 'Inverse Kinematics', duration: '32:15', completed: false),
                                ]),
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
}

class _NotesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lesson Notes', style: AppTypography.headlineSm.copyWith(
          color: AppColors.textOnSurface(brightness),
        )),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(brightness).withValues(alpha: 0.5),
            borderRadius: AppRadius.mdAll,
          ),
          child: Text(
            'Key concepts from this lesson:\n\n'
            '1. Kalman Filter combines predictions from a mathematical model with noisy sensor measurements.\n'
            '2. The Kalman gain determines how much we trust the prediction vs the measurement.\n'
            '3. For multi-sensor fusion, we can chain Kalman filters or use an Extended Kalman Filter (EKF).',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textOnSurfaceVariant(brightness), height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Your Notes', style: AppTypography.headlineSm.copyWith(
          color: AppColors.textOnSurface(brightness),
        )),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest(brightness),
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.border(brightness)),
          ),
          child: Text(
            'Remember to review the covariance matrix initialization for the IMU sensor fusion project.',
            style: AppTypography.bodySm.copyWith(color: AppColors.textOnSurface(brightness)),
          ),
        ),
      ],
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Supplementary Materials', style: AppTypography.headlineSm.copyWith(
          color: AppColors.textOnSurface(brightness),
        )),
        const SizedBox(height: 16),
        _MaterialItem(icon: Icons.picture_as_pdf, name: 'Kalman Filter Cheat Sheet.pdf', size: '2.1 MB'),
        const SizedBox(height: 8),
        _MaterialItem(icon: Icons.code, name: 'sensor_fusion_starter.py', size: '15 KB'),
        const SizedBox(height: 8),
        _MaterialItem(icon: Icons.dataset, name: 'sample_imu_data.csv', size: '4.8 MB'),
        const SizedBox(height: 8),
        _MaterialItem(icon: Icons.link, name: 'Reference Paper: Multi-Sensor EKF', size: 'Link'),
      ],
    );
  }
}

class _MaterialItem extends StatelessWidget {
  final IconData icon;
  final String name, size;
  const _MaterialItem({required this.icon, required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textOnSurface(brightness),
          ))),
          Text(size, style: AppTypography.bodySm.copyWith(color: AppColors.outline(brightness))),
          const SizedBox(width: 8),
          Icon(Icons.download_outlined, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}

class _QATab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Questions & Answers', style: AppTypography.headlineSm.copyWith(
          color: AppColors.textOnSurface(brightness),
        )),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest(brightness),
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.border(brightness)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.outline(brightness)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Search questions...', style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness),
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _QAItem(
          question: 'How do we handle sensor drift in the Kalman filter?',
          author: 'Binod K.',
          answers: 2,
          time: '3 hours ago',
        ),
        const SizedBox(height: 16),
        _QAItem(
          question: 'Is there a way to visualize the Kalman gain over time?',
          author: 'Sarah M.',
          answers: 1,
          time: '1 day ago',
        ),
      ],
    );
  }
}

class _QAItem extends StatelessWidget {
  final String question, author, time;
  final int answers;
  const _QAItem({required this.question, required this.author, required this.answers, required this.time});

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
          Text(question, style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textOnSurface(brightness),
          )),
          const SizedBox(height: 12),
          Row(children: [
            Text(author, style: AppTypography.bodySm.copyWith(
              color: AppColors.outline(brightness),
            )),
            const SizedBox(width: 8),
            Text('\u2022', style: TextStyle(color: AppColors.outline(brightness))),
            const SizedBox(width: 8),
            Text(time, style: AppTypography.bodySm.copyWith(
              color: AppColors.outline(brightness), fontSize: 12,
            )),
            const Spacer(),
            Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 16),
            const SizedBox(width: 4),
            Text('$answers', style: AppTypography.bodySm.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w600,
            )),
          ]),
        ],
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String title;
  final List<_SidebarLesson> lessons;
  const _SidebarSection({required this.title, required this.lessons});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: AppTypography.labelCaps.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textOnSurfaceVariant(brightness),
          )),
        ),
        ...lessons,
      ],
    );
  }
}

class _SidebarLesson extends StatelessWidget {
  final String title, duration;
  final bool completed, active;
  const _SidebarLesson({required this.title, required this.duration,
    this.completed = false, this.active = false});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: active ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : active ? Icons.play_circle : Icons.circle_outlined,
            size: 20,
            color: completed
                ? AppColors.primary
                : active
                    ? AppColors.brandOrange
                    : AppColors.outline(brightness),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTypography.bodySm.copyWith(
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active
                ? AppColors.primary
                : completed
                    ? AppColors.textOnSurfaceVariant(brightness)
                    : AppColors.textOnSurface(brightness),
          ))),
          Text(duration, style: AppTypography.labelCaps.copyWith(
            color: AppColors.outline(brightness),
            fontSize: 10,
          )),
        ],
      ),
    );
  }
}
