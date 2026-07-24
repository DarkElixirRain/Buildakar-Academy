import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border(brightness))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or continue with', style: AppTypography.bodySm.copyWith(
            color: AppColors.outline(brightness),
          )),
        ),
        Expanded(child: Divider(color: AppColors.border(brightness))),
      ],
    );
  }
}
