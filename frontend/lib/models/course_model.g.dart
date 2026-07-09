// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewUser _$ReviewUserFromJson(Map<String, dynamic> json) => ReviewUser(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  photo: json['photo'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$ReviewUserToJson(ReviewUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'photo': instance.photo,
      'email': instance.email,
    };

Instructor _$InstructorFromJson(Map<String, dynamic> json) => Instructor(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  photo: json['photo'] as String?,
  bio: json['bio'] as String?,
  rating: (json['rating'] as num?)?.toDouble() ?? 0,
  studentsCount: (json['studentsCount'] as num?)?.toInt() ?? 0,
  coursesCount: (json['coursesCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$InstructorToJson(Instructor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'photo': instance.photo,
      'bio': instance.bio,
      'rating': instance.rating,
      'studentsCount': instance.studentsCount,
      'coursesCount': instance.coursesCount,
    };

CourseCategory _$CourseCategoryFromJson(Map<String, dynamic> json) =>
    CourseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$CourseCategoryToJson(CourseCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'icon': instance.icon,
    };

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  duration: json['duration'] as String?,
  videoUrl: json['videoUrl'] as String?,
  order: (json['order'] as num).toInt(),
  isPreview: json['isPreview'] as bool? ?? false,
  isFree: json['isFree'] as bool? ?? false,
  content: json['content'] as String?,
  thumbnail: json['thumbnail'] as String?,
);

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'duration': instance.duration,
  'videoUrl': instance.videoUrl,
  'order': instance.order,
  'isPreview': instance.isPreview,
  'isFree': instance.isFree,
  'content': instance.content,
  'thumbnail': instance.thumbnail,
};

CourseSection _$CourseSectionFromJson(Map<String, dynamic> json) =>
    CourseSection(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      order: (json['order'] as num).toInt(),
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseSectionToJson(CourseSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'order': instance.order,
      'lessons': instance.lessons,
    };

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userAvatar: json['userAvatar'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userAvatar': instance.userAvatar,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
};

StudyMaterial _$StudyMaterialFromJson(Map<String, dynamic> json) =>
    StudyMaterial(
      id: json['id'] as String,
      title: json['title'] as String,
      type: $enumDecode(_$StudyMaterialTypeEnumMap, json['type']),
      sizeLabel: json['sizeLabel'] as String,
      url: json['url'] as String,
      relatedSectionTitle: json['relatedSectionTitle'] as String?,
    );

Map<String, dynamic> _$StudyMaterialToJson(StudyMaterial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': _$StudyMaterialTypeEnumMap[instance.type]!,
      'sizeLabel': instance.sizeLabel,
      'url': instance.url,
      'relatedSectionTitle': instance.relatedSectionTitle,
    };

const _$StudyMaterialTypeEnumMap = {
  StudyMaterialType.pdf: 'pdf',
  StudyMaterialType.doc: 'doc',
  StudyMaterialType.zip: 'zip',
  StudyMaterialType.link: 'link',
  StudyMaterialType.slides: 'slides',
};

EnrollmentStatus _$EnrollmentStatusFromJson(Map<String, dynamic> json) =>
    EnrollmentStatus(
      isEnrolled: json['isEnrolled'] as bool,
      progress: (json['progress'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool,
      enrollmentId: json['enrollmentId'] as String?,
      enrolledAt: json['enrolledAt'] == null
          ? null
          : DateTime.parse(json['enrolledAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$EnrollmentStatusToJson(EnrollmentStatus instance) =>
    <String, dynamic>{
      'isEnrolled': instance.isEnrolled,
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
      'enrollmentId': instance.enrollmentId,
      'enrolledAt': instance.enrolledAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

NoteItem _$NoteItemFromJson(Map<String, dynamic> json) => NoteItem(
  id: json['id'] as String,
  lessonId: json['lessonId'] as String,
  lessonTitle: json['lessonTitle'] as String,
  content: json['content'] as String,
  courseId: json['courseId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$NoteItemToJson(NoteItem instance) => <String, dynamic>{
  'id': instance.id,
  'lessonId': instance.lessonId,
  'lessonTitle': instance.lessonTitle,
  'content': instance.content,
  'courseId': instance.courseId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  thumbnail: json['thumbnail'] as String,
  price: (json['price'] as num).toDouble(),
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  level: json['level'] as String,
  language: json['language'] as String,
  duration: json['duration'] as String?,
  totalHours: (json['totalHours'] as num?)?.toDouble(),
  rating: (json['rating'] as num).toDouble(),
  studentsCount: (json['studentsCount'] as num).toInt(),
  isPublished: json['isPublished'] as bool? ?? true,
  isBestseller: json['isBestseller'] as bool? ?? false,
  isTrending: json['isTrending'] as bool? ?? false,
  status: json['status'] as String? ?? 'published',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  instructorId: json['instructorId'] as String,
  categoryId: json['categoryId'] as String,
  instructor: Instructor.fromJson(json['instructor'] as Map<String, dynamic>),
  category: CourseCategory.fromJson(json['category'] as Map<String, dynamic>),
  sections: (json['sections'] as List<dynamic>)
      .map((e) => CourseSection.fromJson(e as Map<String, dynamic>))
      .toList(),
  enrollmentsCount: (json['enrollmentsCount'] as num?)?.toInt() ?? 0,
  reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
  lessonsCount: (json['lessonsCount'] as num?)?.toInt() ?? 0,
  learningObjectives:
      (json['learningObjectives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  requirements:
      (json['requirements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  whatYouWillLearn:
      (json['whatYouWillLearn'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  reviews:
      (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  studyMaterials:
      (json['studyMaterials'] as List<dynamic>?)
          ?.map((e) => StudyMaterial.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'thumbnail': instance.thumbnail,
  'price': instance.price,
  'originalPrice': instance.originalPrice,
  'level': instance.level,
  'language': instance.language,
  'duration': instance.duration,
  'totalHours': instance.totalHours,
  'rating': instance.rating,
  'studentsCount': instance.studentsCount,
  'isPublished': instance.isPublished,
  'isBestseller': instance.isBestseller,
  'isTrending': instance.isTrending,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'instructorId': instance.instructorId,
  'categoryId': instance.categoryId,
  'instructor': instance.instructor,
  'category': instance.category,
  'sections': instance.sections,
  'enrollmentsCount': instance.enrollmentsCount,
  'reviewsCount': instance.reviewsCount,
  'lessonsCount': instance.lessonsCount,
  'learningObjectives': instance.learningObjectives,
  'requirements': instance.requirements,
  'whatYouWillLearn': instance.whatYouWillLearn,
  'reviews': instance.reviews,
  'studyMaterials': instance.studyMaterials,
};
