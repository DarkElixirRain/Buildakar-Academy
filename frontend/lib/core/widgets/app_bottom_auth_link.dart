import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class AppBottomAuthLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onLinkTap;

  const AppBottomAuthLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final size = MediaQuery.of(context).size.width;
    final isSmallDevice = size < 375;

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(brightness),
              fontSize: isSmallDevice ? 14 : 15,
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: onLinkTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              linkText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.getPrimaryColor(brightness),
                fontSize: isSmallDevice ? 14 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
