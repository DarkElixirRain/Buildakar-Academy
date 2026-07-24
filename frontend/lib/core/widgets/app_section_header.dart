import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const AppSectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.headlineSm.copyWith(
          color: AppColors.textOnSurface(brightness),
        )),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text('View All', style: AppTypography.bodySm.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w600,
            )),
          ),
      ],
    );
  }
}
