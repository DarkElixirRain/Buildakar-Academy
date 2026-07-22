// lib/models/live_class_model.dart

class LiveClass {
  final String id;
  final String title;
  final String instructor;
  final String instructorId;
  final String instructorAvatar;
  final String? courseId;
  final String thumbnail;
  final String category;
  final String categoryId;
  final String status; // 'live', 'upcoming', 'ended'
  final DateTime scheduledTime;
  final String? durationSoFar;
  final int participantsCount;
  final int maxParticipants;
  final String description;
  final bool isFollowing;
  final String? meetingLink;
  final String? recordingUrl;
  final bool isFree;
  final double? price;
  final String? level;
  final List<String>? tags;

  LiveClass({
    required this.id,
    required this.title,
    required this.instructor,
    this.instructorId = '',
    this.instructorAvatar = '',
    this.courseId,
    required this.thumbnail,
    required this.category,
    this.categoryId = '',
    required this.status,
    required this.scheduledTime,
    this.durationSoFar,
    required this.participantsCount,
    required this.maxParticipants,
    required this.description,
    this.isFollowing = false,
    this.meetingLink,
    this.recordingUrl,
    this.isFree = true,
    this.price,
    this.level,
    this.tags,
  });

  factory LiveClass.fromJson(Map<String, dynamic> json) {
    // Extract instructor info
    String instructorName = 'Unknown Instructor';
    String instructorId = '';
    String instructorAvatar = '';
    
    if (json['instructor'] != null) {
      if (json['instructor'] is Map<String, dynamic>) {
        final instructor = json['instructor'] as Map<String, dynamic>;
        final nameParts = '${instructor['firstName'] ?? ''} ${instructor['lastName'] ?? ''}'.trim();
        instructorName = instructor['name'] ?? (nameParts.isNotEmpty ? nameParts : 'Unknown Instructor');
        instructorId = instructor['id']?.toString() ?? '';
        instructorAvatar = instructor['photo'] ?? instructor['avatar'] ?? '';
      } else if (json['instructor'] is String) {
        instructorName = json['instructor'] as String;
      }
    }

    // Extract category info
    String categoryName = 'General';
    String categoryId = '';
    if (json['category'] != null) {
      if (json['category'] is Map<String, dynamic>) {
        final category = json['category'] as Map<String, dynamic>;
        categoryName = category['name'] ?? category['title'] ?? 'General';
        categoryId = category['id']?.toString() ?? '';
      } else if (json['category'] is String) {
        categoryName = json['category'] as String;
      }
    }

    // Parse scheduled time
    DateTime scheduledTime;
    if (json['scheduledTime'] != null) {
      try {
        scheduledTime = DateTime.parse(json['scheduledTime'].toString());
      } catch (_) {
        scheduledTime = DateTime.now();
      }
    } else if (json['scheduledAt'] != null) {
      try {
        scheduledTime = DateTime.parse(json['scheduledAt'].toString());
      } catch (_) {
        scheduledTime = DateTime.now();
      }
    } else {
      scheduledTime = DateTime.now();
    }

    return LiveClass(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Class',
      instructor: instructorName,
      instructorId: instructorId,
      instructorAvatar: instructorAvatar,
      courseId: json['courseId']?.toString(),
      thumbnail: _getThumbnail(json),
      category: categoryName,
      categoryId: categoryId,
      status: json['status']?.toString().toLowerCase() ?? 'upcoming',
      scheduledTime: scheduledTime,
      durationSoFar: json['durationSoFar']?.toString(),
      participantsCount: _toInt(json['participantsCount'] ?? json['participants'] ?? 0),
      maxParticipants: _toInt(json['maxParticipants'] ?? json['capacity'] ?? 0),
      description: json['description'] ?? '',
      isFollowing: json['isFollowing'] ?? json['isFollowed'] ?? false,
      meetingLink: json['meetingLink'] ?? json['meetingUrl'] ?? json['joinUrl'],
      recordingUrl: json['recordingUrl'] ?? json['recordedUrl'],
      isFree: json['isFree'] ?? true,
      price: json['price'] != null ? _toDouble(json['price']) : null,
      level: json['level']?.toString(),
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'].map((tag) => tag.toString()))
          : null,
    );
  }

  static String _getThumbnail(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'] ?? 
                     json['thumbnailUrl'] ?? 
                     json['coverImage'] ?? 
                     json['image'] ?? 
                     '';
    if (thumbnail.toString().isNotEmpty) {
      return thumbnail.toString();
    }
    return 'https://via.placeholder.com/400x225/4F46E5/FFFFFF?text=Live+Class';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    if (value is num) return value.toInt();
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    if (value is num) return value.toDouble();
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'instructorId': instructorId,
      'instructorAvatar': instructorAvatar,
      if (courseId != null) 'courseId': courseId,
      'thumbnail': thumbnail,
      'category': category,
      'categoryId': categoryId,
      'status': status,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationSoFar': durationSoFar,
      'participantsCount': participantsCount,
      'maxParticipants': maxParticipants,
      'description': description,
      'isFollowing': isFollowing,
      'meetingLink': meetingLink,
      'recordingUrl': recordingUrl,
      'isFree': isFree,
      'price': price,
      'level': level,
      'tags': tags,
    };
  }

  LiveClass copyWith({
    String? id,
    String? title,
    String? instructor,
    String? instructorId,
    String? instructorAvatar,
    String? courseId,
    String? thumbnail,
    String? category,
    String? categoryId,
    String? status,
    DateTime? scheduledTime,
    String? durationSoFar,
    int? participantsCount,
    int? maxParticipants,
    String? description,
    bool? isFollowing,
    String? meetingLink,
    String? recordingUrl,
    bool? isFree,
    double? price,
    String? level,
    List<String>? tags,
  }) {
    return LiveClass(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      instructorId: instructorId ?? this.instructorId,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      courseId: courseId ?? this.courseId,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationSoFar: durationSoFar ?? this.durationSoFar,
      participantsCount: participantsCount ?? this.participantsCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      description: description ?? this.description,
      isFollowing: isFollowing ?? this.isFollowing,
      meetingLink: meetingLink ?? this.meetingLink,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      isFree: isFree ?? this.isFree,
      price: price ?? this.price,
      level: level ?? this.level,
      tags: tags ?? this.tags,
    );
  }
}