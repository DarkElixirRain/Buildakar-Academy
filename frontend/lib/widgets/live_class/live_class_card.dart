// lib/widgets/live_class/live_class_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class LiveClassCard extends StatelessWidget {
  final Map<String, dynamic> liveClass;
  final VoidCallback onJoin;
  final VoidCallback onRemindMe;
  final VoidCallback? onStart;
  final bool isFollowing;
  final bool isOwnClass;
  final bool isInstructor;

  const LiveClassCard({
    Key? key,
    required this.liveClass,
    required this.onJoin,
    required this.onRemindMe,
    this.onStart,
    this.isFollowing = false,
    this.isOwnClass = false,
    this.isInstructor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    // Extract data from map with safe defaults
    final title = liveClass['title']?.toString() ?? 'Untitled Class';
    final rawInstructor = liveClass['instructor'];
    final instructor = (rawInstructor != null && rawInstructor.toString().isNotEmpty)
        ? rawInstructor.toString()
        : 'Unknown Instructor';
    final thumbnail = liveClass['thumbnail']?.toString() ?? '';
    final status = liveClass['status']?.toString()?.toLowerCase() ?? 'upcoming';
    final participants = liveClass['participantsCount'] ?? 0;
    final maxParticipants = liveClass['maxParticipants'] ?? 0;
    final description = liveClass['description']?.toString() ?? '';
    final scheduledTime = liveClass['scheduledTime'];
    final category = liveClass['category']?.toString() ?? 'General';
    final isLive = status == 'live' || status == 'started' || status == 'active';

    // Format time
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

    // Determine status color and text
    Color statusColor;
    String statusText;
    switch (status) {
      case 'live':
      case 'started':
      case 'active':
        statusColor = Colors.green;
        statusText = '● LIVE';
        break;
      case 'scheduled':
      case 'upcoming':
        statusColor = Colors.blue;
        statusText = '● Upcoming';
        break;
      case 'ended':
      case 'completed':
        statusColor = Colors.grey;
        statusText = '● Ended';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = '● Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '● ${status.toUpperCase()}';
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: textSecondaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with status overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: thumbnail.isNotEmpty
                    ? Image.network(
                        thumbnail,
                        height: isSmallScreen ? 160 : 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: isSmallScreen ? 160 : 180,
                            color: primaryColor.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.videocam_rounded,
                                size: 48,
                                color: primaryColor.withOpacity(0.5),
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: isSmallScreen ? 160 : 180,
                            color: backgroundSelectedColor,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: isSmallScreen ? 160 : 180,
                        color: primaryColor.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.videocam_rounded,
                            size: 48,
                            color: primaryColor.withOpacity(0.5),
                          ),
                        ),
                      ),
              ),
              // Status badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              // "Your Class" badge (for instructor's own classes)
              if (isOwnClass)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Your Class',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Participants count
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_rounded,
                        size: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$participants/${maxParticipants > 0 ? maxParticipants : '∞'}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Category badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 15 : 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Instructor
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: textSecondaryColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        instructor,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: textSecondaryColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeString,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),

                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textSecondaryColor.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    // Remind/Follow button
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: isLive ? null : onRemindMe,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: isFollowing
                                ? Colors.green.withOpacity(0.5)
                                : textSecondaryColor.withOpacity(0.3),
                          ),
                          foregroundColor: isFollowing ? Colors.green : textSecondaryColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isFollowing
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_off_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isFollowing ? 'Remind' : 'Remind Me',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Primary action: Start (own scheduled) / Join Now (live) / disabled
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isOwnClass && isInstructor && !isLive && (status == 'scheduled' || status == 'upcoming')
                            ? onStart
                            : isLive
                                ? onJoin
                                : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: isOwnClass && isInstructor && !isLive && (status == 'scheduled' || status == 'upcoming')
                              ? Colors.blue
                              : isLive
                                  ? Colors.green
                                  : textSecondaryColor.withOpacity(0.3),
                          foregroundColor: isOwnClass && isInstructor && !isLive && (status == 'scheduled' || status == 'upcoming')
                              ? Colors.white
                              : isLive
                                  ? Colors.white
                                  : textSecondaryColor,
                          disabledBackgroundColor: textSecondaryColor.withOpacity(0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isOwnClass && isInstructor && !isLive && (status == 'scheduled' || status == 'upcoming')
                                  ? Icons.play_circle_fill_rounded
                                  : isLive
                                      ? Icons.play_arrow_rounded
                                      : Icons.meeting_room_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOwnClass && isInstructor && !isLive && (status == 'scheduled' || status == 'upcoming')
                                  ? 'Start'
                                  : isLive
                                      ? 'Join Now'
                                      : status == 'upcoming'
                                          ? 'Upcoming'
                                          : 'Ended',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
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
}