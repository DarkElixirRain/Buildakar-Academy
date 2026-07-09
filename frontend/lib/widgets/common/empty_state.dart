import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPress;

  const EmptyState({
    Key? key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPress, required String message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.getPrimaryColor(brightness).withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.school_outlined,
                size: 60,
                color: AppColors.getPrimaryColor(brightness),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(brightness),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondaryColor(brightness),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor(brightness),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}