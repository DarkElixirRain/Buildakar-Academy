import 'package:flutter/material.dart';
import '../../../models/course_model.dart';
import '../../../constants/colors.dart';  // Changed import

class CourseCurriculum extends StatefulWidget {
  final List<CourseSection> sections;
  final String totalDurationLabel;
  final bool isEnrolled;
  final Brightness brightness;  // Changed from AppColors to Brightness
  final void Function(Lesson lesson) onPlayLesson;

  const CourseCurriculum({
    super.key,
    required this.sections,
    required this.totalDurationLabel,
    required this.isEnrolled,
    required this.brightness,  // Changed
    required this.onPlayLesson,
  });

  @override
  State<CourseCurriculum> createState() => _CourseCurriculumState();
}

class _CourseCurriculumState extends State<CourseCurriculum> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    if (widget.sections.isNotEmpty) _expanded.add(widget.sections.first.id);
  }

  bool _isLessonLocked(Lesson lesson) => !widget.isEnrolled && !lesson.isUnlockedPreview;

  // Helper getters
  Brightness get _brightness => widget.brightness;
  Color get _textColor => AppColors.getTextColor(_brightness);
  Color get _backgroundColor => AppColors.getBackgroundColor(_brightness);
  Color get _backgroundElementColor => AppColors.getBackgroundElementColor(_brightness);
  Color get _backgroundSelectedColor => AppColors.getBackgroundSelectedColor(_brightness);
  Color get _textSecondaryColor => AppColors.getTextSecondaryColor(_brightness);
  Color get _primaryColor => AppColors.getPrimaryColor(_brightness);
  Color get _successColor => AppColors.getSuccessColor(_brightness);
  Color get _errorColor => AppColors.getErrorColor(_brightness);
  Color get _badgeBg => _primaryColor.withValues(alpha: 0.15);

  @override
  Widget build(BuildContext context) {
    final totalLessons = widget.sections.fold<int>(0, (sum, s) => sum + s.lessons.length);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.sections.length} sections • $totalLessons lessons',
                style: TextStyle(color: _textSecondaryColor, fontSize: 13),
              ),
              Text(
                widget.totalDurationLabel,
                style: TextStyle(color: _textSecondaryColor, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.sections.map((section) => _buildSectionTile(section)),
        ],
      ),
    );
  }

  Widget _buildSectionTile(CourseSection section) {
    final isOpen = _expanded.contains(section.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _backgroundElementColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _backgroundSelectedColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              isOpen ? _expanded.remove(section.id) : _expanded.add(section.id);
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${section.lessonCount} lessons',
                          style: TextStyle(color: _textSecondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: _textSecondaryColor,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            ...section.lessons.map((lesson) => _buildLessonRow(lesson)),
        ],
      ),
    );
  }

  Widget _buildLessonRow(Lesson lesson) {
    final locked = _isLessonLocked(lesson);
    return InkWell(
      onTap: () {
        if (locked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enroll in this course to unlock this lesson')),
          );
          return;
        }
        widget.onPlayLesson(lesson);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: _backgroundSelectedColor)),
        ),
        child: Row(
          children: [
            Icon(
              lesson.completed
                  ? Icons.check_circle
                  : locked
                      ? Icons.lock_outline
                      : Icons.play_circle_outline,
              size: 20,
              color: lesson.completed
                  ? _successColor
                  : locked
                      ? _textSecondaryColor
                      : _primaryColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lesson.title,
                style: TextStyle(
                  color: locked ? _textSecondaryColor : _textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (lesson.isUnlockedPreview && !widget.isEnrolled)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _badgeBg, borderRadius: BorderRadius.circular(6)),
                child: Text('Preview', style: TextStyle(fontSize: 10, color: _primaryColor, fontWeight: FontWeight.w600)),
              ),
            Text(
              lesson.duration ?? '--:--',
              style: TextStyle(color: _textSecondaryColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}