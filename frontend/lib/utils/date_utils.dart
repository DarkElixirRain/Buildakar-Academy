// lib/utils/date_utils.dart
import 'package:intl/intl.dart';
import 'package:learnhub/models/course_model.dart';

/// Format relative date (e.g., "Today", "Yesterday", "2 days ago")
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}

/// Format month and year (e.g., "Jan 2024")
String formatMonthYear(DateTime date) {
  return DateFormat('MMM yyyy').format(date);
}

/// Format duration from seconds to readable string
String formatDurationFromSeconds(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  } else if (minutes > 0) {
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  } else {
    return '0:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

/// Format total duration from sections
String formatTotalDurationFromSections(List<CourseSection> sections) {
  double totalMinutes = 0;
  for (final section in sections) {
    for (final lesson in section.lessons) {
      final d = lesson.duration;
      if (d == null || d.isEmpty) continue;
      final parts = d.split(':').map((p) => int.tryParse(p) ?? 0).toList();
      if (parts.length == 2) {
        totalMinutes += parts[0] + parts[1] / 60;
      } else if (parts.length == 3) {
        totalMinutes += parts[0] * 60 + parts[1] + parts[2] / 60;
      }
    }
  }
  final hours = totalMinutes ~/ 60;
  final minutes = (totalMinutes % 60).round();
  return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
}