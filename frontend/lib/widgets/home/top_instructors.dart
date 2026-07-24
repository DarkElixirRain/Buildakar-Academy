import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class TopInstructorsSection extends StatelessWidget {
  const TopInstructorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final instructors = ['Dr. Marcus', 'Jane Foster', 'L. Peterson', 'Arthur Day', 'Maya Lin'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
          child: Text('Top Instructors', style: AppTypography.headlineSm.copyWith(
            color: AppColors.textOnSurface(brightness),
          )),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
            itemCount: instructors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 24),
            itemBuilder: (_, i) => _InstructorAvatar(name: instructors[i]),
          ),
        ),
      ],
    );
  }
}

class _InstructorAvatar extends StatelessWidget {
  final String name;
  const _InstructorAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryContainer, width: 2),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.surfaceVariant(brightness),
            child: Text(name[0], style: AppTypography.headlineSm.copyWith(
              color: AppColors.primary,
            )),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: AppTypography.bodySm.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textOnSurface(brightness),
        )),
      ],
    );
  }
}
