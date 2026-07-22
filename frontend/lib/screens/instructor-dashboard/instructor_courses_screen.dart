import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/instructor_course_provider.dart';
import '../../providers/instructor_dashboard_provider.dart';
import '../../models/course_model.dart';
import '../instructor/course_creation_screen.dart';
import '../instructor/instructor_course_detail_screen.dart';

class InstructorCoursesScreen extends StatefulWidget {
  const InstructorCoursesScreen({super.key});

  @override
  State<InstructorCoursesScreen> createState() => _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _statusFilter;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorCourseProvider>().loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final cardColor = AppColors.getBackgroundElementColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('My Courses', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: textSecondaryColor),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () => _openCreateCourse(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(searchController: _searchController, statusFilter: _statusFilter, onStatusChanged: (v) {
            setState(() => _statusFilter = v);
            context.read<InstructorCourseProvider>().loadCourses(status: v, search: _searchController.text);
          }, textColor: textColor, textSecondaryColor: textSecondaryColor, primaryColor: primaryColor, cardColor: cardColor),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<InstructorCourseProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.courses.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: textSecondaryColor),
                        const SizedBox(height: 12),
                        Text('Error loading courses', style: GoogleFonts.inter(color: textSecondaryColor)),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: () => provider.loadCourses(), child: const Text('Retry')),
                      ],
                    ),
                  );
                }

                if (provider.courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library_outlined, size: 80, color: textSecondaryColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('No courses yet', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 8),
                        Text('Create your first course', style: GoogleFonts.inter(color: textSecondaryColor)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _openCreateCourse(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Course'),
                        ),
                      ],
                    ),
                  );
                }

                if (_isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    ),
                    itemCount: provider.courses.length,
                    itemBuilder: (context, index) => _CourseGridCard(
                      course: provider.courses[index],
                      cardColor: cardColor, textColor: textColor, textSecondaryColor: textSecondaryColor,
                      onTap: () => _openCourseDetail(provider.courses[index]),
                      onDelete: () => _deleteCourse(provider, provider.courses[index]),
                      onTogglePublish: () => _togglePublish(provider, provider.courses[index]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.courses.length,
                  itemBuilder: (context, index) {
                    final course = provider.courses[index];
                    return _CourseListTile(
                      course: course, cardColor: cardColor, textColor: textColor, textSecondaryColor: textSecondaryColor,
                      primaryColor: primaryColor,
                      onTap: () => _openCourseDetail(course),
                      onDelete: () => _deleteCourse(provider, course),
                      onTogglePublish: () => _togglePublish(provider, course),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateCourse(BuildContext context) async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const CourseCreationScreen()));
    if (result == true && context.mounted) {
      context.read<InstructorCourseProvider>().loadCourses();
    }
  }

  void _openCourseDetail(Course course) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => InstructorCourseDetailScreen(courseId: course.id, courseTitle: course.title),
    ));
  }

  Future<void> _deleteCourse(InstructorCourseProvider provider, Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Delete "${course.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await provider.deleteCourse(course.id);
      if (context.mounted && ok) {
        context.read<InstructorDashboardProvider>().loadStats();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${course.title}" deleted'), backgroundColor: Colors.green));
      }
    }
  }

  Future<void> _togglePublish(InstructorCourseProvider provider, Course course) async {
    String newStatus;
    if (course.isPublished) {
      newStatus = 'DRAFT';
    } else if (course.status == 'DRAFT') {
      newStatus = 'UNDER_REVIEW';
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course status is "${statusLabel(course.status)}". No action available.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    final ok = await provider.updateCourseStatus(course.id, newStatus);
    if (context.mounted && ok) {
      context.read<InstructorDashboardProvider>().loadStats();
    }
  }
}

class _FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? statusFilter;
  final ValueChanged<String?> onStatusChanged;
  final Color textColor, textSecondaryColor, primaryColor, cardColor;

  const _FilterBar({
    required this.searchController, required this.statusFilter, required this.onStatusChanged,
    required this.textColor, required this.textSecondaryColor, required this.primaryColor, required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search courses...',
              hintStyle: GoogleFonts.inter(color: textSecondaryColor),
              prefixIcon: Icon(Icons.search, color: textSecondaryColor),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { searchController.clear(); onStatusChanged(statusFilter); })
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true, fillColor: cardColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: GoogleFonts.inter(color: textColor),
            onChanged: (v) => onStatusChanged(statusFilter),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'All', selected: statusFilter == null, onTap: () => onStatusChanged(null), primaryColor: primaryColor, cardColor: cardColor, textColor: textColor),
                const SizedBox(width: 8),
                _FilterChip(label: 'Published', selected: statusFilter == 'PUBLISHED', onTap: () => onStatusChanged('PUBLISHED'), primaryColor: primaryColor, cardColor: cardColor, textColor: textColor),
                const SizedBox(width: 8),
                _FilterChip(label: 'Pending', selected: statusFilter == 'PENDING_APPROVAL', onTap: () => onStatusChanged('PENDING_APPROVAL'), primaryColor: primaryColor, cardColor: cardColor, textColor: textColor),
                const SizedBox(width: 8),
                _FilterChip(label: 'Draft', selected: statusFilter == 'DRAFT', onTap: () => onStatusChanged('DRAFT'), primaryColor: primaryColor, cardColor: cardColor, textColor: textColor),
                _FilterChip(label: 'Under Review', selected: statusFilter == 'UNDER_REVIEW', onTap: () => onStatusChanged('UNDER_REVIEW'), primaryColor: primaryColor, cardColor: cardColor, textColor: textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor, cardColor, textColor;
  const _FilterChip({required this.label, required this.selected, required this.onTap, required this.primaryColor, required this.cardColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withValues(alpha: 0.1) : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? primaryColor : textColor.withValues(alpha: 0.1)),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: selected ? primaryColor : textColor, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

class _CourseListTile extends StatelessWidget {
  final Course course;
  final Color cardColor, textColor, textSecondaryColor, primaryColor;
  final VoidCallback onTap, onDelete, onTogglePublish;

  const _CourseListTile({
    required this.course, required this.cardColor, required this.textColor,
    required this.textSecondaryColor, required this.primaryColor,
    required this.onTap, required this.onDelete, required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  image: course.thumbnail.isNotEmpty ? DecorationImage(image: NetworkImage(course.thumbnail), fit: BoxFit.cover) : null,
                ),
                child: course.thumbnail.isEmpty ? Icon(Icons.video_library, color: primaryColor) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                      _StatusBadge(label: statusLabel(course.status), color: statusColor(course.status)),
                        const SizedBox(width: 8),
                        Text('${course.studentsCount} students', style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor)),
                        if (course.price > 0) ...[
                          const SizedBox(width: 8),
                          Text('\$${course.price.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: textSecondaryColor, size: 20),
                onSelected: (value) {
                  if (value == 'edit') onTap();
                  if (value == 'publish') onTogglePublish();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 20), title: Text('Edit'), dense: true, contentPadding: EdgeInsets.zero)),
                  if (course.status == 'PUBLISHED')
                    PopupMenuItem(value: 'publish', child: ListTile(
                      leading: Icon(Icons.radio_button_unchecked, size: 20, color: Colors.orange),
                      title: const Text('Unpublish'),
                      dense: true, contentPadding: EdgeInsets.zero,
                    ))
                  else if (course.status == 'DRAFT')
                    PopupMenuItem(value: 'publish', child: ListTile(
                      leading: Icon(Icons.send_rounded, size: 20, color: Colors.blue),
                      title: const Text('Submit for Review'),
                      dense: true, contentPadding: EdgeInsets.zero,
                    )),
                  const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 20, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)), dense: true, contentPadding: EdgeInsets.zero)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String statusLabel(String status) {
  switch (status) {
    case 'PUBLISHED': return 'Published';
    case 'PENDING_APPROVAL': return 'Pending';
    case 'DRAFT': return 'Draft';
    case 'UNDER_REVIEW': return 'Review';
    case 'REJECTED': return 'Rejected';
    default: return status;
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'PUBLISHED': return Colors.green;
    case 'PENDING_APPROVAL': return Colors.purple;
    case 'DRAFT': return Colors.orange;
    case 'UNDER_REVIEW': return Colors.blue;
    case 'REJECTED': return Colors.red;
    default: return Colors.grey;
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _CourseGridCard extends StatelessWidget {
  final Course course;
  final Color cardColor, textColor, textSecondaryColor;
  final VoidCallback onTap, onDelete, onTogglePublish;

  const _CourseGridCard({
    required this.course, required this.cardColor, required this.textColor,
    required this.textSecondaryColor, required this.onTap, required this.onDelete, required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey.withValues(alpha: 0.1),
                  image: course.thumbnail.isNotEmpty ? DecorationImage(image: NetworkImage(course.thumbnail), fit: BoxFit.cover) : null,
                ),
                child: course.thumbnail.isEmpty
                    ? Center(child: Icon(Icons.video_library, size: 40, color: textSecondaryColor.withValues(alpha: 0.3)))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatusBadge(label: statusLabel(course.status), color: statusColor(course.status)),
                      const Spacer(),
                      Text('${course.studentsCount}', style: GoogleFonts.inter(fontSize: 11, color: textSecondaryColor)),
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
