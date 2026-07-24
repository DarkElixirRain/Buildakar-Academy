import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? width;

  const AppCard({super.key, required this.child, this.padding, this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest(brightness),
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: AppColors.border(brightness), width: 1),
          boxShadow: AppShadow.card,
        ),
        child: child,
      ),
    );
  }
}

class AppStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? trend;
  final bool trendUp;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.trend,
    this.trendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      width: 160,
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
          Text(label.toUpperCase(), style: AppTypography.labelCaps.copyWith(
            color: AppColors.textOnSurfaceVariant(brightness),
          )),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(value, style: AppTypography.numericTabular.copyWith(
                  fontSize: 20,
                  color: AppColors.textOnSurface(brightness),
                )),
              ),
              if (trend != null)
                Icon(
                  trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: trendUp ? AppColors.primary : AppColors.error,
                ),
            ],
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Text(trend!, style: AppTypography.bodySm.copyWith(
              color: trendUp ? AppColors.primary : AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            )),
          ],
        ],
      ),
    );
  }
}
