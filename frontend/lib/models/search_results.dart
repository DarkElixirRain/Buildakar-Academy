class SearchResults {
  final List<CourseSearchResult> courses;
  final List<InstructorSearchResult> instructors;
  final List<CategorySearchResult> categories;
  final SearchMeta meta;
  final SearchPagination? pagination;

  SearchResults({
    required this.courses,
    required this.instructors,
    required this.categories,
    required this.meta,
    this.pagination,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      courses: (json['courses'] as List?)
              ?.map((item) => CourseSearchResult.fromJson(item))
              .toList() ??
          [],
      instructors: (json['instructors'] as List?)
              ?.map((item) => InstructorSearchResult.fromJson(item))
              .toList() ??
          [],
      categories: (json['categories'] as List?)
              ?.map((item) => CategorySearchResult.fromJson(item))
              .toList() ??
          [],
      meta: SearchMeta.fromJson(json['meta'] ?? {}),
      pagination: json['pagination'] != null
          ? SearchPagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses.map((item) => item.toJson()).toList(),
      'instructors': instructors.map((item) => item.toJson()).toList(),
      'categories': categories.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
      'pagination': pagination?.toJson(),
    };
  }
}

class SearchMeta {
  final String query;
  final int totalResults;
  final String type;

  SearchMeta({
    required this.query,
    required this.totalResults,
    required this.type,
  });

  factory SearchMeta.fromJson(Map<String, dynamic> json) {
    return SearchMeta(
      query: json['query'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      type: json['type'] ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'totalResults': totalResults,
      'type': type,
    };
  }
}

class SearchPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  SearchPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory SearchPagination.fromJson(Map<String, dynamic> json) {
    return SearchPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasMore': hasMore,
    };
  }
}

class CourseSearchResult {
  final String id;
  final String title;
  final String description;
  final String? thumbnail;
  final double? rating;
  final int studentsCount;
  final int price;
  final String level;
  final String? categoryId;
  final CategoryInfo? category;
  final InstructorInfo instructor;
  final int enrollments;
  final int reviews;
  final int lessons;
  final String type;

  CourseSearchResult({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    this.rating,
    required this.studentsCount,
    required this.price,
    required this.level,
    this.categoryId,
    this.category,
    required this.instructor,
    required this.enrollments,
    required this.reviews,
    required this.lessons,
    this.type = 'course',
  });

  factory CourseSearchResult.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] ?? {};
    return CourseSearchResult(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'],
      rating: json['rating']?.toDouble(),
      studentsCount: json['studentsCount'] ?? 0,
      price: json['price'] ?? 0,
      level: json['level'] ?? 'BEGINNER',
      categoryId: json['categoryId'],
      category: json['category'] != null
          ? CategoryInfo.fromJson(json['category'])
          : null,
      instructor: json['instructor'] != null
          ? InstructorInfo.fromJson(json['instructor'])
          : InstructorInfo(id: '', firstName: '', lastName: ''),
      enrollments: count['enrollments'] ?? 0,
      reviews: count['reviews'] ?? 0,
      lessons: count['lessons'] ?? 0,
      type: json['type'] ?? 'course',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'rating': rating,
      'studentsCount': studentsCount,
      'price': price,
      'level': level,
      'categoryId': categoryId,
      'category': category?.toJson(),
      'instructor': instructor.toJson(),
      '_count': {
        'enrollments': enrollments,
        'reviews': reviews,
        'lessons': lessons,
      },
      'type': type,
    };
  }
}

class InstructorInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String? photo;
  final String? expertise;

  InstructorInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photo,
    this.expertise,
  });

  factory InstructorInfo.fromJson(Map<String, dynamic> json) {
    return InstructorInfo(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      photo: json['photo'],
      expertise: json['expertise'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'photo': photo,
      'expertise': expertise,
    };
  }

  String get fullName => '$firstName $lastName';
}

class CategoryInfo {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? color;

  CategoryInfo({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.color,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'color': color,
    };
  }
}

class InstructorSearchResult {
  final String id;
  final String firstName;
  final String lastName;
  final String name;
  final String photo;
  final String expertise;
  final String? bio;
  final bool isVerified;
  final int studentsCount;
  final int coursesCount;
  final String type;

  InstructorSearchResult({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.photo,
    required this.expertise,
    this.bio,
    required this.isVerified,
    required this.studentsCount,
    required this.coursesCount,
    this.type = 'instructor',
  });

  factory InstructorSearchResult.fromJson(Map<String, dynamic> json) {
    return InstructorSearchResult(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'] ?? '',
      expertise: json['expertise'] ?? 'Instructor',
      bio: json['bio'],
      isVerified: json['isVerified'] ?? false,
      studentsCount: json['studentsCount'] ?? 0,
      coursesCount: json['coursesCount'] ?? 0,
      type: json['type'] ?? 'instructor',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'photo': photo,
      'expertise': expertise,
      'bio': bio,
      'isVerified': isVerified,
      'studentsCount': studentsCount,
      'coursesCount': coursesCount,
      'type': type,
    };
  }
}

class CategorySearchResult {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String color;
  final String? description;
  final int courseCount;
  final String type;

  CategorySearchResult({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.color,
    this.description,
    required this.courseCount,
    this.type = 'category',
  });

  factory CategorySearchResult.fromJson(Map<String, dynamic> json) {
    return CategorySearchResult(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? 'folder',
      color: json['color'] ?? '#7C3AED',
      description: json['description'],
      courseCount: json['courseCount'] ?? 0,
      type: json['type'] ?? 'category',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'color': color,
      'description': description,
      'courseCount': courseCount,
      'type': type,
    }; 
  }
}