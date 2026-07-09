// lib/constants/dummy_data.dart

import '../models/course_model.dart';
import 'package:flutter/material.dart' show Icons;

// lib/constants/dummy_data.dart


// ============================================
// DUMMY CATEGORY COURSES DATA
// ============================================

/// Get courses for a specific category
List<Map<String, dynamic>> getCategoryCourses(String categoryId) {
  final Map<String, List<Map<String, dynamic>>> categoryCourses = {
    '1': [
      {
        'id': 'course_1',
        'title': 'Complete Flutter Development Course',
        'image': 'https://picsum.photos/seed/flutter/400/300',
        'rating': 4.8,
        'students': 15000,
        'price': '₹49.99',
        'badge': '🔥 Bestseller',
        'instructor': 'Sarah Mitchell',
        'level': 'Intermediate',
        'category': 'Programming',
      },
      {
        'id': 'course_2',
        'title': 'Advanced Python Programming',
        'image': 'https://picsum.photos/seed/python/400/300',
        'rating': 4.9,
        'students': 18000,
        'price': '₹99.99',
        'badge': '⭐ Top Rated',
        'instructor': 'John Doe',
        'level': 'Advanced',
        'category': 'Programming',
      },
      {
        'id': 'course_3',
        'title': 'JavaScript - The Complete Guide',
        'image': 'https://picsum.photos/seed/javascript/400/300',
        'rating': 4.7,
        'students': 22000,
        'price': '₹69.99',
        'badge': '📈 Popular',
        'instructor': 'Sarah Mitchell',
        'level': 'Beginner',
        'category': 'Programming',
      },
      {
        'id': 'course_4',
        'title': 'React Native Masterclass',
        'image': 'https://picsum.photos/seed/react/400/300',
        'rating': 4.6,
        'students': 12000,
        'price': '₹79.99',
        'badge': '💻 Course',
        'instructor': 'John Doe',
        'level': 'Intermediate',
        'category': 'Programming',
      },
      {
        'id': 'course_7',
        'title': 'Data Structures & Algorithms',
        'image': 'https://picsum.photos/seed/dsa/400/300',
        'rating': 4.8,
        'students': 25000,
        'price': '₹89.99',
        'badge': '📚 Course',
        'instructor': 'Sarah Mitchell',
        'level': 'Intermediate',
        'category': 'Programming',
      },
    ],
    '2': [
      {
        'id': 'course_5',
        'title': 'UI/UX Design Fundamentals',
        'image': 'https://picsum.photos/seed/uiux/400/300',
        'rating': 4.8,
        'students': 8000,
        'price': '₹39.99',
        'badge': '⭐ Top Rated',
        'instructor': 'Sarah Mitchell',
        'level': 'Beginner',
        'category': 'Design',
      },
      {
        'id': 'course_6',
        'title': 'Advanced Figma Masterclass',
        'image': 'https://picsum.photos/seed/figma/400/300',
        'rating': 4.7,
        'students': 5000,
        'price': '₹59.99',
        'badge': '🔥 Popular',
        'instructor': 'John Doe',
        'level': 'Intermediate',
        'category': 'Design',
      },
      {
        'id': 'course_8',
        'title': 'Adobe Photoshop Masterclass',
        'image': 'https://picsum.photos/seed/photoshop/400/300',
        'rating': 4.6,
        'students': 12000,
        'price': '₹49.99',
        'badge': '📚 Course',
        'instructor': 'Sarah Mitchell',
        'level': 'Beginner',
        'category': 'Design',
      },
    ],
    '3': [
      {
        'id': 'course_b1',
        'title': 'Business Strategy Fundamentals',
        'image': 'https://picsum.photos/seed/business/400/300',
        'rating': 4.7,
        'students': 10000,
        'price': '₹59.99',
        'badge': '📈 Popular',
        'instructor': 'Sarah Mitchell',
        'level': 'Intermediate',
        'category': 'Business',
      },
      {
        'id': 'course_b2',
        'title': 'Entrepreneurship 101',
        'image': 'https://picsum.photos/seed/entrepreneur/400/300',
        'rating': 4.9,
        'students': 15000,
        'price': '₹49.99',
        'badge': '⭐ Top Rated',
        'instructor': 'John Doe',
        'level': 'Beginner',
        'category': 'Business',
      },
    ],
    '4': [
      {
        'id': 'course_m1',
        'title': 'Digital Marketing Masterclass',
        'image': 'https://picsum.photos/seed/marketing/400/300',
        'rating': 4.8,
        'students': 18000,
        'price': '₹69.99',
        'badge': '🔥 Bestseller',
        'instructor': 'Sarah Mitchell',
        'level': 'Beginner',
        'category': 'Marketing',
      },
      {
        'id': 'course_m2',
        'title': 'Social Media Marketing',
        'image': 'https://picsum.photos/seed/social/400/300',
        'rating': 4.6,
        'students': 12000,
        'price': '₹39.99',
        'badge': '📚 Course',
        'instructor': 'John Doe',
        'level': 'Beginner',
        'category': 'Marketing',
      },
    ],
    '5': [
      {
        'id': 'course_p1',
        'title': 'Photography Fundamentals',
        'image': 'https://picsum.photos/seed/photography/400/300',
        'rating': 4.7,
        'students': 8000,
        'price': '₹49.99',
        'badge': '📈 Popular',
        'instructor': 'Sarah Mitchell',
        'level': 'Beginner',
        'category': 'Photography',
      },
      {
        'id': 'course_p2',
        'title': 'Advanced Photography Techniques',
        'image': 'https://picsum.photos/seed/photography2/400/300',
        'rating': 4.9,
        'students': 5000,
        'price': '₹79.99',
        'badge': '⭐ Top Rated',
        'instructor': 'John Doe',
        'level': 'Advanced',
        'category': 'Photography',
      },
    ],
    '6': [
      {
        'id': 'course_mu1',
        'title': 'Music Theory Fundamentals',
        'image': 'https://picsum.photos/seed/music/400/300',
        'rating': 4.6,
        'students': 6000,
        'price': '₹39.99',
        'badge': '📚 Course',
        'instructor': 'Sarah Mitchell',
        'level': 'Beginner',
        'category': 'Music',
      },
      {
        'id': 'course_mu2',
        'title': 'Music Production Masterclass',
        'image': 'https://picsum.photos/seed/musicprod/400/300',
        'rating': 4.8,
        'students': 4000,
        'price': '₹89.99',
        'badge': '🔥 Popular',
        'instructor': 'John Doe',
        'level': 'Intermediate',
        'category': 'Music',
      },
    ],
    '7': [
      {
        'id': 'course_s1',
        'title': 'Physics Fundamentals',
        'image': 'https://picsum.photos/seed/physics/400/300',
        'rating': 4.7,
        'students': 9000,
        'price': '₹49.99',
        'badge': '📈 Popular',
        'instructor': 'Sarah Mitchell',
        'level': 'Beginner',
        'category': 'Science',
      },
      {
        'id': 'course_s2',
        'title': 'Chemistry Masterclass',
        'image': 'https://picsum.photos/seed/chemistry/400/300',
        'rating': 4.8,
        'students': 7000,
        'price': '₹59.99',
        'badge': '⭐ Top Rated',
        'instructor': 'John Doe',
        'level': 'Intermediate',
        'category': 'Science',
      },
    ],
    '8': [
      {
        'id': 'course_ai1',
        'title': 'Artificial Intelligence Fundamentals',
        'image': 'https://picsum.photos/seed/ai/400/300',
        'rating': 4.9,
        'students': 20000,
        'price': '₹99.99',
        'badge': '🔥 Bestseller',
        'instructor': 'Sarah Mitchell',
        'level': 'Intermediate',
        'category': 'Artificial Intelligence',
      },
      {
        'id': 'course_ai2',
        'title': 'Machine Learning Masterclass',
        'image': 'https://picsum.photos/seed/ml/400/300',
        'rating': 4.8,
        'students': 15000,
        'price': '₹89.99',
        'badge': '⭐ Top Rated',
        'instructor': 'John Doe',
        'level': 'Advanced',
        'category': 'Artificial Intelligence',
      },
      {
        'id': 'course_ai3',
        'title': 'Deep Learning with Python',
        'image': 'https://picsum.photos/seed/deeplearning/400/300',
        'rating': 4.7,
        'students': 10000,
        'price': '₹79.99',
        'badge': '📚 Course',
        'instructor': 'Sarah Mitchell',
        'level': 'Advanced',
        'category': 'Artificial Intelligence',
      },
    ],
  };

  // Return courses for the category, or default courses
  if (categoryCourses.containsKey(categoryId)) {
    return categoryCourses[categoryId]!;
  }

  // Default courses for any category not in the map
  return [
    {
      'id': 'course_default_1',
      'title': 'Introduction to ${getDummyCategoryById(categoryId)['name'] ?? 'Category'}',
      'image': 'https://picsum.photos/seed/default/400/300',
      'rating': 4.5,
      'students': 3000,
      'price': '₹29.99',
      'badge': '📚 New',
      'instructor': 'Sarah Mitchell',
      'level': 'Beginner',
      'category': getDummyCategoryById(categoryId)['name'] ?? 'Category',
    },
    {
      'id': 'course_default_2',
      'title': 'Advanced ${getDummyCategoryById(categoryId)['name'] ?? 'Category'} Techniques',
      'image': 'https://picsum.photos/seed/default2/400/300',
      'rating': 4.7,
      'students': 2000,
      'price': '₹89.99',
      'badge': '💻 Course',
      'instructor': 'John Doe',
      'level': 'Advanced',
      'category': getDummyCategoryById(categoryId)['name'] ?? 'Category',
    },
    {
      'id': 'course_default_3',
      'title': 'Practical ${getDummyCategoryById(categoryId)['name'] ?? 'Category'} Projects',
      'image': 'https://picsum.photos/seed/default3/400/300',
      'rating': 4.6,
      'students': 1500,
      'price': '₹59.99',
      'badge': '📈 Popular',
      'instructor': 'Sarah Mitchell',
      'level': 'Intermediate',
      'category': getDummyCategoryById(categoryId)['name'] ?? 'Category',
    },
  ];
}

// ... rest of the existing dummy_data.dart code ...

// ============================================
// DUMMY COURSES DATA
// ============================================

/// Get a dummy course by ID
Course getDummyCourse(String id) {
  final instructor = Instructor(
    id: 'ins_1',
    firstName: 'Sarah',
    lastName: 'Mitchell',
    email: 'sarah.mitchell@example.com',
    photo: null,
    bio: 'Senior Flutter engineer with 8+ years building production mobile '
        'apps. Previously at two YC-backed startups. Loves teaching clean '
        'architecture and state management patterns.',
    rating: 4.8,
    studentsCount: 48210,
    coursesCount: 12,
  );

  final category = CourseCategory(id: 'cat_1', name: 'Mobile Development', slug: 'mobile-development');

  final sections = <CourseSection>[
    CourseSection(
      id: 'sec_1',
      title: 'Getting Started',
      description: 'Environment setup and Flutter fundamentals',
      order: 1,
      lessons: [
        Lesson(
          id: 'les_1',
          title: 'Course Introduction',
          description: 'What we will build and how the course is structured.',
          duration: '4:32',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          order: 1,
          isPreview: true,
          isFree: true,
          completed: true,
        ),
        Lesson(
          id: 'les_2',
          title: 'Installing Flutter & Dart',
          description: 'Setting up the SDK on macOS, Windows, and Linux.',
          duration: '12:10',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          order: 2,
          isFree: true,
          completed: true,
        ),
        Lesson(
          id: 'les_3',
          title: 'Project Structure Deep Dive',
          duration: '9:45',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          order: 3,
          completed: false,
        ),
      ],
    ),
    CourseSection(
      id: 'sec_2',
      title: 'Widgets & Layout',
      description: 'Building responsive UI with Flutter widgets',
      order: 2,
      lessons: [
        Lesson(
          id: 'les_4',
          title: 'Stateless vs Stateful Widgets',
          duration: '15:20',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
          order: 1,
          isPreview: true,
          completed: true,
        ),
        Lesson(
          id: 'les_5',
          title: 'Rows, Columns & Flex',
          duration: '18:02',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
          order: 2,
          completed: false,
        ),
        Lesson(
          id: 'les_6',
          title: 'ListView & GridView',
          duration: '14:55',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
          order: 3,
          completed: false,
        ),
        Lesson(
          id: 'les_7',
          title: 'Custom Painters & Animations',
          duration: '22:18',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
          order: 4,
          completed: false,
        ),
      ],
    ),
    CourseSection(
      id: 'sec_3',
      title: 'State Management',
      description: 'Provider, Riverpod, and Bloc compared',
      order: 3,
      lessons: [
        Lesson(
          id: 'les_8',
          title: 'Why State Management Matters',
          duration: '10:00',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
          order: 1,
          completed: false,
        ),
        Lesson(
          id: 'les_9',
          title: 'Provider in Depth',
          duration: '25:40',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          order: 2,
          completed: false,
        ),
        Lesson(
          id: 'les_10',
          title: 'Riverpod from Scratch',
          duration: '28:15',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          order: 3,
          completed: false,
        ),
      ],
    ),
    CourseSection(
      id: 'sec_4',
      title: 'Networking & APIs',
      description: 'REST, JSON serialization, and error handling',
      order: 4,
      lessons: [
        Lesson(
          id: 'les_11',
          title: 'http vs dio Package',
          duration: '11:30',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          order: 1,
          completed: false,
        ),
        Lesson(
          id: 'les_12',
          title: 'Building a Repository Layer',
          duration: '19:47',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
          order: 2,
          completed: false,
        ),
      ],
    ),
  ];

// lib/constants/dummy_data.dart
// Replace the reviews section in getDummyCourse with this:

final reviews = <Review>[
  Review(
    id: 'rev_1',
    userId: 'user_1',  // Add this required field
    userName: 'Michael Chen',
    userAvatar: 'https://ui-avatars.com/api/?name=Michael+Chen&size=100&background=0EA5E9&color=fff',
    rating: 5,
    comment: 'Best Flutter course I have taken. The state management section alone was worth the price.',
    createdAt: DateTime.now().subtract(const Duration(days: 12)),  // Changed from 'date' to 'createdAt'
  ),
  Review(
    id: 'rev_2',
    userId: 'user_2',  // Add this required field
    userName: 'Priya Sharma',
    userAvatar: 'https://ui-avatars.com/api/?name=Priya+Sharma&size=100&background=D946EF&color=fff',
    rating: 4,
    comment: 'Very thorough, though I wish there was more on testing. Still highly recommend it.',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),  // Changed from 'date' to 'createdAt'
  ),
  Review(
    id: 'rev_3',
    userId: 'user_3',  // Add this required field
    userName: 'James O\'Connor',
    userAvatar: 'https://ui-avatars.com/api/?name=James+OConnor&size=100&background=F97316&color=fff',
    rating: 5,
    comment: 'Instructor explains concepts clearly with real project examples. Loved it.',
    createdAt: DateTime.now().subtract(const Duration(days: 45)),  // Changed from 'date' to 'createdAt'
  ),
  Review(
    id: 'rev_4',
    userId: 'user_4',  // Add this required field
    userName: 'Ana Torres',
    userAvatar: 'https://ui-avatars.com/api/?name=Ana+Torres&size=100&background=16A34A&color=fff',
    rating: 3,
    comment: 'Good content but some videos feel a bit outdated with the newer Flutter versions.',
    createdAt: DateTime.now().subtract(const Duration(days: 60)),  // Changed from 'date' to 'createdAt'
  ),
];
  final studyMaterials = <StudyMaterial>[
    StudyMaterial(
      id: 'mat_1',
      title: 'Course Slides — Full Deck',
      type: StudyMaterialType.slides,
      sizeLabel: '8.4 MB',
      url: 'https://example.com/materials/slides.pdf',
    ),
    StudyMaterial(
      id: 'mat_2',
      title: 'Flutter Cheat Sheet',
      type: StudyMaterialType.pdf,
      sizeLabel: '1.2 MB',
      url: 'https://example.com/materials/cheatsheet.pdf',
      relatedSectionTitle: 'Widgets & Layout',
    ),
    StudyMaterial(
      id: 'mat_3',
      title: 'Starter Project Source Code',
      type: StudyMaterialType.zip,
      sizeLabel: '4.7 MB',
      url: 'https://example.com/materials/starter.zip',
      relatedSectionTitle: 'Getting Started',
    ),
    StudyMaterial(
      id: 'mat_4',
      title: 'State Management Comparison Doc',
      type: StudyMaterialType.doc,
      sizeLabel: '640 KB',
      url: 'https://example.com/materials/state-mgmt.docx',
      relatedSectionTitle: 'State Management',
    ),
    StudyMaterial(
      id: 'mat_5',
      title: 'Official Flutter Docs',
      type: StudyMaterialType.link,
      sizeLabel: 'External link',
      url: 'https://docs.flutter.dev',
    ),
  ];

  return Course(
    id: id,
    title: 'Flutter & Dart: The Complete Developer Course',
    description:
        'Learn Flutter from the ground up and build real, production-quality mobile apps for iOS and '
        'Android from a single codebase. This course covers widgets, layouts, navigation, state '
        'management (Provider & Riverpod), networking, local storage, animations, and publishing to '
        'the App Store and Play Store. By the end you will have shipped three complete apps.',
    thumbnail: 'https://picsum.photos/seed/flutter-course/900/600',
    price: 49.99,
    originalPrice: 129.99,
    level: 'Intermediate',
    language: 'English',
    duration: null,
    totalHours: 18.5,
    rating: 4.7,
    studentsCount: 52340,
    isPublished: true,
    isBestseller: true,
    isTrending: true,
    status: 'published',
    createdAt: DateTime(2023, 3, 14),
    updatedAt: DateTime.now().subtract(const Duration(days: 18)),
    instructorId: instructor.id,
    categoryId: category.id,
    instructor: instructor,
    category: category,
    sections: sections,
    enrollmentsCount: 52340,
    reviewsCount: reviews.length,
    lessonsCount: sections.fold(0, (sum, s) => sum + s.lessons.length),
    learningObjectives: const [],
    requirements: const [
      'Basic programming knowledge (any language) is helpful but not required',
      'A Mac, Windows, or Linux computer capable of running Android Studio / Xcode',
      'No prior Flutter or Dart experience needed',
    ],
    whatYouWillLearn: const [
      'Build beautiful, responsive UIs with Flutter widgets',
      'Manage app state with Provider and Riverpod',
      'Consume REST APIs and handle JSON serialization',
      'Navigate between screens with named routes and deep links',
      'Persist data locally with SQLite and shared_preferences',
      'Publish your app to the App Store and Google Play',
    ],
    reviews: reviews,
    studyMaterials: studyMaterials,
  );
}

/// Get dummy category by ID
Map<String, dynamic> getDummyCategoryById(String categoryId) {
  final categories = getDummyCategories();
  return categories.firstWhere(
    (c) => c['id'] == categoryId,
    orElse: () => {
      'id': categoryId,
      'name': 'Category',
      'description': 'Explore courses in this category',
      'courseCount': 0,
      'image': 'https://picsum.photos/seed/default/800/400',
      'color': '#2563EB',
      'icon': '📚',
    },
  );
}

// ============================================
// DUMMY CATEGORIES DATA
// ============================================

List<Map<String, dynamic>> getDummyCategories() {
  return [
    {
      'id': '1',
      'name': 'Programming',
      'slug': 'programming',
      'icon': Icons.code,
      'color': '#2563EB',
      'courseCount': 45,
      'image': 'https://picsum.photos/seed/programming/800/400',
      'description': 'Learn programming languages and development',
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Design',
      'slug': 'design',
      'icon': Icons.design_services,
      'color': '#7C3AED',
      'courseCount': 32,
      'image': 'https://picsum.photos/seed/design/800/400',
      'description': 'UI/UX, Graphic Design, and more',
      'isActive': true,
    },
    {
      'id': '3',
      'name': 'Business',
      'slug': 'business',
      'icon': Icons.business_center,
      'color': '#22C55E',
      'courseCount': 28,
      'image': 'https://picsum.photos/seed/business/800/400',
      'description': 'Business management and entrepreneurship',
      'isActive': true,
    },
    {
      'id': '4',
      'name': 'Marketing',
      'slug': 'marketing',
      'icon': Icons.campaign,
      'color': '#F59E0B',
      'courseCount': 20,
      'image': 'https://picsum.photos/seed/marketing/800/400',
      'description': 'Digital marketing and branding',
      'isActive': true,
    },
    {
      'id': '5',
      'name': 'Photography',
      'slug': 'photography',
      'icon': Icons.photo_camera,
      'color': '#EF4444',
      'courseCount': 15,
      'image': 'https://picsum.photos/seed/photography/800/400',
      'description': 'Photography techniques and editing',
      'isActive': true,
    },
    {
      'id': '6',
      'name': 'Music',
      'slug': 'music',
      'icon': Icons.music_note,
      'color': '#EC4899',
      'courseCount': 12,
      'image': 'https://picsum.photos/seed/music/800/400',
      'description': 'Music theory and production',
      'isActive': true,
    },
    {
      'id': '7',
      'name': 'Science',
      'slug': 'science',
      'icon': Icons.science,
      'color': '#06B6D4',
      'courseCount': 18,
      'image': 'https://picsum.photos/seed/science/800/400',
      'description': 'Physics, Chemistry, Biology and more',
      'isActive': true,
    },
    {
      'id': '8',
      'name': 'Artificial Intelligence',
      'slug': 'ai',
      'icon': Icons.psychology,
      'color': '#8B5CF6',
      'courseCount': 24,
      'image': 'https://picsum.photos/seed/ai/800/400',
      'description': 'Machine Learning, Deep Learning, AI',
      'isActive': true,
    },
  ];
}

// ============================================
// DUMMY CONTINUE LEARNING DATA
// ============================================

List<Map<String, dynamic>> getDummyContinueLearning() {
  return [
    {
      'courseId': 'course_1',
      'id': 'course_1',
      'title': 'Flutter & Dart: The Complete Developer Course',
      'description': 'Learn Flutter from the ground up and build real, production-quality mobile apps.',
      'thumbnail': 'https://picsum.photos/seed/flutter-course/400/300',
      'instructor': 'Sarah Mitchell',
      'instructorId': 'ins_1',
      'instructorAvatar': 'https://ui-avatars.com/api/?name=Sarah+Mitchell&size=100&background=0EA5E9&color=fff',
      'level': 'Intermediate',
      'category': 'Mobile Development',
      'price': 49.99,
      'originalPrice': 129.99,
      'discountPercent': 62,
      'rating': 4.7,
      'reviewsCount': 52340,
      'studentsCount': 52340,
      'language': 'English',
      'progress': 65,
      'isCompleted': false,
      'remainingTime': '2h 30m',
      'lastAccessed': DateTime.now().subtract(const Duration(hours: 5)),
      'sections': getDummySections(),
      'learningObjectives': [
        'Build professional Flutter applications',
        'Master Dart programming language',
        'Understand state management patterns',
        'Create responsive UI designs',
      ],
      'requirements': [
        'Basic programming knowledge',
        'Familiarity with OOP concepts',
        'No prior Flutter experience needed',
      ],
      'studyMaterials': getDummyStudyMaterials(),
      'whatYouWillLearn': [
        'Build beautiful, responsive UIs with Flutter widgets',
        'Manage app state with Provider and Riverpod',
        'Consume REST APIs and handle JSON serialization',
        'Navigate between screens with named routes',
      ],
    },
    {
      'courseId': 'course_2',
      'id': 'course_2',
      'title': 'React Native - Build Native Mobile Apps',
      'description': 'Master React Native with real-world projects.',
      'thumbnail': 'https://picsum.photos/seed/react-native/400/300',
      'instructor': 'Maximilian Schwarzmüller',
      'instructorId': 'inst_2',
      'instructorAvatar': 'https://ui-avatars.com/api/?name=Max+Schwarzmuller&size=100&background=8B5CF6&color=fff',
      'level': 'Beginner',
      'category': 'Mobile Development',
      'price': 79.99,
      'originalPrice': 129.99,
      'discountPercent': 38,
      'rating': 4.7,
      'reviewsCount': 9876,
      'studentsCount': 65432,
      'language': 'English',
      'progress': 30,
      'isCompleted': false,
      'remainingTime': '4h 15m',
      'lastAccessed': DateTime.now().subtract(const Duration(days: 2)),
      'sections': [],
      'learningObjectives': [],
      'requirements': [],
      'studyMaterials': [],
      'whatYouWillLearn': [],
    },
    {
      'courseId': 'course_3',
      'id': 'course_3',
      'title': 'Python for Data Science and Machine Learning',
      'description': 'Learn Python for data analysis and ML.',
      'thumbnail': 'https://picsum.photos/seed/python/400/300',
      'instructor': 'Jose Portilla',
      'instructorId': 'inst_3',
      'instructorAvatar': 'https://ui-avatars.com/api/?name=Jose+Portilla&size=100&background=059669&color=fff',
      'level': 'Intermediate',
      'category': 'Data Science',
      'price': 99.99,
      'originalPrice': 199.99,
      'discountPercent': 50,
      'rating': 4.9,
      'reviewsCount': 15432,
      'studentsCount': 123456,
      'language': 'English',
      'progress': 0,
      'isCompleted': false,
      'remainingTime': '8h 0m',
      'lastAccessed': DateTime.now().subtract(const Duration(days: 5)),
      'sections': [],
      'learningObjectives': [],
      'requirements': [],
      'studyMaterials': [],
      'whatYouWillLearn': [],
    },
    {
      'courseId': 'course_4',
      'id': 'course_4',
      'title': 'JavaScript - The Complete Guide',
      'description': 'Master JavaScript from basics to advanced.',
      'thumbnail': 'https://picsum.photos/seed/javascript/400/300',
      'instructor': 'Jonas Schmedtmann',
      'instructorId': 'inst_4',
      'instructorAvatar': 'https://ui-avatars.com/api/?name=Jonas+Schmedtmann&size=100&background=DC2626&color=fff',
      'level': 'Beginner',
      'category': 'Web Development',
      'price': 69.99,
      'originalPrice': 119.99,
      'discountPercent': 42,
      'rating': 4.8,
      'reviewsCount': 8765,
      'studentsCount': 54321,
      'language': 'English',
      'progress': 100,
      'isCompleted': true,
      'remainingTime': '0h 0m',
      'lastAccessed': DateTime.now().subtract(const Duration(days: 1)),
      'sections': [],
      'learningObjectives': [],
      'requirements': [],
      'studyMaterials': [],
      'whatYouWillLearn': [],
    },
  ];
}

// ============================================
// DUMMY SECTIONS AND LESSONS
// ============================================

List<Map<String, dynamic>> getDummySections() {
  return [
    {
      'id': 'sec_1',
      'title': 'Getting Started',
      'description': 'Environment setup and Flutter fundamentals',
      'order': 1,
      'lessons': [
        {
          'id': 'les_1',
          'title': 'Course Introduction',
          'description': 'What we will build and how the course is structured.',
          'duration': '4:32',
          'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          'order': 1,
          'isPreview': true,
          'isFree': true,
          'completed': true,
        },
        {
          'id': 'les_2',
          'title': 'Installing Flutter & Dart',
          'description': 'Setting up the SDK on macOS, Windows, and Linux.',
          'duration': '12:10',
          'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          'order': 2,
          'isPreview': false,
          'isFree': true,
          'completed': true,
        },
        {
          'id': 'les_3',
          'title': 'Project Structure Deep Dive',
          'description': 'Understanding the Flutter project structure',
          'duration': '9:45',
          'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          'order': 3,
          'isPreview': false,
          'isFree': false,
          'completed': false,
        },
      ],
    },
    {
      'id': 'sec_2',
      'title': 'Widgets & Layout',
      'description': 'Building responsive UI with Flutter widgets',
      'order': 2,
      'lessons': [
        {
          'id': 'les_4',
          'title': 'Stateless vs Stateful Widgets',
          'description': 'Understanding the difference between Stateless and Stateful widgets',
          'duration': '15:20',
          'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
          'order': 1,
          'isPreview': true,
          'isFree': false,
          'completed': true,
        },
        {
          'id': 'les_5',
          'title': 'Rows, Columns & Flex',
          'description': 'Building flexible layouts with Rows, Columns, and Flex widgets',
          'duration': '18:02',
          'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
          'order': 2,
          'isPreview': false,
          'isFree': false,
          'completed': false,
        },
        {
          'id': 'les_6',
          'title': 'ListView & GridView',
          'description': 'Creating scrollable lists and grids',
          'duration': '14:55',
          'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
          'order': 3,
          'isPreview': false,
          'isFree': false,
          'completed': false,
        },
      ],
    },
    {
      'id': 'sec_3',
      'title': 'State Management',
      'description': 'Provider, Riverpod, and Bloc compared',
      'order': 3,
      'lessons': [
        {
          'id': 'les_7',
          'title': 'Why State Management Matters',
          'description': 'Understanding the importance of state management',
          'duration': '10:00',
          'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
          'order': 1,
          'isPreview': false,
          'isFree': false,
          'completed': false,
        },
        {
          'id': 'les_8',
          'title': 'Provider in Depth',
          'description': 'Deep dive into the Provider package',
          'duration': '25:40',
          'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
          'order': 2,
          'isPreview': false,
          'isFree': false,
          'completed': false,
        },
      ],
    },
  ];
}

// ============================================
// DUMMY STUDY MATERIALS
// ============================================

List<Map<String, dynamic>> getDummyStudyMaterials() {
  return [
    {
      'id': 'mat_1',
      'title': 'Course Slides — Full Deck',
      'type': 'slides',
      'sizeLabel': '8.4 MB',
      'url': 'https://example.com/materials/slides.pdf',
    },
    {
      'id': 'mat_2',
      'title': 'Flutter Cheat Sheet',
      'type': 'pdf',
      'sizeLabel': '1.2 MB',
      'url': 'https://example.com/materials/cheatsheet.pdf',
      'relatedSectionTitle': 'Widgets & Layout',
    },
  ];
}

// ============================================
// DUMMY LIVE CLASSES
// ============================================

List<Map<String, dynamic>> getDummyLiveClasses() {
  return [
    {
      'id': '1',
      'title': 'Live Flutter Workshop',
      'instructor': 'John Doe',
      'date': 'Today',
      'time': '3:00 PM',
      'image': 'https://picsum.photos/400/200?random=10',
      'attendees': 45,
      'isLive': true,
    },
    {
      'id': '2',
      'title': 'UI/UX Design Live Session',
      'instructor': 'Jane Smith',
      'date': 'Tomorrow',
      'time': '10:00 AM',
      'image': 'https://picsum.photos/400/200?random=11',
      'attendees': 32,
      'isLive': false,
    },
    {
      'id': '3',
      'title': 'Data Science Bootcamp',
      'instructor': 'Alex Johnson',
      'date': 'Wed, 15 Jan',
      'time': '2:00 PM',
      'image': 'https://picsum.photos/400/200?random=12',
      'attendees': 28,
      'isLive': false,
    },
  ];
}

// ============================================
// DUMMY TOP INSTRUCTORS
// ============================================

List<Map<String, dynamic>> getDummyTopInstructors() {
  return [
    {
      'id': '1',
      'name': 'Maximilian Schwarzmüller',
      'title': 'Flutter & React Expert',
      'image': 'https://picsum.photos/100/100?random=20',
      'rating': 4.8,
      'students': 15000,
      'isFollowing': false,
    },
    {
      'id': '2',
      'name': 'Stephen Grider',
      'title': 'Mobile Development Specialist',
      'image': 'https://picsum.photos/100/100?random=21',
      'rating': 4.9,
      'students': 12000,
      'isFollowing': false,
    },
    {
      'id': '3',
      'name': 'Angela Yu',
      'title': 'Full Stack Developer',
      'image': 'https://picsum.photos/100/100?random=22',
      'rating': 4.7,
      'students': 18000,
      'isFollowing': false,
    },
  ];
}

// ============================================
// DUMMY RECENTLY VIEWED
// ============================================

List<Map<String, dynamic>> getDummyRecentlyViewed() {
  return [
    {
      'id': '1',
      'title': 'Advanced Flutter Animations',
      'image': 'https://picsum.photos/200/100?random=30',
      'progress': 20,
    },
    {
      'id': '2',
      'title': 'State Management in Flutter',
      'image': 'https://picsum.photos/200/100?random=31',
      'progress': 45,
    },
    {
      'id': '3',
      'title': 'Firebase Integration',
      'image': 'https://picsum.photos/200/100?random=32',
      'progress': 75,
    },
  ];
}

// ============================================
// DUMMY FEATURED COURSES
// ============================================

List<Map<String, dynamic>> getDummyFeaturedCourses() {
  return [
    {
      'id': 'featured_1',
      'title': 'Complete Web Development Bootcamp',
      'description': 'Learn HTML, CSS, JavaScript, Node.js, and MongoDB',
      'thumbnail': 'https://picsum.photos/seed/webdev/400/300',
      'instructor': 'Dr. Angela Yu',
      'rating': 4.8,
      'studentsCount': 45000,
      'price': 89.99,
      'originalPrice': 199.99,
      'level': 'Beginner',
      'isBestseller': true,
    },
    {
      'id': 'featured_2',
      'title': 'Machine Learning A-Z',
      'description': 'Learn Machine Learning with Python and R',
      'thumbnail': 'https://picsum.photos/seed/ml/400/300',
      'instructor': 'Kirill Eremenko',
      'rating': 4.7,
      'studentsCount': 32000,
      'price': 99.99,
      'originalPrice': 149.99,
      'level': 'Intermediate',
      'isBestseller': false,
    },
  ];
}

// ============================================
// DUMMY RECOMMENDED COURSES
// ============================================

List<Map<String, dynamic>> getDummyRecommendedCourses() {
  return [
    {
      'id': 'rec_1',
      'title': 'Python for Data Science',
      'description': 'Master Python for data analysis and visualization',
      'thumbnail': 'https://picsum.photos/seed/pythondata/400/300',
      'instructor': 'Jose Portilla',
      'rating': 4.9,
      'studentsCount': 25000,
      'price': 79.99,
      'originalPrice': 129.99,
      'level': 'Intermediate',
    },
    {
      'id': 'rec_2',
      'title': 'UI/UX Design Masterclass',
      'description': 'Learn UI/UX design from scratch',
      'thumbnail': 'https://picsum.photos/seed/uiuxdesign/400/300',
      'instructor': 'Sarah Mitchell',
      'rating': 4.6,
      'studentsCount': 18000,
      'price': 69.99,
      'originalPrice': 99.99,
      'level': 'Beginner',
    },
    {
      'id': 'rec_3',
      'title': 'Android App Development with Kotlin',
      'description': 'Build Android apps using Kotlin',
      'thumbnail': 'https://picsum.photos/seed/kotlin/400/300',
      'instructor': 'John Doe',
      'rating': 4.7,
      'studentsCount': 20000,
      'price': 89.99,
      'originalPrice': 159.99,
      'level': 'Intermediate',
    },
  ];
}

// ============================================
// DUMMY POPULAR COURSES
// ============================================

List<Map<String, dynamic>> getDummyPopularCourses() {
  return [
    {
      'id': 'pop_1',
      'title': 'The Complete JavaScript Course',
      'description': 'Master JavaScript from basics to advanced',
      'thumbnail': 'https://picsum.photos/seed/js/400/300',
      'instructor': 'Jonas Schmedtmann',
      'rating': 4.8,
      'studentsCount': 38000,
      'price': 59.99,
      'originalPrice': 89.99,
      'level': 'Beginner',
    },
    {
      'id': 'pop_2',
      'title': 'Docker & Kubernetes Masterclass',
      'description': 'Learn containerization and orchestration',
      'thumbnail': 'https://picsum.photos/seed/docker/400/300',
      'instructor': 'Maximilian Schwarzmüller',
      'rating': 4.7,
      'studentsCount': 15000,
      'price': 99.99,
      'originalPrice': 149.99,
      'level': 'Intermediate',
    },
  ];
}

// ============================================
// ENROLLMENT STATUS
// ============================================

/// Stand-in for the `/api/enroll/:id/status` call.
EnrollmentStatus getDummyEnrollmentStatus() {
  return EnrollmentStatus(isEnrolled: false, progress: 0, isCompleted: false);
}

// ============================================
// FORMATTING HELPERS
// ============================================

/// Format total duration from sections
String formatTotalDuration(List<CourseSection> sections) {
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

/// Format month and year
String formatMonthYear(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[date.month - 1]} ${date.year}';
}

/// Format relative date
String formatRelativeDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays < 1) return 'Today';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}