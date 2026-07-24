import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'Popular';

  final categories = ['All', 'Engineering', 'Robotics', 'Design', 'BIM', 'Business'];
  final courses = [
    {'title': 'Additive Manufacturing Fundamentals', 'instructor': 'Dr. Marcus', 'rating': '4.9', 'price': '\$89', 'level': 'Beginner'},
    {'title': 'Smart Grid Optimization Systems', 'instructor': 'Jane Foster', 'rating': '4.7', 'price': '\$124', 'level': 'Advanced'},
    {'title': 'Electronic Circuit Prototyping', 'instructor': 'L. Peterson', 'rating': '5.0', 'price': '\$55', 'level': 'Intermediate'},
    {'title': 'AI Ethics in Industrial Design', 'instructor': 'Arthur Day', 'rating': '4.8', 'price': '\$99', 'level': 'Beginner'},
    {'title': 'Structural Analysis Methods', 'instructor': 'Dr. Marcus', 'rating': '4.6', 'price': '\$79', 'level': 'Advanced'},
    {'title': 'Robotics Motion Planning', 'instructor': 'Jane Foster', 'rating': '4.9', 'price': '\$110', 'level': 'Intermediate'},
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 8),
            child: Text('Explore', style: AppTypography.headlineMd.copyWith(
              color: AppColors.textOnSurface(brightness),
            )),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = categories[i] == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = categories[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceContainer(brightness),
                      borderRadius: AppRadius.chipAll,
                    ),
                    child: Center(child: Text(categories[i], style: AppTypography.bodySm.copyWith(
                      color: selected ? Colors.white : AppColors.textOnSurfaceVariant(brightness),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ))),
                  ),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _ExploreCourseCard(
                title: courses[i]['title']!,
                instructor: courses[i]['instructor']!,
                rating: double.parse(courses[i]['rating']!),
                price: courses[i]['price']!,
                level: courses[i]['level']!,
              ),
              childCount: courses.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _ExploreCourseCard extends StatelessWidget {
  final String title, instructor, price, level;
  final double rating;

  const _ExploreCourseCard({
    required this.title, required this.instructor, required this.rating,
    required this.price, required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/home', arguments: {'courseId': '1'}),
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
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Container(
                    color: AppColors.surfaceVariant(brightness),
                    child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 36),
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface(brightness).withValues(alpha: 0.9),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(level, style: AppTypography.labelCaps.copyWith(
                      color: AppColors.textOnSurfaceVariant(brightness),
                    )),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.cardTitle(context).copyWith(fontSize: 14),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Text(instructor, style: AppTypography.bodySm.copyWith(
                      color: AppColors.textOnSurfaceVariant(brightness), fontSize: 12,
                    )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 2),
                        Text(rating.toStringAsFixed(1), style: AppTypography.numericTabular.copyWith(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: AppColors.textOnSurface(brightness),
                        )),
                        const Spacer(),
                        Text(price, style: AppTypography.priceText(brightness: brightness).copyWith(fontSize: 15)),
                      ],
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
