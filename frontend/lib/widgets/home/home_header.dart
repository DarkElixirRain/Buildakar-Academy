import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final int notificationCount;

  const HomeHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      height: AppSpacing.navBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        border: Border(bottom: BorderSide(color: AppColors.border(brightness))),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: AppTypography.bodyMd.copyWith(color: Colors.white, fontWeight: FontWeight.w700))
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,', style: AppTypography.bodySm.copyWith(
                  color: AppColors.textOnSurfaceVariant(brightness),
                )),
                Text(userName, style: AppTypography.headlineSmMobile.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: SizedBox(
              width: AppSpacing.targetMin, height: AppSpacing.targetMin,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_outlined, color: AppColors.primary, size: 24),
                  if (notificationCount > 0)
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
