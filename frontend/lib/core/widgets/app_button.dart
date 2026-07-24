import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

enum AppButtonType { primary, secondary, outlined, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool fullWidth;
  final IconData? icon;
  final bool loading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.fullWidth = true,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    Widget child = loading
        ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
            ],
          );

    Widget button;
    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: Size.fromHeight(AppSpacing.targetMin),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
          ),
          child: child,
        );
        break;
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryContainer,
            foregroundColor: Colors.white,
            minimumSize: Size.fromHeight(AppSpacing.targetMin),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
          ),
          child: child,
        );
        break;
      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: Size.fromHeight(AppSpacing.targetMin),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
          ),
          child: child,
        );
        break;
      case AppButtonType.ghost:
        button = TextButton(
          onPressed: loading ? null : onPressed,
          child: child,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class AppSocialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget icon;

  const AppSocialButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.targetMin,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
        ),
      ),
    );
  }
}
