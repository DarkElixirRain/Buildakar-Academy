import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class LiveClassRoomScreen extends StatelessWidget {
  final String classId;
  const LiveClassRoomScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Advanced Sensor Fusion Workshop', style: AppTypography.bodyMd.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700,
                        )),
                        Row(children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.brandRed, shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('LIVE \u2022 234 watching', style: AppTypography.labelCaps.copyWith(
                            color: Colors.white70, fontSize: 10,
                          )),
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandRed.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.circle, color: AppColors.brandRed, size: 6),
                      const SizedBox(width: 4),
                      Text('REC', style: AppTypography.labelCaps.copyWith(
                        color: AppColors.brandRed, fontSize: 9,
                      )),
                    ]),
                  ),
                ],
              ),
            ),
            // Video area
            Expanded(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline, color: Colors.white38, size: 80),
                      SizedBox(height: 16),
                      Text('Live Stream', style: TextStyle(color: Colors.white38, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            // Chat area
            Expanded(
              child: Container(
                color: AppColors.surface(brightness),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Live Chat', style: AppTypography.labelCaps.copyWith(
                        color: AppColors.textOnSurfaceVariant(brightness), fontWeight: FontWeight.w700,
                      )),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _ChatMessage(name: 'Binod K.', message: 'Great explanation of Kalman gain!', time: '2m ago'),
                          const SizedBox(height: 12),
                          _ChatMessage(name: 'Sarah M.', message: 'Can you explain the covariance matrix update?', time: '1m ago'),
                          const SizedBox(height: 12),
                          _ChatMessage(name: 'Dr. Elena Volkov', message: 'Sure! Let me share my screen.', time: 'Just now', isInstructor: true),
                        ],
                      ),
                    ),
                    // Chat input
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface(brightness),
                        border: Border(top: BorderSide(color: AppColors.border(brightness))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant(brightness),
                                borderRadius: AppRadius.chipAll,
                              ),
                              child: Text('Type a message...', style: AppTypography.bodySm.copyWith(
                                color: AppColors.outline(brightness),
                              )),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final String name, message, time;
  final bool isInstructor;
  const _ChatMessage({required this.name, required this.message, required this.time,
    this.isInstructor = false});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isInstructor ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceVariant(brightness),
          child: Text(name[0], style: AppTypography.labelCaps.copyWith(
            color: isInstructor ? AppColors.primary : AppColors.textOnSurfaceVariant(brightness),
            fontSize: 10,
          )),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(name, style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isInstructor ? AppColors.primary : AppColors.textOnSurface(brightness),
                )),
                if (isInstructor) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Text('HOST', style: AppTypography.labelCaps.copyWith(
                      color: Colors.white, fontSize: 8,
                    )),
                  ),
                ],
                const Spacer(),
                Text(time, style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness), fontSize: 10,
                )),
              ]),
              const SizedBox(height: 4),
              Text(message, style: AppTypography.bodySm.copyWith(
                color: AppColors.textOnSurfaceVariant(brightness),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
