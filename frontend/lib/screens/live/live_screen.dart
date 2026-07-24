import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/screens/live/create_live_class_screen.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Live Classes', style: AppTypography.headlineMdMobile.copyWith(
                    color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
                  )),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const CreateLiveClassScreen(),
                    )),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Schedule', style: AppTypography.labelCaps.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700,
                    )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandOrange,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live now section
                    Text('LIVE NOW', style: AppTypography.labelCaps.copyWith(
                      color: AppColors.brandRed, fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 12),
                    _LiveClassCard(
                      title: 'Advanced Sensor Fusion Workshop',
                      instructor: 'Dr. Elena Volkov',
                      students: 234,
                      isLive: true,
                      startsIn: null,
                    ),
                    const SizedBox(height: 24),
                    // Upcoming
                    Text('UPCOMING', style: AppTypography.labelCaps.copyWith(
                      color: AppColors.outline(brightness), fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 12),
                    _LiveClassCard(
                      title: 'Q&A: Kinematics & Motion Planning',
                      instructor: 'Dr. Elena Volkov',
                      students: 0,
                      isLive: false,
                      startsIn: '2:30:00',
                    ),
                    const SizedBox(height: 12),
                    _LiveClassCard(
                      title: 'Guest Lecture: AI in Robotics',
                      instructor: 'Prof. James Chen',
                      students: 0,
                      isLive: false,
                      startsIn: '1 day',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveClassCard extends StatelessWidget {
  final String title, instructor;
  final int students;
  final bool isLive;
  final String? startsIn;
  const _LiveClassCard({required this.title, required this.instructor, required this.students,
    required this.isLive, this.startsIn});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: isLive ? AppColors.brandRed.withValues(alpha: 0.3) : AppColors.border(brightness)),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (isLive) ...[
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.brandRed, shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.brandRed,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Text('LIVE', style: AppTypography.labelCaps.copyWith(
                  color: Colors.white, fontSize: 10,
                )),
              ),
            ] else ...[
              Icon(Icons.schedule_rounded, color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text('Starts in $startsIn', style: AppTypography.labelCaps.copyWith(
                color: AppColors.primary,
              )),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(brightness),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Text(isLive ? '$students watching' : 'Reminder set', style: AppTypography.labelCaps.copyWith(
                color: AppColors.textOnSurfaceVariant(brightness), fontSize: 10,
              )),
            ),
          ]),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.headlineSmMobile.copyWith(
            color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          Row(children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.surfaceVariant(brightness),
              child: Icon(Icons.person, size: 14, color: AppColors.outline(brightness)),
            ),
            const SizedBox(width: 8),
            Text(instructor, style: AppTypography.bodySm.copyWith(
              color: AppColors.outline(brightness),
            )),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isLive ? AppColors.brandRed : AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(44),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
              ),
              child: Text(isLive ? 'Join Now' : 'Set Reminder', style: AppTypography.labelCaps.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700,
              )),
            ),
          ),
        ],
      ),
    );
  }
}
