import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/screens/course/course_detail_screen.dart';
import 'package:buildacad/widgets/common/rating_stars.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  const CategoryDetailScreen({super.key, required this.categoryName});

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
        title: Text(categoryName, style: AppTypography.headlineSmMobile.copyWith(
          color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
        )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('156 courses available', style: AppTypography.bodySm.copyWith(
              color: AppColors.outline(brightness),
            )),
            const SizedBox(height: 16),
            // Sort/filter row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(brightness),
                    borderRadius: AppRadius.chipAll,
                  ),
                  child: Row(children: [
                    Icon(Icons.sort, size: 16, color: AppColors.textOnSurfaceVariant(brightness)),
                    const SizedBox(width: 4),
                    Text('Most Popular', style: AppTypography.bodySm.copyWith(
                      color: AppColors.textOnSurfaceVariant(brightness),
                    )),
                  ]),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(brightness),
                    borderRadius: AppRadius.chipAll,
                  ),
                  child: Row(children: [
                    Icon(Icons.filter_list, size: 16, color: AppColors.textOnSurfaceVariant(brightness)),
                    const SizedBox(width: 4),
                    Text('Filter', style: AppTypography.bodySm.copyWith(
                      color: AppColors.textOnSurfaceVariant(brightness),
                    )),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Course list
            ...List.generate(5, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryCourseCard(
                title: '$categoryName Fundamentals ${i + 1}',
                instructor: ['Dr. Elena Volkov', 'Prof. James Chen', 'Dr. Aisha Patel'][i % 3],
                rating: 4.8 - (i * 0.1),
                students: '${(85 - i * 12).toString()}k',
                price: '\$${49 + i * 10}.99',
                isBestseller: i == 0,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(courseId: '${i + 1}'),
                )),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _CategoryCourseCard extends StatelessWidget {
  final String title, instructor, students, price;
  final double rating;
  final bool isBestseller;
  final VoidCallback onTap;
  const _CategoryCourseCard({required this.title, required this.instructor, required this.rating,
    required this.students, required this.price, required this.isBestseller, required this.onTap});

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
              child: const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(title, style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600, color: AppColors.textOnSurface(brightness),
                    ))),
                    if (isBestseller) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.brandOrange,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Text('BEST', style: AppTypography.labelCaps.copyWith(
                        color: Colors.white, fontSize: 8,
                      )),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(instructor, style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline(brightness), fontSize: 12,
                  )),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(rating.toStringAsFixed(1), style: AppTypography.numericTabular.copyWith(
                      fontWeight: FontWeight.w700, color: AppColors.textOnSurface(brightness), fontSize: 13,
                    )),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 8),
                    Text('$students students', style: AppTypography.bodySm.copyWith(
                      color: AppColors.outline(brightness), fontSize: 11,
                    )),
                  ]),
                  const SizedBox(height: 4),
                  Text(price, style: AppTypography.headlineSmMobile.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
