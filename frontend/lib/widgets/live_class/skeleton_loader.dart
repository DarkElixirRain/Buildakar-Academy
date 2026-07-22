// lib/widgets/live_class/skeleton_loader.dart
//
// Reusable shimmer effect + skeleton placeholders used while
// live class data is loading. Drop-in replacement for a plain
// CircularProgressIndicator so the first load feels instant and
// matches the final layout (no jarring content jump).

import 'package:flutter/material.dart';

/// Wraps [child] in a moving shimmer highlight, looping forever.
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerEffect({
    Key? key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final slide = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1.0 - slide * 2, -0.2),
              end: Alignment(1.0 - slide * 2, 0.2),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single rounded skeleton block.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color color;

  const SkeletonBox({
    Key? key,
    this.width,
    required this.height,
    this.radius = 8,
    required this.color,
  }) : super(key: key);

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

/// Skeleton placeholder shaped like [LiveClassCard] so the loading
/// state lines up pixel-for-pixel with the real content.
class SkeletonLiveClassCard extends StatelessWidget {
  final bool isDark;

  const SkeletonLiveClassCard({Key? key, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xFF2A2C34) : const Color(0xFFE7E9EE);
    final highlightColor = isDark ? const Color(0xFF3A3D48) : const Color(0xFFF6F7F9);
    final cardColor = isDark ? const Color(0xFF1E2028) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: ShimmerEffect(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: SkeletonBox(height: double.infinity, radius: 14, color: baseColor),
            ),
            const SizedBox(height: 14),
            SkeletonBox(width: double.infinity, height: 16, color: baseColor),
            const SizedBox(height: 8),
            SkeletonBox(width: 130, height: 12, color: baseColor),
            const SizedBox(height: 16),
            Row(
              children: [
                SkeletonBox(width: 28, height: 28, radius: 14, color: baseColor),
                const SizedBox(width: 8),
                SkeletonBox(width: 80, height: 12, color: baseColor),
                const Spacer(),
                SkeletonBox(width: 72, height: 34, radius: 10, color: baseColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A full skeleton grid/list, mirroring the real content layout so
/// swapping skeleton -> real data causes no layout shift.
class SkeletonLiveClassList extends StatelessWidget {
  final bool isDark;
  final bool isGrid;
  final int crossAxisCount;
  final double horizontalPadding;
  final int itemCount;

  const SkeletonLiveClassList({
    Key? key,
    required this.isDark,
    required this.isGrid,
    required this.crossAxisCount,
    required this.horizontalPadding,
    this.itemCount = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isGrid) {
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonLiveClassCard(isDark: isDark),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonLiveClassCard(isDark: isDark),
    );
  }
}

/// A small pulsing dot, used for the "LIVE" indicator. Fixes the
/// previous implementation which built a TweenAnimationBuilder that
/// never actually looped and was visually static.
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({Key? key, required this.color, this.size = 8}) : super(key: key);

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + _controller.value * 0.6;
        final opacity = 1.0 - _controller.value * 0.7;
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withAlpha((255 * opacity * 0.5).toInt()),
                ),
              ),
            ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
            ),
          ],
        );
      },
    );
  }
}