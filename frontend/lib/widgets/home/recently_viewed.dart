import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class RecentlyViewed extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Function(String) onCoursePress;

  const RecentlyViewed({
    Key? key,
    required this.courses,
    required this.onCoursePress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Recently Viewed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(brightness),
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildRecentCard(context, course);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCard(BuildContext context, Map<String, dynamic> course) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onCoursePress(course['id']),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundElementColor(brightness),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.getBackgroundSelectedColor(brightness),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                course['image'],
                height: 60,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 60,
                    color: AppColors.getPrimaryColor(brightness).withValues(alpha: 0.2),
                    child: Icon(Icons.image, color: AppColors.getTextSecondaryColor(brightness), size: 24),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(brightness),
                    ),
                  ),
                  const SizedBox(height: 2),
                  LinearProgressIndicator(
                    value: course['progress'],
                    backgroundColor: AppColors.getBackgroundSelectedColor(brightness),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.getPrimaryColor(brightness),
                    ),
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}