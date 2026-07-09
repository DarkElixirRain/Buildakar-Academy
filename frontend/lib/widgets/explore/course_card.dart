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
/// ---------------------------------------------------------------------
class _GridCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const _GridCard({required this.course, this.onTap, this.onBookmarkTap});

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);

    final bool isBookmarked = course['isBookmarked'] == true;
    final double? oldPrice = (course['oldPrice'] as num?)?.toDouble();
    final double price = (course['price'] as num?)?.toDouble() ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundElementColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ExploreColors.border(brightness)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Thumbnail ----
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    course['thumbnail'] ?? course['image'] ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: backgroundColor);
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: backgroundColor,
                      child: Icon(Icons.image_not_supported_outlined, color: textSecondaryColor),
                    ),
                  ),
                  if (course['level'] != null)
                    Positioned(top: 10, left: 10, child: LevelBadge(level: course['level'])),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _BookmarkButton(
                      isBookmarked: isBookmarked,
                      onTap: onBookmarkTap,
                      brightness: brightness,
                    ),
                  ),
                  if (oldPrice != null && oldPrice > price)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(((oldPrice - price) / oldPrice) * 100).round()}% OFF',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ---- Details ----
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course['category'] != null)
                    Text(
                      (course['category'] as String).toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    course['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course['instructor'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (course['rating'] != null) ...[
                        RatingPill(rating: (course['rating'] as num).toDouble()),
                        const SizedBox(width: 6),
                        Text(
                          '(${course['students'] ?? 0})',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (oldPrice != null && oldPrice > price)
                        Text(
                          '\$${oldPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: textSecondaryColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        price == 0 ? 'Free' : '\$${price.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
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
}

/// ---------------------------------------------------------------------
/// Horizontal card: thumbnail on the left, details on the right.
/// Great for dense phone-width lists.
/// ---------------------------------------------------------------------
class _ListCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const _ListCard({required this.course, this.onTap, this.onBookmarkTap});

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    
    final bool isBookmarked = course['isBookmarked'] == true;
    final double price = (course['price'] as num?)?.toDouble() ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundElementColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ExploreColors.border(brightness)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 96,
                height: 96,
                child: Image.network(
                  course['thumbnail'] ?? course['image'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: backgroundColor,
                    child: Icon(Icons.image_not_supported_outlined, color: textSecondaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course['level'] != null) LevelBadge(level: course['level']),
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
                  Text(
                    course['instructor'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (course['rating'] != null)
                        RatingPill(rating: (course['rating'] as num).toDouble()),
                      const Spacer(),
                      Text(
                        price == 0 ? 'Free' : '\$${price.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _BookmarkButton(
              isBookmarked: isBookmarked,
              onTap: onBookmarkTap,
              small: true,
              brightness: brightness,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback? onTap;
  final bool small;
  final Brightness brightness;

  const _BookmarkButton({
    required this.isBookmarked,
    this.onTap,
    this.small = false,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: small ? 30 : 32,
        height: small ? 30 : 32,
        decoration: BoxDecoration(
          color: small ? backgroundColor : Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: 17,
          color: isBookmarked ? primaryColor : (small ? primaryColor : Colors.white),
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

        if (width < 480) {
          // Single-column dense list on small phones.
          return ListView.separated(
            shrinkWrap: shrinkWrap,
            physics: physics ?? const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final c = courses[i];
              return CourseCard(
                course: c,
                style: CourseCardStyle.list,
                onTap: () => onCoursePress?.call(c['id'] ?? c['courseId'] ?? ''),
                onBookmarkTap: () => onBookmarkToggle?.call(c['id'] ?? c['courseId'] ?? ''),
              );
            },
          );
        }

        int columns;
        double aspectRatio;
        if (width < 780) {
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