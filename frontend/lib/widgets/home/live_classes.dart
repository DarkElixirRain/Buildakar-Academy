// lib/widgets/home/live_classes.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class LiveClasses extends StatefulWidget {
  final List<Map<String, dynamic>> classes;
  final Function(String) onJoinPress;
  final VoidCallback onSeeAll;

  const LiveClasses({
    Key? key,
    required this.classes,
    required this.onJoinPress,
    required this.onSeeAll,
  }) : super(key: key);

  @override
  State<LiveClasses> createState() => _LiveClassesState();
}

class _LiveClassesState extends State<LiveClasses> {
  late List<Map<String, dynamic>> _classes;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _classes = widget.classes.map((classItem) {
      return {
        ...classItem,
        'isLive': classItem['isLive'] ?? false,
        'attendees': classItem['attendees'] ?? 0,
        'isReminderSet': false,
      };
    }).toList();

    // Update live status every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateLiveStatus();
    });
  }

  void _updateLiveStatus() {
    setState(() {
      // Simulate live status changes
      for (var i = 0; i < _classes.length; i++) {
        // Randomly toggle live status for demo
        if (i == 0) {
          _classes[i]['isLive'] = true;
          _classes[i]['attendees'] = 45 + (DateTime.now().second % 20);
        } else if (i == 1) {
          _classes[i]['isLive'] = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleReminder(int index) {
    setState(() {
      _classes[index]['isReminderSet'] = !_classes[index]['isReminderSet'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _classes[index]['isReminderSet']
              ? 'Reminder set for ${_classes[index]['title']}!'
              : 'Reminder removed',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get theme-aware colors
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    // Responsive sizing
    double cardWidth;
    double cardHeight;
    double imageHeight;
    double fontSizeTitle;
    double fontSizeSubtitle;
    double fontSizeBadge;
    double fontSizeButton;
    double paddingSize;
    double gap;

    if (screenWidth < 380) {
      // Small phones
      cardWidth = screenWidth * 0.75;
      cardHeight = screenHeight * 0.38;
      imageHeight = cardHeight * 0.42;
      fontSizeTitle = 13;
      fontSizeSubtitle = 11;
      fontSizeBadge = 9;
      fontSizeButton = 11;
      paddingSize = 8;
      gap = 10;
    } else if (screenWidth < 600) {
      // Medium phones
      cardWidth = screenWidth * 0.60;
      cardHeight = screenHeight * 0.40;
      imageHeight = cardHeight * 0.42;
      fontSizeTitle = 14;
      fontSizeSubtitle = 12;
      fontSizeBadge = 10;
      fontSizeButton = 12;
      paddingSize = 10;
      gap = 12;
    } else if (screenWidth < 900) {
      // Tablets
      cardWidth = screenWidth * 0.38;
      cardHeight = screenHeight * 0.42;
      imageHeight = cardHeight * 0.42;
      fontSizeTitle = 15;
      fontSizeSubtitle = 13;
      fontSizeBadge = 11;
      fontSizeButton = 13;
      paddingSize = 12;
      gap = 16;
    } else {
      // Desktop / Large screens
      cardWidth = screenWidth * 0.25;
      cardHeight = screenHeight * 0.44;
      imageHeight = cardHeight * 0.42;
      fontSizeTitle = 16;
      fontSizeSubtitle = 14;
      fontSizeBadge = 12;
      fontSizeButton = 14;
      paddingSize = 14;
      gap = 18;
    }

    // Clamp values
    cardWidth = cardWidth.clamp(160.0, 380.0);
    cardHeight = cardHeight.clamp(200.0, 420.0);
    imageHeight = imageHeight.clamp(80.0, 180.0);

    if (_classes.isEmpty) {
      return _buildEmptyState(isDark, brightness);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
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
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.video_camera_front,
                      size: screenWidth < 380 ? 18 : 20,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Live Classes',
                      style: TextStyle(
                        fontSize: screenWidth < 380 ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onSeeAll,
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: screenWidth < 380 ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Scroll
        SizedBox(
          height: cardHeight + 10,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _classes.length,
            padding: const EdgeInsets.only(right: 16),
            itemBuilder: (context, index) {
              final classItem = _classes[index];
              return _buildClassCard(
                context,
                classItem,
                index,
                cardWidth,
                cardHeight,
                imageHeight,
                fontSizeTitle,
                fontSizeSubtitle,
                fontSizeBadge,
                fontSizeButton,
                paddingSize,
                gap,
                isDark,
                brightness,
                screenWidth,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    Map<String, dynamic> classItem,
    int index,
    double cardWidth,
    double cardHeight,
    double imageHeight,
    double fontSizeTitle,
    double fontSizeSubtitle,
    double fontSizeBadge,
    double fontSizeButton,
    double paddingSize,
    double gap,
    bool isDark,
    Brightness brightness,
    double screenWidth,
  ) {
    // Get theme-aware colors
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    final isLast = index == _classes.length - 1;
    final isLive = classItem['isLive'] ?? false;
    final attendees = classItem['attendees'] ?? 0;
    final isReminderSet = classItem['isReminderSet'] ?? false;
    final date = classItem['date'] ?? 'Today';
    final time = classItem['time'] ?? '3:00 PM';
    final title = classItem['title'] ?? 'Live Class';
    final instructor = classItem['instructor'] ?? 'Instructor';
    final image = classItem['image'] ?? 'https://picsum.photos/400/200?random=10';
    final category = classItem['category'] ?? 'General';

    return GestureDetector(
      onTap: () => widget.onJoinPress(classItem['id']),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(
          right: isLast ? 0 : gap,
        ),
        decoration: BoxDecoration(
          color: backgroundElementColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLive
                ? Colors.red.withValues(alpha: 0.3)
                : backgroundSelectedColor,
            width: isLive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isLive
                  ? Colors.red.withValues(alpha: 0.2)
                  : isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : const Color(0xFF0F172A).withValues(alpha: 0.06),
              offset: const Offset(0, 2),
              blurRadius: isLive ? 12 : 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: primaryColor.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.video_camera_front,
                                size: 30,
                                color: textSecondaryColor,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: imageHeight,
                          width: double.infinity,
                          color: primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.video_camera_front,
                            size: 30,
                            color: textSecondaryColor,
                          ),
                        ),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: imageHeight * 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Live Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive ? Colors.red : Colors.grey[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        Text(
                          isLive ? 'LIVE' : 'Upcoming',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeBadge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category Badge - Top Right
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeBadge - 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Attendees Count
                if (isLive)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.white,
                            size: fontSizeBadge + 2,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$attendees watching',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSizeBadge,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(paddingSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Instructor
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: fontSizeSubtitle,
                          color: textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            instructor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: fontSizeSubtitle,
                              color: textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Date and Time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: fontSizeSubtitle - 2,
                          color: textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: fontSizeSubtitle - 1,
                            color: textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: fontSizeSubtitle - 2,
                          color: textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: fontSizeSubtitle - 1,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    // Buttons Row
                    SizedBox(height: paddingSize),
                    Row(
                      children: [
                        // Main Action Button
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: fontSizeButton + 16,
                            child: ElevatedButton(
                              onPressed: () => widget.onJoinPress(classItem['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLive
                                    ? Colors.red
                                    : primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isLive ? 'Join Now' : 'Set Reminder',
                                style: TextStyle(
                                  fontSize: fontSizeButton,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Reminder Button
                        SizedBox(width: paddingSize),
                        Container(
                          height: fontSizeButton + 16,
                          width: fontSizeButton + 16,
                          decoration: BoxDecoration(
                            color: backgroundSelectedColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => _toggleReminder(index),
                            icon: Icon(
                              isReminderSet
                                  ? Icons.notifications_active
                                  : Icons.notifications_none,
                              size: fontSizeButton,
                              color: isReminderSet
                                  ? primaryColor
                                  : textSecondaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
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

  Widget _buildEmptyState(bool isDark, Brightness brightness) {
    // Get theme-aware colors
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
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.video_camera_front,
                size: 20,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Live Classes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: backgroundElementColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: backgroundSelectedColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.video_camera_front_outlined,
                size: 48,
                color: textSecondaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                'No live classes available',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for upcoming sessions',
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondaryColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}