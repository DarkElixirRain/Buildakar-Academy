import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class LiveClasses extends StatelessWidget {
  final List<Map<String, dynamic>> classes;
  final Function(String) onJoinPress;
  final VoidCallback onSeeAll;
  final String? currentUserId;
  final Function(String)? onEndPress;

  const LiveClasses({
    Key? key,
    required this.classes,
    required this.onJoinPress,
    required this.onSeeAll,
    this.currentUserId,
    this.onEndPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final textColor = AppColors.getTextColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);

    final screenWidth = MediaQuery.of(context).size.width;

    if (classes.isEmpty) {
      return _buildEmptyState(isDark, brightness);
    }

    double cardWidth;
    double cardHeight;

    if (screenWidth < 380) {
      cardWidth = screenWidth * 0.75;
      cardHeight = 280;
    } else if (screenWidth < 600) {
      cardWidth = screenWidth * 0.60;
      cardHeight = 290;
    } else if (screenWidth < 900) {
      cardWidth = screenWidth * 0.38;
      cardHeight = 300;
    } else {
      cardWidth = screenWidth * 0.25;
      cardHeight = 310;
    }
    cardWidth = cardWidth.clamp(160.0, 380.0);
    cardHeight = cardHeight.clamp(240.0, 350.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.getErrorColor(brightness)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.video_camera_front, size: screenWidth < 380 ? 18 : 20, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Live Classes',
                      style: TextStyle(fontSize: screenWidth < 380 ? 18 : 20, fontWeight: FontWeight.bold, color: textColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: TextStyle(fontSize: screenWidth < 380 ? 12 : 14, fontWeight: FontWeight.w600, color: primaryColor),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight + 10,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: classes.length,
            padding: const EdgeInsets.only(right: 16),
            itemBuilder: (context, index) {
              final classItem = classes[index];
              final isLast = index == classes.length - 1;
              return _buildClassCard(context, classItem, isLast, cardWidth, cardHeight, isDark, brightness);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    Map<String, dynamic> classItem,
    bool isLast,
    double cardWidth,
    double cardHeight,
    bool isDark,
    Brightness brightness,
  ) {
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);

    final status = (classItem['status'] as String?)?.toLowerCase() ?? 'upcoming';
    final isLive = status == 'live';
    final isOwnClass = currentUserId != null && classItem['instructorId'] == currentUserId;

    final title = classItem['title']?.toString() ?? 'Untitled Class';
    final instructor = classItem['instructor']?.toString() ?? 'Instructor';
    final thumbnail = classItem['thumbnail']?.toString() ?? classItem['image']?.toString() ?? '';
    final category = classItem['category']?.toString() ?? 'General';
    final participants = classItem['participantsCount'] ?? classItem['attendees'] ?? 0;
    final maxParticipants = classItem['maxParticipants'] ?? 0;
    final scheduledTime = classItem['scheduledTime'];

    String timeString = 'Time TBD';
    if (scheduledTime != null) {
      try {
        DateTime time;
        if (scheduledTime is DateTime) {
          time = scheduledTime;
        } else if (scheduledTime is String) {
          time = DateTime.parse(scheduledTime);
        } else {
          time = DateTime.now();
        }
        timeString = DateFormat('MMM d, h:mm a').format(time);
      } catch (_) {
        timeString = 'Time TBD';
      }
    }

    Color statusColor;
    String statusText;
    switch (status) {
      case 'live':
        statusColor = AppColors.getSuccessColor(brightness);
        statusText = 'LIVE';
        break;
      case 'scheduled':
      case 'upcoming':
        statusColor = primaryColor;
        statusText = 'Upcoming';
        break;
      case 'ended':
      case 'completed':
        statusColor = textSecondaryColor;
        statusText = 'Ended';
        break;
      case 'cancelled':
        statusColor = AppColors.getErrorColor(brightness);
        statusText = 'Cancelled';
        break;
      default:
        statusColor = textSecondaryColor;
        statusText = status.toUpperCase();
    }

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.only(right: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textSecondaryColor.withAlpha(30), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                thumbnail.isNotEmpty
                    ? Image.network(
                        thumbnail,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(primaryColor),
                      )
                    : _fallback(primaryColor),
                // Status badge - top left
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(190),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withAlpha(120), width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor, letterSpacing: 0.5),
                    ),
                  ),
                ),
                // "Your Class" badge for own classes
                if (isOwnClass)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.withAlpha(220), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school_rounded, size: 10, color: Colors.white),
                          const SizedBox(width: 2),
                          Text('Your Class', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                // Category - bottom left
                Positioned(
                  bottom: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: primaryColor.withAlpha(220), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      category,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Participants count - bottom right
                Positioned(
                  bottom: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withAlpha(190), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_rounded, size: 12, color: Colors.white.withAlpha(220)),
                        const SizedBox(width: 3),
                        Text(
                          '$participants/${maxParticipants > 0 ? maxParticipants : '\u221E'}',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withAlpha(220)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor, height: 1.2),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 12, color: textSecondaryColor.withAlpha(130)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        instructor,
                        style: TextStyle(fontSize: 11, color: textSecondaryColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 12, color: textSecondaryColor.withAlpha(130)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        timeString,
                        style: TextStyle(fontSize: 11, color: textSecondaryColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Remind/End button
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: isOwnClass && isLive
                            ? () => onEndPress?.call(classItem['id']?.toString() ?? '')
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          side: BorderSide(
                            color: isOwnClass && isLive ? Colors.red.withAlpha(100) : textSecondaryColor.withAlpha(50),
                          ),
                          foregroundColor: isOwnClass && isLive ? Colors.red : textSecondaryColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOwnClass && isLive ? Icons.stop_circle_outlined : Icons.notifications_off_rounded,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                isOwnClass && isLive ? 'End' : 'Remind',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Join button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isLive ? () => onJoinPress(classItem['id']?.toString() ?? '') : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          backgroundColor: isLive ? Colors.green : textSecondaryColor.withAlpha(50),
                          foregroundColor: isLive ? Colors.white : textSecondaryColor,
                          disabledBackgroundColor: textSecondaryColor.withAlpha(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLive ? Icons.play_arrow_rounded : Icons.meeting_room_rounded,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                isLive ? 'Join' : status == 'upcoming' ? 'Soon' : 'Ended',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(50), color.withAlpha(20)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.videocam_rounded, size: 32, color: color.withAlpha(100)),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Brightness brightness) {
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
              ),
              const SizedBox(width: 8),
              Icon(Icons.video_camera_front, size: 20, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'Live Classes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: backgroundElementColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: backgroundSelectedColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_camera_front_outlined, size: 48, color: textSecondaryColor),
              const SizedBox(height: 8),
              Text(
                'No live classes available',
                style: TextStyle(fontSize: 14, color: textSecondaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for upcoming sessions',
                style: TextStyle(fontSize: 12, color: textSecondaryColor.withAlpha(180)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
