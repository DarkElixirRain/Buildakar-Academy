import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class ContinueLearning extends StatelessWidget {
  const ContinueLearning({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest(brightness),
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: AppColors.border(brightness)),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Continue Learning', style: AppTypography.headlineSm.copyWith(
                  color: AppColors.textOnSurface(brightness),
                )),
                Icon(Icons.more_vert, color: AppColors.outline(brightness)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Thumbnail
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(brightness),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_outline, color: AppColors.primary, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MODULE 4: STRUCTURAL ANALYSIS', style: AppTypography.labelCaps.copyWith(
                        color: AppColors.primary,
                      )),
                      const SizedBox(height: 4),
                      Text('Advanced BIM Integration', style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOnSurface(brightness),
                      )),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: 0.75,
                                backgroundColor: AppColors.surfaceVariant(brightness),
                                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('75%', style: AppTypography.numericTabular.copyWith(
                            fontSize: 12, color: AppColors.outline(brightness),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text('Resume Learning', style: AppTypography.bodyMd.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700,
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryContainer,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
