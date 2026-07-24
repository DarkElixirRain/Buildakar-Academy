import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class AppBottomAuthLink extends StatelessWidget {
  final String label;
  final String actionText;
  final VoidCallback onTap;

  const AppBottomAuthLink({
    super.key,
    required this.label,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTypography.bodySm.copyWith(
            color: AppColors.textOnSurfaceVariant(brightness),
          )),
          const SizedBox(width: 4),
          Text(actionText, style: AppTypography.bodySm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}
