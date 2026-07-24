import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class LoadingShimmer extends StatelessWidget {
  final Widget child;
  const LoadingShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant(brightness),
      highlightColor: AppColors.surfaceContainerLowest(brightness),
      child: child,
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerPlaceholder({super.key, required this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: AppRadius.cardAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerPlaceholder(width: double.infinity, height: 120, radius: 16),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerPlaceholder(width: double.infinity, height: 14, radius: 4),
                  const SizedBox(height: 6),
                  const ShimmerPlaceholder(width: 120, height: 12, radius: 4),
                  const SizedBox(height: 6),
                  const ShimmerPlaceholder(width: 60, height: 14, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCardSkeleton extends StatelessWidget {
  const CategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: Container(
        width: 100, height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: AppRadius.mdAll,
        ),
      ),
    );
  }
}

class InstructorCardSkeleton extends StatelessWidget {
  const InstructorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: Column(
        children: [
          Container(width: 64, height: 64, decoration: const BoxDecoration(
            color: Colors.white24, shape: BoxShape.circle,
          )),
          const SizedBox(height: 8),
          const ShimmerPlaceholder(width: 60, height: 12, radius: 4),
        ],
      ),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  final int count;
  const GridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const CourseCardSkeleton(),
    );
  }
}
