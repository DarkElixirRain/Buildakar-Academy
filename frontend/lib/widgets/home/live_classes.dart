import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class LiveClassesSection extends StatelessWidget {
  const LiveClassesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Classes', style: AppTypography.headlineSm.copyWith(
                color: AppColors.textOnSurface(brightness),
              )),
              Row(
                children: [
                  _dot(AppColors.primary), const SizedBox(width: 4),
                  _dot(AppColors.surfaceVariant(brightness)), const SizedBox(width: 4),
                  _dot(AppColors.surfaceVariant(brightness)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
            children: [
              _LiveClassCard(
                title: 'Collaborative Robotics Lab',
                instructor: 'Dr. Sarah Chen',
                viewers: '2.4k',
                isLive: true,
              ),
              const SizedBox(width: 16),
              _LiveClassCard(
                title: 'Sustainable Urban Design',
                instructor: 'Prof. Julian Vane',
                viewers: '1.1k',
                isLive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot(Color c) => Container(width: 6, height: 6, decoration: BoxDecoration(
    color: c, shape: BoxShape.circle,
  ));
}

class _LiveClassCard extends StatelessWidget {
  final String title, instructor, viewers;
  final bool isLive;

  const _LiveClassCard({
    required this.title, required this.instructor, required this.viewers, required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      width: 288,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadow.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          SizedBox(
            height: 140,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.surfaceVariant(brightness)),
                if (isLive) Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text('LIVE', style: AppTypography.labelCaps.copyWith(
                          color: Colors.white, fontSize: 10,
                        )),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.groups, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('$viewers watching', style: AppTypography.bodySm.copyWith(
                          color: Colors.white, fontSize: 11,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnSurface(brightness),
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(instructor, style: AppTypography.bodySm.copyWith(
                  color: AppColors.textOnSurfaceVariant(brightness),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
