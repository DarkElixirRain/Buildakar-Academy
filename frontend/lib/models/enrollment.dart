class Enrollment {
  final String id;
  final String userId;
  final String courseId;
  final int progress;
  final bool isCompleted;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  final Course? course;

  Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.progress,
    required this.isCompleted,
    required this.enrolledAt,
    this.completedAt,
    this.lastAccessedAt,
    this.course,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      progress: json['progress']?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] ?? false,
      enrolledAt: DateTime.parse(json['enrolledAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      lastAccessedAt: json['lastAccessedAt'] != null ? DateTime.parse(json['lastAccessedAt']) : null,
      course: json['course'] != null ? Course.fromJson(json['course']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'progress': progress,
      'isCompleted': isCompleted,
      'enrolledAt': enrolledAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'course': course?.toJson(),
    };
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String? thumbnail;
  final String? instructor;
  final String level;
  final String category;
  final int totalLessons;
  final int completedLessons;
  final String? remainingTime;
  final double progress;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    this.instructor,
    required this.level,
    required this.category,
    required this.totalLessons,
    required this.completedLessons,
    this.remainingTime,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'instructor': instructor,
      'level': level,
      'category': category,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'remainingTime': remainingTime,
      'progress': progress,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    // Calculate progress
    final totalLessons = json['totalLessons'] ?? 1;
    final completedLessons = json['completedLessons'] ?? 0;
    final progress = totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0.0;

    // Get instructor name
    String instructorName = 'Unknown Instructor';
    if (json['instructor'] != null) {
      if (json['instructor'] is Map<String, dynamic>) {
        instructorName = json['instructor']['name'] ?? 'Unknown Instructor';
      } else if (json['instructor'] is String) {
        instructorName = json['instructor'];
      }
    }

    // Get category
    String category = 'General';
    if (json['category'] != null) {
      if (json['category'] is Map<String, dynamic>) {
        category = json['category']['name'] ?? 'General';
      } else if (json['category'] is String) {
        category = json['category'];
      }
    }

    // Calculate remaining time (simplified)
    String remainingTime = 'In progress';
    if (progress >= 100) {
      remainingTime = 'Completed ✅';
    } else if (progress > 75) {
      remainingTime = 'Almost done';
    } else if (progress > 50) {
      remainingTime = 'Halfway there';
    } else if (progress > 25) {
      remainingTime = 'Getting started';
    } else {
      remainingTime = 'Just started';
    }

    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Course',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? json['thumbnailUrl'] ?? '',
      instructor: instructorName,
      level: json['level'] ?? 'Beginner',
      category: category,
      totalLessons: totalLessons,
      completedLessons: completedLessons,
      remainingTime: remainingTime,
      progress: progress,
    );
  }
}