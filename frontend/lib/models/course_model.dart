// lib/models/course_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

// ============ HELPER EXTENSIONS ============
extension NumExtension on num? {
  double toDoubleSafe() => this?.toDouble() ?? 0.0;
  int toIntSafe() => this?.toInt() ?? 0;
}

// ============ REVIEW USER MODEL ============
@JsonSerializable()
class ReviewUser {
  final String id;
  final String firstName;
  final String lastName;
  final String? photo;
  final String? email;

  ReviewUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photo,
    this.email,
  });

  String get fullName => '$firstName $lastName'.trim();
  
  String get avatarUrl => photo ?? 
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&size=100&background=4F46E5&color=fff';

  factory ReviewUser.fromJson(Map<String, dynamic> json) =>
      _$ReviewUserFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewUserToJson(this);
}

// ============ INSTRUCTOR MODEL ============
@JsonSerializable()
class Instructor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? photo;
  final String? bio;
  final double rating;
  final int studentsCount;
  final int coursesCount;

  Instructor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photo,
    this.bio,
    this.rating = 0.0,
    this.studentsCount = 0,
    this.coursesCount = 0,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Instructor' : name;
  }

  String get avatarUrl =>
      photo ??
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&size=150&background=4F46E5&color=fff';

  factory Instructor.fromJson(Map<String, dynamic> json) {
    // Safely convert numeric values
    final rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    final studentsCount = (json['studentsCount'] as num?)?.toInt() ?? 0;
    final coursesCount = (json['coursesCount'] as num?)?.toInt() ?? 0;

    return Instructor(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      photo: json['photo']?.toString(),
      bio: json['bio']?.toString(),
      rating: rating,
      studentsCount: studentsCount,
      coursesCount: coursesCount,
    );
  }

  Map<String, dynamic> toJson() => _$InstructorToJson(this);
}

// ============ CATEGORY MODEL ============
@JsonSerializable()
class CourseCategory {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;

  CourseCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) =>
      _$CourseCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CourseCategoryToJson(this);
}

// ============ LESSON MODEL ============
@JsonSerializable()
class Lesson {
  final String id;
  final String title;
  final String? description;
  final String? duration;
  final String? videoUrl;
  final int order;
  final bool isPreview;
  final bool isFree;
  final String? content;
  final String? thumbnail;

  @JsonKey(ignore: true)
  bool completed;

  Lesson({
    required this.id,
    required this.title,
    this.description,
    this.duration,
    this.videoUrl,
    required this.order,
    this.isPreview = false,
    this.isFree = false,
    this.content,
    this.thumbnail,
    this.completed = false,
  });

  bool get isUnlockedPreview => isPreview || isFree;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final order = (json['order'] as num?)?.toInt() ?? 0;
    
    return Lesson(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      duration: json['duration']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      order: order,
      isPreview: json['isPreview'] == true,
      isFree: json['isFree'] == true,
      content: json['content']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      completed: json['completed'] == true,
    );
  }

  Map<String, dynamic> toJson() => _$LessonToJson(this);
}

// ============ SECTION MODEL ============
@JsonSerializable()
class CourseSection {
  final String id;
  final String title;
  final String? description;
  final int order;
  final List<Lesson> lessons;

  CourseSection({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    required this.lessons,
  });

  int get lessonCount => lessons.length;

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    final order = (json['order'] as num?)?.toInt() ?? 0;
    final lessons = (json['lessons'] as List? ?? [])
        .map((item) => Lesson.fromJson(item))
        .toList();

    return CourseSection(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      order: order,
      lessons: lessons,
    );
  }

  Map<String, dynamic> toJson() => _$CourseSectionToJson(this);
}

// ============ REVIEW MODEL ============
@JsonSerializable()
class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;

  @JsonKey(ignore: true)
  final ReviewUser? user;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Safely convert rating
    final rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    
    // Get user data
    ReviewUser? userObj;
    String userName = 'User';
    String userAvatar = '';
    String userId = '';

    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      try {
        userObj = ReviewUser.fromJson(json['user']);
        userName = userObj.fullName;
        userAvatar = userObj.avatarUrl;
        userId = userObj.id;
      } catch (e) {
        // Fallback to direct fields
      }
    }

    // Fallback to direct fields if user object not available
    if (userName == 'User') {
      userName = json['userName']?.toString() ?? json['user']?['firstName']?.toString() ?? 'User';
    }
    if (userAvatar.isEmpty) {
      userAvatar = json['userAvatar']?.toString() ?? json['user']?['photo']?.toString() ?? '';
    }
    if (userId.isEmpty) {
      userId = json['userId']?.toString() ?? json['user']?['id']?.toString() ?? '';
    }

    // Parse date
    DateTime createdAt;
    try {
      createdAt = json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now();
    } catch (e) {
      createdAt = DateTime.now();
    }

    return Review(
      id: json['id']?.toString() ?? '',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating,
      comment: json['comment']?.toString() ?? '',
      createdAt: createdAt,
      user: userObj,
    );
  }

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

// ============ STUDY MATERIAL MODEL ============
enum StudyMaterialType { pdf, doc, zip, link, slides }

@JsonSerializable()
class StudyMaterial {
  final String id;
  final String title;
  final StudyMaterialType type;
  final String sizeLabel;
  final String url;
  final String? relatedSectionTitle;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.sizeLabel,
    required this.url,
    this.relatedSectionTitle,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    StudyMaterialType type;
    final typeStr = json['type']?.toString().toLowerCase() ?? 'pdf';
    switch (typeStr) {
      case 'doc':
        type = StudyMaterialType.doc;
        break;
      case 'zip':
        type = StudyMaterialType.zip;
        break;
      case 'link':
        type = StudyMaterialType.link;
        break;
      case 'slides':
        type = StudyMaterialType.slides;
        break;
      default:
        type = StudyMaterialType.pdf;
    }

    return StudyMaterial(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: type,
      sizeLabel: json['sizeLabel']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      relatedSectionTitle: json['relatedSectionTitle']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$StudyMaterialToJson(this);
}

// ============ ENROLLMENT STATUS MODEL ============
@JsonSerializable()
class EnrollmentStatus {
  final bool isEnrolled;
  final double progress;
  final bool isCompleted;
  final String? enrollmentId;
  final DateTime? enrolledAt;
  final DateTime? completedAt;

  EnrollmentStatus({
    required this.isEnrolled,
    required this.progress,
    required this.isCompleted,
    this.enrollmentId,
    this.enrolledAt,
    this.completedAt,
  });

  factory EnrollmentStatus.fromJson(Map<String, dynamic> json) {
    final progress = (json['progress'] as num?)?.toDouble() ?? 0.0;
    
    DateTime? enrolledAt;
    try {
      enrolledAt = json['enrolledAt'] != null 
          ? DateTime.parse(json['enrolledAt'].toString()) 
          : null;
    } catch (e) {
      enrolledAt = null;
    }

    DateTime? completedAt;
    try {
      completedAt = json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'].toString()) 
          : null;
    } catch (e) {
      completedAt = null;
    }

    return EnrollmentStatus(
      isEnrolled: json['isEnrolled'] == true,
      progress: progress,
      isCompleted: json['isCompleted'] == true,
      enrollmentId: json['enrollmentId']?.toString(),
      enrolledAt: enrolledAt,
      completedAt: completedAt,
    );
  }

  Map<String, dynamic> toJson() => _$EnrollmentStatusToJson(this);
}

// ============ NOTE ITEM MODEL ============
@JsonSerializable()
class NoteItem {
  final String id;
  final String lessonId;
  final String lessonTitle;
  final String content;
  final String courseId;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteItem({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.content,
    required this.courseId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      createdAt = json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now();
    } catch (e) {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    try {
      updatedAt = json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString()) 
          : DateTime.now();
    } catch (e) {
      updatedAt = DateTime.now();
    }

    return NoteItem(
      id: json['id']?.toString() ?? '',
      lessonId: json['lessonId']?.toString() ?? '',
      lessonTitle: json['lessonTitle']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$NoteItemToJson(this);
}

// ============ COURSE MODEL ============
@JsonSerializable()
class Course {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final double price;
  final double? originalPrice;
  final String level;
  final String language;
  final String? duration;
  final double? totalHours;
  final double rating;
  final int studentsCount;
  final bool isPublished;
  final bool isBestseller;
  final bool isTrending;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String instructorId;
  final String categoryId;
  final Instructor instructor;
  final CourseCategory category;
  final List<CourseSection> sections;
  final int enrollmentsCount;
  final int reviewsCount;
  final int lessonsCount;
  final List<String> learningObjectives;
  final List<String> requirements;
  final List<String> whatYouWillLearn;
  final List<Review> reviews;
  final List<StudyMaterial> studyMaterials;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.price,
    this.originalPrice,
    required this.level,
    required this.language,
    this.duration,
    this.totalHours,
    required this.rating,
    required this.studentsCount,
    this.isPublished = true,
    this.isBestseller = false,
    this.isTrending = false,
    this.status = 'published',
    required this.createdAt,
    required this.updatedAt,
    required this.instructorId,
    required this.categoryId,
    required this.instructor,
    required this.category,
    required this.sections,
    this.enrollmentsCount = 0,
    this.reviewsCount = 0,
    this.lessonsCount = 0,
    this.learningObjectives = const [],
    this.requirements = const [],
    this.whatYouWillLearn = const [],
    this.reviews = const [],
    this.studyMaterials = const [],
  });

  int get discountPercent {
    if (originalPrice == null || originalPrice == 0) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    // Safely convert numeric values
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final originalPrice = (json['originalPrice'] as num?)?.toDouble();
    final totalHours = (json['totalHours'] as num?)?.toDouble();
    final rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    final studentsCount = (json['studentsCount'] as num?)?.toInt() ?? 0;
    final enrollmentsCount = (json['enrollmentsCount'] as num?)?.toInt() ?? 0;
    final reviewsCount = (json['reviewsCount'] as num?)?.toInt() ?? 0;
    final lessonsCount = (json['lessonsCount'] as num?)?.toInt() ?? 0;

    // Parse sections
    List<CourseSection> sections = [];
    if (json['sections'] != null && json['sections'] is List) {
      sections = (json['sections'] as List)
          .map((item) => CourseSection.fromJson(item))
          .toList();
    }

    // Parse reviews
    List<Review> reviews = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      reviews = (json['reviews'] as List)
          .map((item) => Review.fromJson(item))
          .toList();
    }

    // Parse instructor
    Instructor instructor;
    if (json['instructor'] != null) {
      instructor = Instructor.fromJson(json['instructor']);
    } else {
      instructor = Instructor(
        id: json['instructorId']?.toString() ?? '',
        firstName: 'Unknown',
        lastName: 'Instructor',
        email: '',
      );
    }

    // Parse category
    CourseCategory category;
    if (json['category'] != null) {
      category = CourseCategory.fromJson(json['category']);
    } else {
      category = CourseCategory(
        id: json['categoryId']?.toString() ?? '',
        name: 'General',
        slug: 'general',
      );
    }

    // Parse study materials
    List<StudyMaterial> studyMaterials = [];
    if (json['studyMaterials'] != null && json['studyMaterials'] is List) {
      studyMaterials = (json['studyMaterials'] as List)
          .map((item) => StudyMaterial.fromJson(item))
          .toList();
    }

    // Parse dates
    DateTime createdAt;
    try {
      createdAt = json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now();
    } catch (e) {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    try {
      updatedAt = json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString()) 
          : DateTime.now();
    } catch (e) {
      updatedAt = DateTime.now();
    }

    return Course(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      price: price,
      originalPrice: originalPrice,
      level: json['level']?.toString() ?? 'BEGINNER',
      language: json['language']?.toString() ?? 'English',
      duration: json['duration']?.toString(),
      totalHours: totalHours,
      rating: rating,
      studentsCount: studentsCount,
      isPublished: json['isPublished'] == true,
      isBestseller: json['isBestseller'] == true,
      isTrending: json['isTrending'] == true,
      status: json['status']?.toString() ?? 'published',
      createdAt: createdAt,
      updatedAt: updatedAt,
      instructorId: json['instructorId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      instructor: instructor,
      category: category,
      sections: sections,
      enrollmentsCount: enrollmentsCount,
      reviewsCount: reviewsCount,
      lessonsCount: lessonsCount,
      learningObjectives: List<String>.from(json['learningObjectives'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      whatYouWillLearn: List<String>.from(json['whatYouWillLearn'] ?? []),
      reviews: reviews,
      studyMaterials: studyMaterials,
    );
  }

  Map<String, dynamic> toJson() => _$CourseToJson(this);
}