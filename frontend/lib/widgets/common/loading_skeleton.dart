import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(brightness),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header skeleton
              Row(
                children: [
                  _buildSkeletonCircle(40, brightness),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonBox(80, 12, brightness),
                        const SizedBox(height: 4),
                        _buildSkeletonBox(120, 16, brightness),
                      ],
                    ),
                  ),
                  _buildSkeletonCircle(40, brightness),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar skeleton
              _buildSkeletonBox(double.infinity, 48, brightness),
              const SizedBox(height: 24),
              // Section title skeleton
              _buildSkeletonBox(150, 20, brightness),
              const SizedBox(height: 12),
              // Horizontal scroll skeleton
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      child: _buildSkeletonBox(double.infinity, 120, brightness),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Another section
              _buildSkeletonBox(150, 20, brightness),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      child: _buildSkeletonBox(double.infinity, 200, brightness),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Grid skeleton
              _buildSkeletonBox(120, 20, brightness),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildSkeletonBox(double.infinity, double.infinity, brightness);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height, Brightness brightness) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.getBackgroundElementColor(brightness),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SizedBox(),
    );
  }

  Widget _buildSkeletonCircle(double size, Brightness brightness) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.getTextSecondaryColor(brightness),
      ),
    );
  }
}
