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

    final title = liveClass['title']?.toString() ?? 'Untitled Class';
    final rawInstructor = liveClass['instructor'];
    final instructor = (rawInstructor != null && rawInstructor.toString().isNotEmpty)
        ? rawInstructor.toString()
        : 'Unknown Instructor';
    final thumbnail = liveClass['thumbnail']?.toString() ?? '';
    final status = liveClass['status']?.toString().toLowerCase() ?? 'upcoming';
    final participants = liveClass['participantsCount'] ?? 0;
    final maxParticipants = liveClass['maxParticipants'] ?? 0;
    final description = liveClass['description']?.toString() ?? '';
    final scheduledTime = liveClass['scheduledTime'];
    final category = liveClass['category']?.toString() ?? 'General';
    final isLive = status == 'live' || status == 'started' || status == 'active';

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
      case 'started':
      case 'active':
        statusColor = Colors.green;
        statusText = 'LIVE';
        break;
      case 'scheduled':
      case 'upcoming':
        statusColor = Colors.blue;
        statusText = 'Upcoming';
        break;
      case 'ended':
      case 'completed':
        statusColor = Colors.grey;
        statusText = 'Ended';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.toUpperCase();
    }

    return Card(
      color: backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: textSecondaryColor.withAlpha(30), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThumbnailSection(
            thumbnail: thumbnail,
            statusText: statusText,
            statusColor: statusColor,
            isOwnClass: isOwnClass,
            category: category,
            participants: participants,
            maxParticipants: maxParticipants,
            primaryColor: primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: textColor, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 13, color: textSecondaryColor.withAlpha(130)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        instructor,
                        style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 13, color: textSecondaryColor.withAlpha(130)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        timeString,
                        style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor.withAlpha(180), height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                _ActionButtons(
                  isLive: isLive,
                  isOwnClass: isOwnClass,
                  isInstructor: isInstructor,
                  isFollowing: isFollowing,
                  status: liveClass['status']?.toString().toLowerCase() ?? 'upcoming',
                  textSecondaryColor: textSecondaryColor,
                  onRemindMe: onRemindMe,
                  onStart: onStart,
                  onJoin: onJoin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailSection extends StatelessWidget {
  final String thumbnail;
  final String statusText;
  final Color statusColor;
  final bool isOwnClass;
  final String category;
  final dynamic participants;
  final dynamic maxParticipants;
  final Color primaryColor;

  const _ThumbnailSection({
    required this.thumbnail,
    required this.statusText,
    required this.statusColor,
    required this.isOwnClass,
    required this.category,
    required this.participants,
    required this.maxParticipants,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
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
                  loadingBuilder: (_, child, loading) => loading == null ? child : _fallback(primaryColor),
                )
              : _fallback(primaryColor),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(190),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withAlpha(120), width: 1),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor, letterSpacing: 0.5),
              ),
            ),
          ),
          if (isOwnClass)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withAlpha(220), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_rounded, size: 10, color: Colors.white),
                    const SizedBox(width: 2),
                    Text('Your Class', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black.withAlpha(190), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_rounded, size: 12, color: Colors.white.withAlpha(220)),
                  const SizedBox(width: 3),
                  Text(
                    '$participants/${maxParticipants > 0 ? maxParticipants : '∞'}',
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withAlpha(220)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: primaryColor.withAlpha(220), borderRadius: BorderRadius.circular(8)),
              child: Text(
                category,
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.videocam_rounded, size: 32, color: color.withAlpha(100)),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isLive;
  final bool isOwnClass;
  final bool isInstructor;
  final bool isFollowing;
  final String status;
  final Color textSecondaryColor;
  final VoidCallback onRemindMe;
  final VoidCallback? onStart;
  final VoidCallback onJoin;

  const _ActionButtons({
    required this.isLive,
    required this.isOwnClass,
    required this.isInstructor,
    required this.isFollowing,
    required this.status,
    required this.textSecondaryColor,
    required this.onRemindMe,
    required this.onStart,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final isScheduledOrUpcoming = status == 'scheduled' || status == 'upcoming';
    final canStart = isOwnClass && isInstructor && !isLive && isScheduledOrUpcoming;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: isLive ? null : onRemindMe,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: BorderSide(
                color: isFollowing ? Colors.green.withAlpha(100) : textSecondaryColor.withAlpha(50),
              ),
              foregroundColor: isFollowing ? Colors.green : textSecondaryColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFollowing ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                  size: 14,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    isFollowing ? 'Remind' : 'Remind',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: canStart ? onStart : isLive ? onJoin : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              backgroundColor: canStart ? Colors.blue : isLive ? Colors.green : textSecondaryColor.withAlpha(50),
              foregroundColor: canStart || isLive ? Colors.white : textSecondaryColor,
              disabledBackgroundColor: textSecondaryColor.withAlpha(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  canStart ? Icons.play_circle_fill_rounded : isLive ? Icons.play_arrow_rounded : Icons.meeting_room_rounded,
                  size: 14,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    canStart ? 'Start' : isLive ? 'Join' : status == 'upcoming' ? 'Soon' : 'Ended',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
