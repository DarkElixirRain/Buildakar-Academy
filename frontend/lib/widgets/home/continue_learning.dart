// lib/widgets/home/continue_learning.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/course/course_learning/course_learning.dart';
import '../../models/course_model.dart';

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class ContinueLearning extends StatefulWidget {
  final Function(String)? onCoursePress;
  final int limit;

  const ContinueLearning({Key? key, this.onCoursePress, this.limit = 10})
    : super(key: key);

  @override
  State<ContinueLearning> createState() => _ContinueLearningState();
}

class _ContinueLearningState extends State<ContinueLearning> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchContinueLearning();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      setState(() {
        _courses = [];
        _isLoading = false;
        _error = null;
      });
    }
  }

  // Helper method to safely convert to double
  double _safeToDouble(dynamic value) {
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

  // Helper method to safely convert to int
  int _safeToInt(dynamic value) {
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

  Future<void> _fetchContinueLearning() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _courses = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getContinueLearning(
        limit: widget.limit,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        final courses = response.data!;

        // First pass: process with existing heuristics
        final processedCourses = courses.map((course) {
          return _processCourseData(course);
        }).toList();

        // Second pass: for any course still missing a real instructor,
        // fetch the full course record
        final enrichedCourses = await Future.wait(
          processedCourses.map((course) async {
            final needsEnrichment =
                course['instructor'] == null ||
                course['instructor'] == 'Unknown Instructor' ||
                (course['instructor'] as String).trim().isEmpty;

            if (!needsEnrichment) return course;

            final courseId = course['courseId'] ?? course['id'];
            if (courseId == null) return course;

            try {
              final detailResponse = await _apiService.getCourseById(courseId);
              if (detailResponse.success && detailResponse.data != null) {
                final courseData = detailResponse.data!;

                // Try to extract instructor from course data
                String instructorName = 'Unknown Instructor';
                String instructorId = '';
                String instructorAvatar = '';

                // Check if instructor is in the data
                if (courseData['instructor'] != null) {
                  if (courseData['instructor'] is Map<String, dynamic>) {
                    final inst =
                        courseData['instructor'] as Map<String, dynamic>;
                    final firstName = inst['firstName']?.toString() ?? '';
                    final lastName = inst['lastName']?.toString() ?? '';
                    if (firstName.isNotEmpty || lastName.isNotEmpty) {
                      instructorName = '$firstName $lastName'.trim();
                    } else if (inst['name'] != null) {
                      instructorName = inst['name'].toString();
                    }
                    instructorId = inst['id']?.toString() ?? '';
                    instructorAvatar =
                        inst['photo']?.toString() ??
                        inst['avatar']?.toString() ??
                        '';
                  } else if (courseData['instructor'] is String) {
                    instructorName = courseData['instructor'].toString();
                  }
                }

                // Also check for instructorId directly
                if (instructorId.isEmpty) {
                  instructorId = courseData['instructorId']?.toString() ?? '';
                }

                // Check for instructorName directly
                if (instructorName == 'Unknown Instructor' &&
                    courseData['instructorName'] != null) {
                  instructorName = courseData['instructorName'].toString();
                }

                // Check for firstName and lastName directly
                if (instructorName == 'Unknown Instructor') {
                  final firstName = courseData['firstName']?.toString() ?? '';
                  final lastName = courseData['lastName']?.toString() ?? '';
                  if (firstName.isNotEmpty || lastName.isNotEmpty) {
                    instructorName = '$firstName $lastName'.trim();
                  }
                }

                // If we still don't have an instructor name, try to get it from the course's instructor relation
                if (instructorName == 'Unknown Instructor' &&
                    courseData['instructor'] != null) {
                  // Try parsing as Course model
                  try {
                    final fullCourse = Course.fromJson(courseData);
                    instructorName = fullCourse.instructor.fullName;
                    instructorId = fullCourse.instructor.id;
                    instructorAvatar = fullCourse.instructor.avatarUrl;
                  } catch (_) {
                    // Fallback to what we already have
                  }
                }

                final merged = Map<String, dynamic>.from(course);
                merged['instructor'] = instructorName;
                merged['instructorId'] = instructorId;
                merged['instructorAvatar'] = instructorAvatar;

                print(
                  '✅ Enriched course: ${course['title']} - Instructor: $instructorName',
                );
                return merged;
              }
            } catch (e) {
              print('❌ Failed to enrich course: $e');
            }
            return course;
          }),
        );

        setState(() {
          _courses = enrichedCourses;
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load continue learning courses';
          _isLoading = false;
          _courses = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _courses = [];
      });
    }
  }

  Map<String, dynamic> _processCourseData(Map<String, dynamic> course) {
    final processed = Map<String, dynamic>.from(course);

    String instructorName = 'Unknown Instructor';
    String instructorId = course['instructorId'] ?? '';
    String instructorAvatar = course['instructorAvatar'] ?? '';

    if (course['course'] != null && course['course'] is Map<String, dynamic>) {
      final courseData = course['course'] as Map<String, dynamic>;

      if (courseData['instructor'] != null) {
        if (courseData['instructor'] is Map<String, dynamic>) {
          final inst = courseData['instructor'] as Map<String, dynamic>;
          final firstName = inst['firstName'] ?? '';
          final lastName = inst['lastName'] ?? '';
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            instructorName = '$firstName $lastName'.trim();
          } else if (inst['name'] != null) {
            instructorName = inst['name'] as String;
          }
          instructorId = inst['id'] ?? instructorId;
          instructorAvatar =
              inst['photo'] ?? inst['avatar'] ?? instructorAvatar;
        } else if (courseData['instructor'] is String) {
          instructorName = courseData['instructor'] as String;
        }
      }

      if (courseData['title'] != null && processed['title'] == null) {
        processed['title'] = courseData['title'];
      }
      if (courseData['thumbnail'] != null && processed['thumbnail'] == null) {
        processed['thumbnail'] = courseData['thumbnail'];
      }
    }

    if (course['instructor'] != null &&
        course['instructor'] is Map<String, dynamic>) {
      final inst = course['instructor'] as Map<String, dynamic>;
      final firstName = inst['firstName'] ?? '';
      final lastName = inst['lastName'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        instructorName = '$firstName $lastName'.trim();
      } else if (inst['name'] != null) {
        instructorName = inst['name'] as String;
      }
      instructorId = inst['id'] ?? instructorId;
      instructorAvatar = inst['photo'] ?? inst['avatar'] ?? instructorAvatar;
    } else if (course['instructor'] != null && course['instructor'] is String) {
      instructorName = course['instructor'] as String;
    } else if (course['instructorName'] != null) {
      instructorName = course['instructorName'] as String;
    } else if (course['name'] != null) {
      instructorName = course['name'] as String;
    } else if (course['firstName'] != null || course['lastName'] != null) {
      final firstName = course['firstName'] ?? '';
      final lastName = course['lastName'] ?? '';
      instructorName = '$firstName $lastName'.trim();
    } else if (course['user'] != null &&
        course['user'] is Map<String, dynamic>) {
      final user = course['user'] as Map<String, dynamic>;
      final firstName = user['firstName'] ?? '';
      final lastName = user['lastName'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        instructorName = '$firstName $lastName'.trim();
      }
      instructorAvatar = user['photo'] ?? instructorAvatar;
    }

    processed['instructor'] = instructorName;
    processed['instructorId'] = instructorId;
    processed['instructorAvatar'] = instructorAvatar;

    // Convert numeric values safely using _safeToDouble and _safeToInt
    processed['price'] = _safeToDouble(course['price']);
    processed['originalPrice'] = _safeToDouble(course['originalPrice']);
    processed['rating'] = _safeToDouble(course['rating']);
    processed['studentsCount'] = _safeToInt(course['studentsCount']);
    processed['reviewsCount'] = _safeToInt(course['reviewsCount']);
    processed['progress'] = _safeToDouble(course['progress']);

    if (instructorName == 'Unknown Instructor' && course['email'] != null) {
      final email = course['email'] as String;
      final parts = email.split('@');
      if (parts.isNotEmpty) {
        final nameParts = parts[0].split('.');
        if (nameParts.length >= 2) {
          instructorName =
              '${nameParts[0].capitalize()} ${nameParts[1].capitalize()}';
          processed['instructor'] = instructorName;
        }
      }
    }

    return processed;
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await _fetchContinueLearning();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Course _createCourseFromMap(Map<String, dynamic> data) {
    final processedData = _processCourseData(data);

    List<CourseSection> sections = [];
    if (processedData['sections'] != null &&
        processedData['sections'] is List) {
      sections = (processedData['sections'] as List).map((sectionData) {
        List<Lesson> lessons = [];
        if (sectionData['lessons'] != null && sectionData['lessons'] is List) {
          lessons = (sectionData['lessons'] as List).map((lessonData) {
            return Lesson(
              id: lessonData['id'] ?? '',
              title: lessonData['title'] ?? '',
              description: lessonData['description'],
              duration: lessonData['duration'] ?? '',
              videoUrl: lessonData['videoUrl'] ?? '',
              order: _safeToInt(lessonData['order']),
              isPreview: lessonData['isPreview'] ?? false,
              isFree: lessonData['isFree'] ?? false,
              content: lessonData['content'],
              completed: lessonData['completed'] ?? false,
            );
          }).toList();
        }
        return CourseSection(
          id: sectionData['id'] ?? '',
          title: sectionData['title'] ?? '',
          description: sectionData['description'],
          order: _safeToInt(sectionData['order']),
          lessons: lessons,
        );
      }).toList();
    }

    List<String> learningObjectives = [];
    if (processedData['learningObjectives'] != null &&
        processedData['learningObjectives'] is List) {
      learningObjectives = List<String>.from(
        processedData['learningObjectives'],
      );
    }
    if (processedData['whatYouWillLearn'] != null &&
        processedData['whatYouWillLearn'] is List &&
        learningObjectives.isEmpty) {
      learningObjectives = List<String>.from(processedData['whatYouWillLearn']);
    }

    List<String> requirements = [];
    if (processedData['requirements'] != null &&
        processedData['requirements'] is List) {
      requirements = List<String>.from(processedData['requirements']);
    }

    List<StudyMaterial> studyMaterials = [];
    if (processedData['studyMaterials'] != null &&
        processedData['studyMaterials'] is List) {
      studyMaterials = (processedData['studyMaterials'] as List).map((
        materialData,
      ) {
        StudyMaterialType type;
        switch (materialData['type']?.toString().toLowerCase()) {
          case 'pdf':
            type = StudyMaterialType.pdf;
            break;
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
          id: materialData['id'] ?? '',
          title: materialData['title'] ?? '',
          type: type,
          sizeLabel: materialData['sizeLabel'] ?? '',
          url: materialData['url'] ?? '',
          relatedSectionTitle: materialData['relatedSectionTitle'],
        );
      }).toList();
    }

    String instructorName = processedData['instructor'] ?? 'Unknown Instructor';
    String instructorId = processedData['instructorId'] ?? '';
    String instructorAvatar = processedData['instructorAvatar'] ?? '';

    List<String> nameParts = instructorName.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts.first : 'Instructor';
    String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';

    final instructor = Instructor(
      id: instructorId,
      firstName: firstName,
      lastName: lastName,
      email: '',
      photo: instructorAvatar.isNotEmpty ? instructorAvatar : null,
      bio: '',
      rating: _safeToDouble(processedData['rating']),
      studentsCount: _safeToInt(processedData['studentsCount']),
      coursesCount: 0,
    );

    final category = CourseCategory(
      id: 'cat_1',
      name: processedData['category'] ?? 'General',
      slug:
          processedData['category']?.toLowerCase().replaceAll(' ', '-') ??
          'general',
    );

    return Course(
      id: processedData['courseId'] ?? processedData['id'] ?? '',
      title: processedData['title'] ?? '',
      description: processedData['description'] ?? '',
      thumbnail: processedData['thumbnail'] ?? '',
      price: _safeToDouble(processedData['price']),
      originalPrice: _safeToDouble(processedData['originalPrice']),
      level: processedData['level'] ?? 'Beginner',
      language: processedData['language'] ?? 'English',
      rating: _safeToDouble(processedData['rating']),
      studentsCount: _safeToInt(processedData['studentsCount']),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      instructorId: instructorId,
      categoryId: 'cat_1',
      instructor: instructor,
      category: category,
      sections: sections,
      reviewsCount: _safeToInt(processedData['reviewsCount']),
      whatYouWillLearn: learningObjectives,
      requirements: requirements,
      studyMaterials: studyMaterials,
      reviews: [],
      learningObjectives: learningObjectives,
    );
  }

  void _navigateToLearning(Map<String, dynamic> courseData) {
    final courseId = courseData['courseId'] ?? courseData['id'];

    try {
      final course = _createCourseFromMap(courseData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CourseLearningPage(courseId: courseId, course: course),
        ),
      );
    } catch (e) {
      final processedData = _processCourseData(courseData);
      String instructorName = processedData['instructor'] ?? 'Instructor';
      List<String> nameParts = instructorName.split(' ');
      String firstName = nameParts.isNotEmpty ? nameParts.first : 'Instructor';
      String lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final instructor = Instructor(
        id: processedData['instructorId'] ?? '',
        firstName: firstName,
        lastName: lastName,
        email: '',
        photo: processedData['instructorAvatar'],
        bio: '',
        rating: 0,
        studentsCount: 0,
        coursesCount: 0,
      );

      final category = CourseCategory(
        id: 'cat_1',
        name: processedData['category'] ?? 'General',
        slug:
            processedData['category']?.toLowerCase().replaceAll(' ', '-') ??
            'general',
      );

      final minimalCourse = Course(
        id: courseId,
        title: processedData['title'] ?? 'Course',
        description: processedData['description'] ?? '',
        thumbnail: processedData['thumbnail'] ?? '',
        rating: _safeToDouble(processedData['rating']),
        reviewsCount: _safeToInt(processedData['reviewsCount']),
        price: _safeToDouble(processedData['price']),
        originalPrice: _safeToDouble(processedData['originalPrice']),
        level: processedData['level'] ?? 'Beginner',
        language: processedData['language'] ?? 'English',
        studentsCount: _safeToInt(processedData['studentsCount']),
        sections: [],
        instructor: instructor,
        category: category,
        whatYouWillLearn: [],
        requirements: [],
        studyMaterials: [],
        reviews: [],
        learningObjectives: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        instructorId: processedData['instructorId'] ?? '',
        categoryId: 'cat_1',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CourseLearningPage(courseId: courseId, course: minimalCourse),
        ),
      );
    }
  }

  void _handleCoursePress(Map<String, dynamic> course) {
    if (widget.onCoursePress != null) {
      widget.onCoursePress!(course['courseId'] ?? course['id']);
    } else {
      _navigateToLearning(course);
    }
  }

  void _handleCourseCardPress(Map<String, dynamic> course) {
    final id = course['courseId'] ?? course['id'];
    if (widget.onCoursePress != null) {
      widget.onCoursePress!(id);
    } else {
      Navigator.pushNamed(context, '/course', arguments: {'courseId': id});
    }
  }

  void _handleSeeAll() {
    Navigator.pushNamed(context, '/my-learning');
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get theme-aware colors
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final errorColor = AppColors.getErrorColor(brightness);
    final successColor = AppColors.getSuccessColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    double cardWidth;
    double cardHeight;
    double imageHeight;
    double fontSizeTitle;
    double fontSizeSubtitle;
    double fontSizeBadge;
    double paddingSize;
    double buttonHeight;
    double progressBarHeight;

    if (screenWidth < 380) {
      cardWidth = screenWidth * 0.75;
      cardHeight = screenHeight * 0.30;
      imageHeight = cardHeight * 0.40;
      fontSizeTitle = 12;
      fontSizeSubtitle = 10;
      fontSizeBadge = 8;
      paddingSize = 6;
      buttonHeight = 28;
      progressBarHeight = 3;
    } else if (screenWidth < 600) {
      cardWidth = screenWidth * 0.65;
      cardHeight = screenHeight * 0.32;
      imageHeight = cardHeight * 0.40;
      fontSizeTitle = 13;
      fontSizeSubtitle = 11;
      fontSizeBadge = 9;
      paddingSize = 8;
      buttonHeight = 30;
      progressBarHeight = 4;
    } else if (screenWidth < 900) {
      cardWidth = screenWidth * 0.40;
      cardHeight = screenHeight * 0.34;
      imageHeight = cardHeight * 0.40;
      fontSizeTitle = 14;
      fontSizeSubtitle = 12;
      fontSizeBadge = 10;
      paddingSize = 10;
      buttonHeight = 34;
      progressBarHeight = 4;
    } else {
      cardWidth = screenWidth * 0.28;
      cardHeight = screenHeight * 0.36;
      imageHeight = cardHeight * 0.40;
      fontSizeTitle = 15;
      fontSizeSubtitle = 13;
      fontSizeBadge = 11;
      paddingSize = 12;
      buttonHeight = 36;
      progressBarHeight = 5;
    }

    cardWidth = cardWidth.clamp(180.0, 380.0);
    cardHeight = cardHeight.clamp(200.0, 360.0);
    imageHeight = imageHeight.clamp(80.0, 160.0);

    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Continue Learning',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          _buildSkeletonLoading(isDark, cardWidth, cardHeight, brightness),
        ],
      );
    }

    if (!authProvider.isAuthenticated) {
      return _buildNotAuthenticated(isDark, brightness);
    }

    if (_error != null) {
      return _buildErrorState(isDark, brightness);
    }

    if (_courses.isEmpty) {
      return _buildEmptyState(isDark, brightness);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Continue Learning',
                  style: TextStyle(
                    fontSize: screenWidth < 380 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _handleSeeAll,
                child: Text(
                  'See All (${_courses.length})',
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
        SizedBox(
          height: cardHeight + 10,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: primaryColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _courses.length,
              padding: const EdgeInsets.only(right: 16),
              itemBuilder: (context, index) {
                final course = _courses[index];
                final isCompleted = course['isCompleted'] ?? false;
                // Ensure progress is a double using _safeToDouble
                final progress = _safeToDouble(
                  course['progress'],
                ).clamp(0.0, 100.0);
                final progressColor = isCompleted
                    ? successColor
                    : primaryColor;

                return _buildCourseCard(
                  context,
                  course,
                  index,
                  cardWidth,
                  cardHeight,
                  imageHeight,
                  progress,
                  progressColor,
                  isCompleted,
                  isDark,
                  brightness,
                  fontSizeTitle,
                  fontSizeSubtitle,
                  fontSizeBadge,
                  paddingSize,
                  buttonHeight,
                  progressBarHeight,
                  screenWidth,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    int index,
    double cardWidth,
    double cardHeight,
    double imageHeight,
    double progress,
    Color progressColor,
    bool isCompleted,
    bool isDark,
    Brightness brightness,
    double fontSizeTitle,
    double fontSizeSubtitle,
    double fontSizeBadge,
    double paddingSize,
    double buttonHeight,
    double progressBarHeight,
    double screenWidth,
  ) {
    // Get theme-aware colors
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final successColor = AppColors.getSuccessColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    final isLast = index == _courses.length - 1;
    // Ensure progress is a double between 0 and 1 for the indicator
    final progressValue = (progress / 100.0).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _handleCourseCardPress(course),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(right: isLast ? 0 : 12),
        decoration: BoxDecoration(
          color: backgroundElementColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: backgroundSelectedColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : const Color(0xFF0F172A).withValues(alpha: 0.06),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child:
                      course['thumbnail'] != null &&
                          course['thumbnail'].toString().isNotEmpty
                      ? Image.network(
                          course['thumbnail'],
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: primaryColor.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.image_outlined,
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
                            Icons.school_outlined,
                            size: 30,
                            color: textSecondaryColor,
                          ),
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${progress.round()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeBadge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: successColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: fontSizeBadge + 2,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSizeBadge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (course['level'] != null)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        course['level'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeBadge,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: fontSizeBadge + 2,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          course['remainingTime'] ?? 'In progress',
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
                    SizedBox(
                      height: fontSizeTitle * 2.4,
                      child: Text(
                        course['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSizeTitle,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: fontSizeSubtitle + 2,
                      child: Text(
                        course['instructor'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSizeSubtitle,
                          color: textSecondaryColor,
                        ),
                      ),
                    ),
                    if (course['category'] != null)
                      SizedBox(
                        height: fontSizeSubtitle,
                        child: Text(
                          course['category'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: fontSizeSubtitle - 2,
                            color: textSecondaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: paddingSize * 0.5,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE5E7EB),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progressColor,
                                ),
                                minHeight: progressBarHeight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.round()}%',
                            style: TextStyle(
                              fontSize: fontSizeSubtitle - 1,
                              fontWeight: FontWeight.w600,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => _handleCoursePress(course),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted
                              ? successColor
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
                          isCompleted ? 'Review' : 'Resume',
                          style: TextStyle(
                            fontSize: fontSizeSubtitle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildSkeletonLoading(
    bool isDark,
    double cardWidth,
    double cardHeight,
    Brightness brightness,
  ) {
    final textColor = AppColors.getTextColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return SizedBox(
      height: cardHeight + 10,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: const EdgeInsets.only(right: 16),
        itemBuilder: (context, index) {
          return Container(
            width: cardWidth,
            height: cardHeight,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: backgroundElementColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: backgroundSelectedColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: cardHeight * 0.40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2E3135)
                        : const Color(0xFFE5E7EB),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2E3135)
                                : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 10,
                          width: 80,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2E3135)
                                : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2E3135)
                                : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 28,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2E3135)
                                : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotAuthenticated(bool isDark, Brightness brightness) {
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
          child: Text(
            'Continue Learning',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
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
                Icons.login_outlined,
                size: 40,
                color: textSecondaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                'Login to Continue Learning',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to track your progress',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(bool isDark, Brightness brightness) {
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final errorColor = AppColors.getErrorColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Continue Learning',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
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
                Icons.error_outline,
                size: 40,
                color: errorColor,
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to Load Courses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _error ?? 'Something went wrong. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchContinueLearning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, Brightness brightness) {
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
          child: Text(
            'Continue Learning',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
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
                Icons.school_outlined,
                size: 40,
                color: textSecondaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                'No courses in progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Browse our catalog and start learning today!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/browse');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Browse Courses',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}