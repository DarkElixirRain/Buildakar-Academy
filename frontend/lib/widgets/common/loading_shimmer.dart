// lib/widgets/common/loading_shimmer.dart

import 'package:flutter/material.dart';

/// A shimmer loading effect widget for loading states
class LoadingShimmer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const LoadingShimmer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(duration: duration, curve: curve, child: child);
  }
}

/// A widget that applies a shimmer effect to its child
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const Shimmer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();

    _animation = Tween<double>(
      begin: -0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(animation: _animation, child: widget.child);
  }
}

/// The actual shimmer widget that applies the gradient effect
class ShimmerWidget extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const ShimmerWidget({Key? key, required this.animation, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDark = brightness == Brightness.dark;

        final baseColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
        final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + animation.value * 2, 0.0),
              end: Alignment(1.0 + animation.value * 2, 0.0),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

/// A simple shimmer loading placeholder
class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isDark;

  const ShimmerPlaceholder({
    Key? key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final dark = isDark ? true : brightness == Brightness.dark;

    return LoadingShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A skeleton loading widget for course cards
class CourseCardSkeleton extends StatelessWidget {
  final bool isDark;

  const CourseCardSkeleton({Key? key, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3D4045) : const Color(0xFFD1D5DB),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D4045)
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D4045)
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D4045)
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3D4045)
                                  : const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 30,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3D4045)
                                  : const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 50,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D4045)
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
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

/// A skeleton loading widget for category cards
class CategoryCardSkeleton extends StatelessWidget {
  final bool isDark;

  const CategoryCardSkeleton({Key? key, required this.isDark})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 120,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3D4045) : const Color(0xFFD1D5DB),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3D4045)
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 60,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3D4045)
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A skeleton loading widget for instructor cards
class InstructorCardSkeleton extends StatelessWidget {
  final bool isDark;

  const InstructorCardSkeleton({Key? key, required this.isDark})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF3D4045) : const Color(0xFFD1D5DB),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3D4045) : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3D4045) : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

/// A skeleton loading widget for a grid of items
class GridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool isDark;

  const GridSkeleton({
    Key? key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return CourseCardSkeleton(isDark: isDark);
      },
    );
  }
}

/// A skeleton loading widget for a list of items
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final bool isDark;

  const ListSkeleton({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 120,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: itemHeight,
            child: CourseCardSkeleton(isDark: isDark),
          ),
        );
      }),
    );
  }
}
