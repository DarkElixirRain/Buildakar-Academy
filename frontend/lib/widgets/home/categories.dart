import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class CategoriesSection extends StatelessWidget {
  final List<String> categories = const [
    'All Topics', 'Engineering', 'Robotics', 'Design', 'BIM', 'Business',
  ];

  CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: AppTypography.headlineSm.copyWith(
                color: AppColors.textOnSurface(brightness),
              )),
              TextButton(
                onPressed: () {},
                child: Text('View All', style: AppTypography.bodySm.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = i == 0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surfaceContainer(brightness),
                  borderRadius: AppRadius.chipAll,
                ),
                child: Center(
                  child: Text(categories[i], style: AppTypography.bodySm.copyWith(
                    color: selected ? Colors.white : AppColors.textOnSurfaceVariant(brightness),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  )),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
