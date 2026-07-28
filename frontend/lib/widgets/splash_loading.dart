import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SplashLoading extends StatelessWidget {
  const SplashLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primaryColor = AppColors.getPrimaryColor(brightness);

    return SizedBox(
      width: 160,
      child: LinearProgressIndicator(
        backgroundColor: AppColors.getBackgroundElementColor(brightness),
        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        minHeight: 3,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
