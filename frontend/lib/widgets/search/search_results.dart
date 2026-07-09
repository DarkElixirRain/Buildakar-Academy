import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../models/search_results.dart';

class SearchResultsWidget extends StatelessWidget {
  final SearchResults results;
  final Function(String) onCourseTap;
  final Function(String) onInstructorTap;
  final Function(String) onCategoryTap;

  const SearchResultsWidget({
    Key? key,
    required this.results,
    required this.onCourseTap,
    required this.onInstructorTap,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    // Filter out empty sections
    final hasCourses = results.courses.isNotEmpty;
    final hasInstructors = results.instructors.isNotEmpty;
    final hasCategories = results.categories.isNotEmpty;
    final hasResults = hasCourses || hasInstructors || hasCategories;

    if (!hasResults) {
      return _buildEmptyState(context, isDark);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search info
          _buildSearchInfo(context, isDark),
          const SizedBox(height: 16),

          // Categories (show first)
          if (hasCategories) ...[
            _buildSectionHeader(context, 'Categories', isDark),
            const SizedBox(height: 12),
            _buildCategoriesGrid(context),
            const SizedBox(height: 24),
          ],

          // Courses
          if (hasCourses) ...[
            _buildSectionHeader(
              context,
              'Courses (${results.courses.length})',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildCoursesList(context),
            const SizedBox(height: 24),
          ],

          // Instructors
          if (hasInstructors) ...[
            _buildSectionHeader(
              context,
              'Instructors (${results.instructors.length})',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildInstructorsList(context),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchInfo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Showing results for "${results.meta.query}"',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${results.meta.totalResults} results found',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.getPrimaryColor(isDark ? Brightness.light : Brightness.dark),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CATEGORIES GRID
  // ============================================

  Widget _buildCategoriesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: results.categories.length > 4 ? 4 : results.categories.length,
      itemBuilder: (context, index) {
        final category = results.categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategorySearchResult category) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return InkWell(
      onTap: () => onCategoryTap(category.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(int.parse(category.color.replaceFirst('#', '0xFF'))),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconFromString(category.icon),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${category.courseCount} courses',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // COURSES LIST
  // ============================================

  Widget _buildCoursesList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.courses.length > 5 ? 5 : results.courses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final course = results.courses[index];
        return _buildCourseCard(context, course);
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseSearchResult course) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return InkWell(
      onTap: () => onCourseTap(course.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 60,
                color: isDark ? Colors.grey[700] : Colors.grey[200],
                child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                    ? Image.network(
                        course.thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.school,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          );
                        },
                      )
                    : Icon(
                        Icons.school,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Course info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        course.instructor.fullName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      if (course.rating != null) ...[
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          course.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.studentsCount} students',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // INSTRUCTORS LIST
  // ============================================

  Widget _buildInstructorsList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.instructors.length > 5 ? 5 : results.instructors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final instructor = results.instructors[index];
        return _buildInstructorCard(context, instructor);
      },
    );
  }

  Widget _buildInstructorCard(BuildContext context, InstructorSearchResult instructor) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return InkWell(
      onTap: () => onInstructorTap(instructor.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: instructor.photo.isNotEmpty
                  ? NetworkImage(instructor.photo)
                  : null,
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
              child: instructor.photo.isEmpty
                  ? Text(
                      instructor.firstName.isNotEmpty ? instructor.firstName[0] : '?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Instructor info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        instructor.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (instructor.isVerified)
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.blue[400],
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    instructor.expertise,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${instructor.studentsCount} students',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.school_outlined,
                        size: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${instructor.coursesCount} courses',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'folder':
        return Icons.folder;
      case 'folder_open':
        return Icons.folder_open;
      case 'book':
        return Icons.book;
      case 'school':
        return Icons.school;
      case 'science':
        return Icons.science;
      case 'computer':
        return Icons.computer;
      case 'music_note':
        return Icons.music_note;
      case 'sports':
        return Icons.sports;
      case 'art_track':
        return Icons.art_track;
      case 'business':
        return Icons.business;
      case 'code':
        return Icons.code;
      case 'design_services':
        return Icons.design_services;
      case 'business_center':
        return Icons.business_center;
      case 'campaign':
        return Icons.campaign;
      case 'photo_camera':
        return Icons.photo_camera;
      default:
        return Icons.folder;
    }
  }
}