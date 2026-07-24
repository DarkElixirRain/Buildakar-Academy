import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showNumber;

  const RatingStars({super.key, required this.rating, this.size = 16, this.showNumber = true});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final filled = i < rating.floor();
          final half = !filled && i < rating;
          return Icon(
            filled ? Icons.star : (half ? Icons.star_half : Icons.star_border),
            size: size,
            color: const Color(0xFFF59E0B),
          );
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(rating.toStringAsFixed(1), style: AppTypography.numericTabular.copyWith(
            fontSize: size * 0.8,
            color: AppColors.textOnSurface(brightness),
            fontWeight: FontWeight.w600,
          )),
        ],
      ],
    );
  }
}
