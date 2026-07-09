// lib/widgets/explore/explore_loading_skeleton.dart
//
// A skeleton loader that mirrors the *actual* Explore layout (title,
// search bar, category chips, result-count row, responsive card grid)
// instead of a generic placeholder — so there's no layout "jump" when
// real data comes in. Includes a subtle shimmer sweep and adapts to
// light/dark mode plus the same responsive breakpoints as CourseGrid.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ExploreLoadingSkeleton extends StatefulWidget {
  const ExploreLoadingSkeleton({Key? key}) : super(key: key);

  @override
  State<ExploreLoadingSkeleton> createState() => _ExploreLoadingSkeletonState();
}

class _ExploreLoadingSkeletonState extends State<ExploreLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final screenWidth = MediaQuery.of(context).size.width;

    final double horizontalPadding = screenWidth < 480
        ? 16
        : screenWidth < 900
            ? 24
            : 40;

    // Get theme-aware skeleton colors
    final backgroundColor = isDark ? const Color(0xFF121417) : const Color(0xFFF7F8FA);
    final baseColor = isDark ? const Color(0xFF2A2E37) : const Color(0xFFE9EBEF);
    final highlightColor = isDark ? const Color(0xFF3A3F4B) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1C1F26) : Colors.white;

    int columns;
    double aspectRatio;
    bool singleColumnList = false;
    if (screenWidth < 480) {
      singleColumnList = true;
      columns = 1;
      aspectRatio = 1;
    } else if (screenWidth < 780) {
      columns = 2;
      aspectRatio = 0.66;
    } else if (screenWidth < 1100) {
      columns = 3;
      aspectRatio = 0.70;
    } else {
      columns = 4;
      aspectRatio = 0.72;
    }

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: _Shimmer(
              controller: _controller,
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + subtitle - matches explore header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(
                            width: screenWidth < 600 ? 120 : 160,
                            height: screenWidth < 600 ? 26 : 32,
                            radius: 8,
                            color: baseColor,
                          ),
                          const SizedBox(height: 8),
                          _SkeletonBox(
                            width: screenWidth < 600 ? 150 : 200,
                            height: screenWidth < 600 ? 14 : 16,
                            radius: 6,
                            color: baseColor,
                          ),
                        ],
                      ),
                      // Course count badge on large screens
                      if (screenWidth > 900)
                        _SkeletonBox(
                          width: 100,
                          height: 36,
                          radius: 20,
                          color: baseColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search bar + filter button (matches explore layout)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _SkeletonBox(
                          width: double.infinity,
                          height: 52,
                          radius: 16,
                          color: baseColor,
                        ),
                      ),
                      // Sort dropdown on large screens
                      if (screenWidth > 780) ...[
                        const SizedBox(width: 12),
                        _SkeletonBox(
                          width: 160,
                          height: 52,
                          radius: 16,
                          color: baseColor,
                        ),
                      ],
                      if (screenWidth <= 780) ...[
                        const SizedBox(width: 10),
                        _SkeletonBox(
                          width: 52,
                          height: 52,
                          radius: 16,
                          color: baseColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category chips (matches explore)
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) => _SkeletonBox(
                        width: [70.0, 110.0, 90.0, 100.0, 80.0, 95.0][i % 6],
                        height: 42,
                        radius: 24,
                        color: baseColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Result count + sort row (matches explore)
                  Row(
                    children: [
                      _SkeletonBox(
                        width: screenWidth < 480 ? 70 : 90,
                        height: 13,
                        radius: 4,
                        color: baseColor,
                      ),
                      const Spacer(),
                      if (screenWidth <= 780)
                        _SkeletonBox(
                          width: 100,
                          height: 13,
                          radius: 4,
                          color: baseColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card grid / list - wrapped in Container with cardColor background
                  Container(
                    color: backgroundColor,
                    child: singleColumnList
                        ? Column(
                            children: List.generate(
                              4,
                              (i) => Padding(
                                padding: EdgeInsets.only(bottom: i == 3 ? 0 : 12),
                                child: _SkeletonListCard(
                                  color: cardColor,
                                  baseColor: baseColor,
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: columns * 3,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: aspectRatio,
                            ),
                            itemBuilder: (context, i) => _SkeletonGridCard(
                              color: cardColor,
                              baseColor: baseColor,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Shimmer sweep: paints a moving highlight gradient over all the
/// skeleton boxes beneath it via ShaderMask.
/// ---------------------------------------------------------------------
class _Shimmer extends StatelessWidget {
  final AnimationController controller;
  final Color baseColor;
  final Color highlightColor;
  final Widget child;

  const _Shimmer({
    required this.controller,
    required this.baseColor,
    required this.highlightColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        // Create a gradient that sweeps across the entire widget
        final gradient = LinearGradient(
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.35, 0.5, 0.65],
          begin: Alignment(-1.0 - 2 * t, -0.3),
          end: Alignment(1.0 - 2 * t, 0.3),
        );
        
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: child,
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// Skeleton box with theme-aware color
/// ---------------------------------------------------------------------
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Grid card skeleton with theme-aware colors
/// ---------------------------------------------------------------------
class _SkeletonGridCard extends StatelessWidget {
  final Color color;
  final Color baseColor;

  const _SkeletonGridCard({
    required this.color,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail skeleton
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              color: baseColor,
            ),
          ),
          // Content skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: 60,
                  height: 10,
                  radius: 4,
                  color: baseColor,
                ),
                const SizedBox(height: 8),
                _SkeletonBox(
                  width: double.infinity,
                  height: 14,
                  radius: 4,
                  color: baseColor,
                ),
                const SizedBox(height: 6),
                _SkeletonBox(
                  width: 100,
                  height: 12,
                  radius: 4,
                  color: baseColor,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _SkeletonBox(
                      width: 40,
                      height: 12,
                      radius: 4,
                      color: baseColor,
                    ),
                    const Spacer(),
                    _SkeletonBox(
                      width: 44,
                      height: 16,
                      radius: 4,
                      color: baseColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// List card skeleton with theme-aware colors
/// ---------------------------------------------------------------------
class _SkeletonListCard extends StatelessWidget {
  final Color color;
  final Color baseColor;

  const _SkeletonListCard({
    required this.color,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail skeleton
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 96,
              height: 96,
              child: Container(
                color: baseColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: 70,
                  height: 18,
                  radius: 8,
                  color: baseColor,
                ),
                const SizedBox(height: 8),
                _SkeletonBox(
                  width: double.infinity,
                  height: 14,
                  radius: 4,
                  color: baseColor,
                ),
                const SizedBox(height: 6),
                _SkeletonBox(
                  width: 90,
                  height: 12,
                  radius: 4,
                  color: baseColor,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _SkeletonBox(
                      width: 40,
                      height: 12,
                      radius: 4,
                      color: baseColor,
                    ),
                    const Spacer(),
                    _SkeletonBox(
                      width: 44,
                      height: 16,
                      radius: 4,
                      color: baseColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}