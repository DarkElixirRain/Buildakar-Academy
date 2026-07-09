// lib/widgets/live_class/live_class_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/live_class_model.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class LiveClassCard extends StatelessWidget {
  final Map<String, dynamic> liveClass;
  final VoidCallback onJoin;
  final VoidCallback onRemindMe;
  final bool isFollowing;

  const LiveClassCard({
    Key? key,
    required this.liveClass,
    required this.onJoin,
    required this.onRemindMe,
    this.isFollowing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    
    // Extract data from map
    final title = liveClass['title'] ?? 'Untitled Class';
    final instructor = liveClass['instructor'] ?? 'Unknown Instructor';
    final thumbnail = liveClass['thumbnail'] ?? '';
    final status = liveClass['status'] ?? 'upcoming';
    final participants = liveClass['participantsCount'] ?? 0;
    final maxParticipants = liveClass['maxParticipants'] ?? 0;
    final description = liveClass['description'] ?? '';
    final scheduledTime = liveClass['scheduledTime'];
    final category = liveClass['category'] ?? 'General';
    
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
    switch (status.toLowerCase()) {
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

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textSecondaryColor.withAlpha(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                            color: primaryColor.withAlpha(50),
                            child: Center(
                              child: Icon(
                                Icons.videocam_rounded,
                                size: 48,
                                color: primaryColor.withAlpha(100),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: isSmallScreen ? 160 : 180,
                        color: primaryColor.withAlpha(50),
                        child: Center(
                          child: Icon(
                            Icons.videocam_rounded,
                            size: 48,
                            color: primaryColor.withAlpha(100),
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
                    color: Colors.black.withAlpha(180),
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
              // Participants count
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_rounded,
                        size: 14,
                        color: Colors.white.withAlpha(200),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$participants/${maxParticipants > 0 ? maxParticipants : '∞'}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withAlpha(200),
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
                    color: primaryColor.withAlpha(200),
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
                      color: textSecondaryColor.withAlpha(150),
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
                      color: textSecondaryColor.withAlpha(150),
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
                      color: textSecondaryColor.withAlpha(180),
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
                      child: OutlinedButton.icon(
                        onPressed: onRemindMe,
                        icon: Icon(
                          isFollowing 
                              ? Icons.notifications_active_rounded 
                              : Icons.notifications_off_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isFollowing ? 'Remind' : 'Remind Me',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: isFollowing 
                                ? Colors.green.withAlpha(100) 
                                : textSecondaryColor.withAlpha(50),
                          ),
                          foregroundColor: isFollowing ? Colors.green : textSecondaryColor,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Join button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: onJoin,
                        icon: Icon(
                          status.toLowerCase() == 'live' 
                              ? Icons.play_arrow_rounded 
                              : Icons.meeting_room_rounded,
                          size: 18,
                        ),
                        label: Text(
                          status.toLowerCase() == 'live' 
                              ? 'Join Now' 
                              : 'Join Class',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: status.toLowerCase() == 'live' 
                              ? Colors.green 
                              : primaryColor,
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