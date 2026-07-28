
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class LiveLoadingSkeleton extends StatefulWidget {
  const LiveLoadingSkeleton({Key? key}) : super(key: key);

  @override
  State<LiveLoadingSkeleton> createState() => _LiveLoadingSkeletonState();
}

class _LiveLoadingSkeletonState extends State<LiveLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final screenWidth = MediaQuery.of(context).size.width;

    final double horizontalPadding = screenWidth < 480 ? 16 : (screenWidth < 900 ? 24 : 40);

    int columns;
    double aspectRatio;
    if (screenWidth < 480) {
      columns = 1;
      aspectRatio = 1.08;
    } else if (screenWidth < 780) {
      columns = 2;
      aspectRatio = 0.80;
    } else if (screenWidth < 1100) {
      columns = 3;
      aspectRatio = 0.82;
    } else {
      columns = 4;
      aspectRatio = 0.84;
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _Shimmer(
            controller: _controller,
            brightness: brightness,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Box(width: 150, height: 26),
                const SizedBox(height: 8),
                const _Box(width: 190, height: 14),
                const SizedBox(height: 20),
                const _Box(width: double.infinity, height: 52, radius: 16),
                const SizedBox(height: 16),
                const _Box(width: double.infinity, height: 50, radius: 14),
                const SizedBox(height: 20),
                _Box(width: double.infinity, height: screenWidth >= 700 ? 220 : 260, radius: 20),
                const SizedBox(height: 22),
                const _Box(width: 130, height: 16),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: columns * 2,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: aspectRatio,
                  ),
                  itemBuilder: (context, i) => const _SkeletonCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final AnimationController controller;
  final Brightness brightness;
  final Widget child;
  const _Shimmer({required this.controller, required this.brightness, required this.child});

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.getBackgroundElementColor(brightness);
    final highlightColor = AppColors.getBackgroundSelectedColor(brightness);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1.0 - 2 * t, -0.3),
              end: Alignment(1.0 - 2 * t, 0.3),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Box({required this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 16 / 10, child: ColoredBox(color: Colors.white)),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(width: 60, height: 10),
                SizedBox(height: 8),
                _Box(width: double.infinity, height: 14),
                SizedBox(height: 6),
                _Box(width: 100, height: 12),
                SizedBox(height: 10),
                _Box(width: double.infinity, height: 36, radius: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}