import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class AppSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;

  const AppSuccessDialog({super.key, required this.title, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest(brightness),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetAll),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 36),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.headlineSm.copyWith(
              color: AppColors.textOnSurface(brightness),
            )),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: AppTypography.bodySm.copyWith(
              color: AppColors.textOnSurfaceVariant(brightness),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: onDismiss ?? () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                ),
                child: Text('Done', style: AppTypography.bodyMd.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showAppSuccessDialog(BuildContext context, {required String title, required String message, VoidCallback? onDismiss}) {
  showDialog(context: context, builder: (_) => AppSuccessDialog(title: title, message: message, onDismiss: onDismiss));
}
