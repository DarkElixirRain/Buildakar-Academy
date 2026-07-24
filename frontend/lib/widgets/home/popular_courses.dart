import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class PopularCoursesSection extends StatelessWidget {
  const PopularCoursesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final courses = [
      {'title': 'Additive Manufacturing Fundamentals', 'rating': '4.9', 'price': '\$89'},
      {'title': 'Smart Grid Optimization Systems', 'rating': '4.7', 'price': '\$124'},
      {'title': 'Electronic Circuit Prototyping', 'rating': '5.0', 'price': '\$55'},
      {'title': 'AI Ethics in Industrial Design', 'rating': '4.8', 'price': '\$99'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recommended', style: AppTypography.headlineSm.copyWith(
                color: AppColors.textOnSurface(brightness),
              )),
              TextButton(
                onPressed: () {},
                child: Text('Filter', style: AppTypography.bodySm.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.62,
            ),
            itemCount: courses.length,
            itemBuilder: (_, i) => _CourseGridCard(
              title: courses[i]['title']!,
              rating: courses[i]['rating']!,
              price: courses[i]['price']!,
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseGridCard extends StatelessWidget {
  final String title, rating, price;
  const _CourseGridCard({required this.title, required this.rating, required this.price});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest(brightness),
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: AppColors.border(brightness)),
          boxShadow: AppShadow.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: AppColors.surfaceVariant(brightness),
                child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 40),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.cardTitle(context).copyWith(fontSize: 14),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 2),
                        Text(rating, style: AppTypography.numericTabular.copyWith(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: AppColors.textOnSurface(brightness),
                        )),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(price, style: AppTypography.bodyLg.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700,
                    )),
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
