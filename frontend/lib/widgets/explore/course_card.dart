// lib/widgets/explore/course_card.dart
//
// CourseCard renders as a vertical "grid" card on wider layouts and can
// also render as a horizontal "list" card on narrow phones for a denser,
// more scannable feed. CourseGrid picks the right layout + column count
// automatically based on the available width.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import './explore_widget.dart';

enum CourseCardStyle { grid, list }

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final CourseCardStyle style;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const CourseCard({
    Key? key,
    required this.course,
    this.style = CourseCardStyle.grid,
    this.onTap,
    this.onBookmarkTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return style == CourseCardStyle.grid
        ? _GridCard(course: course, onTap: onTap, onBookmarkTap: onBookmarkTap)
        : _ListCard(course: course, onTap: onTap, onBookmarkTap: onBookmarkTap);
  }
}

/// ---------------------------------------------------------------------
/// Vertical card: image on top, details below. Used in grid layouts.
/// Matches the design from Featured / Recommended / Popular sections.
/// ---------------------------------------------------------------------
class _GridCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const _GridCard({required this.course, this.onTap, this.onBookmarkTap});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    final rating = (course['rating'] as num?)?.toDouble() ?? 0.0;
    final students = (course['students'] as num?)?.toInt() ?? 0;
    final price = (course['price'] as num?)?.toDouble() ?? 0.0;
    final discountPrice = (course['discountPrice'] as num?)?.toDouble() ?? 0.0;
    final hasDiscount = discountPrice > 0;
    final priceDisplay = course['priceDisplay']?.toString() ?? (price == 0 ? 'Free' : 'रू $price');
    final badge = course['badge']?.toString() ?? '📚 Course';
    final level = course['level']?.toString() ?? 'Beginner';
    final instructor = course['instructor']?.toString() ?? 'Unknown Instructor';
    final thumbnail = course['thumbnail']?.toString() ?? course['image']?.toString() ?? '';

    final screenWidth = MediaQuery.of(context).size.width;
    final fontSizeBadge = screenWidth < 380 ? 9.0 : 10.0;
    final fontSizeTitle = screenWidth < 380 ? 13.0 : 14.5;
    final fontSizeSubtitle = screenWidth < 380 ? 11.0 : 12.5;
    final paddingSize = screenWidth < 380 ? 8.0 : 10.0;
    final imageHeight = 110.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundElementColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: backgroundSelectedColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: thumbnail.isNotEmpty
                      ? Image.network(
                          thumbnail,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: primaryColor.withValues(alpha: 0.1),
                              child: Icon(Icons.image_outlined, size: 30, color: textSecondaryColor),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: backgroundSelectedColor,
                              child: const Center(
                                child: SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: imageHeight,
                          width: double.infinity,
                          color: primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.school_outlined, size: 30, color: textSecondaryColor),
                        ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade700, Colors.orange.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(color: Colors.white, fontSize: fontSizeBadge, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasDiscount)
                          Text(
                            'रू ${price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: fontSizeBadge,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (hasDiscount) const SizedBox(width: 4),
                        Text(
                          priceDisplay,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeBadge + 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(color: Colors.white, fontSize: fontSizeBadge, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(paddingSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
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
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: fontSizeSubtitle - 2, color: textSecondaryColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            instructor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: fontSizeSubtitle - 1,
                              color: textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: fontSizeSubtitle + 2),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(fontSize: fontSizeSubtitle, color: textColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$students students',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: fontSizeSubtitle - 2, color: textSecondaryColor),
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
}

/// ---------------------------------------------------------------------
/// Horizontal card: thumbnail on the left, details on the right.
/// Matches the design from Featured / Recommended / Popular sections.
/// ---------------------------------------------------------------------
class _ListCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const _ListCard({required this.course, this.onTap, this.onBookmarkTap});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);

    final rating = (course['rating'] as num?)?.toDouble() ?? 0.0;
    final students = (course['students'] as num?)?.toInt() ?? 0;
    final price = (course['price'] as num?)?.toDouble() ?? 0.0;
    final badge = course['badge']?.toString() ?? '📚 Course';
    final instructor = course['instructor']?.toString() ?? 'Unknown Instructor';
    final priceDisplay = course['priceDisplay']?.toString() ?? (price == 0 ? 'Free' : 'रू $price');
    final thumbnail = course['thumbnail']?.toString() ?? course['image']?.toString() ?? '';

    final screenWidth = MediaQuery.of(context).size.width;
    final fontSizeSubtitle = screenWidth < 380 ? 11.0 : 12.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundElementColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBackgroundSelectedColor(brightness)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  children: [
                    Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: backgroundColor,
                        child: Icon(Icons.image_not_supported_outlined, color: textSecondaryColor),
                      ),
                    ),
                    Positioned(
                      top: 4, left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade700, Colors.orange.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4, right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          priceDisplay,
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course['level'] != null)
                    LevelBadge(level: course['level'], brightness: brightness),
                  const SizedBox(height: 6),
                  Text(
                    course['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: fontSizeSubtitle - 2, color: textSecondaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          instructor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: fontSizeSubtitle - 1,
                            color: textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: fontSizeSubtitle + 2),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(fontSize: fontSizeSubtitle, color: textColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$students students',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: fontSizeSubtitle - 2, color: textSecondaryColor),
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
}

/// ---------------------------------------------------------------------
/// Responsive grid that adapts column count (and card style) to the
/// available width:
///   < 480   -> 1 column, horizontal list cards (dense, thumb-friendly)
///   480-780 -> 2 columns, grid cards
///   780-1100-> 3 columns
///   > 1100  -> 4 columns, content capped to a max width and centered
/// ---------------------------------------------------------------------
class CourseGrid extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final void Function(String courseId)? onCoursePress;
  final void Function(String courseId)? onBookmarkToggle;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const CourseGrid({
    Key? key,
    required this.courses,
    this.onCoursePress,
    this.onBookmarkToggle,
    this.physics,
    this.shrinkWrap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;
        double aspectRatio;
        if (width < 480) {
          columns = 2;
          aspectRatio = 0.66;
        } else if (width < 780) {
          columns = 2;
          aspectRatio = 0.66;
        } else if (width < 1100) {
          columns = 3;
          aspectRatio = 0.70;
        } else {
          columns = 4;
          aspectRatio = 0.72;
        }

        final content = GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, i) {
            final c = courses[i];
            return CourseCard(
              course: c,
              style: CourseCardStyle.grid,
              onTap: () => onCoursePress?.call(c['id'] ?? c['courseId'] ?? ''),
              onBookmarkTap: () => onBookmarkToggle?.call(c['id'] ?? c['courseId'] ?? ''),
            );
          },
        );

        // Cap and center content on very large (desktop/web) screens.
        if (width > 1100) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: content,
            ),
          );
        }
        return content;
      },
    );
  }
}