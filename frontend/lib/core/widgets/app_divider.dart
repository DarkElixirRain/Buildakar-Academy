import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class OrDivider extends StatelessWidget {
  final String text;

  const OrDivider({super.key, this.text = 'or continue with'});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final size = MediaQuery.of(context).size.width;
    final isSmallDevice = size < 375;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.getBackgroundSelectedColor(brightness),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.getTextSecondaryColor(brightness),
              letterSpacing: 0.5,
              fontSize: isSmallDevice ? 10 : 12,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.getBackgroundSelectedColor(brightness),
          ),
        ),
      ],
    );
  }
}
