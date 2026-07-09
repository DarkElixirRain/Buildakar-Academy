// lib/widgets/course/notes_list.dart
import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../theme/app_colors.dart';

class NotesList extends StatefulWidget {
  final List<NoteItem> notes;
  final List<Lesson> lessons;
  final AppColors colors;
  final void Function(NoteItem note) onAdd;
  final void Function(NoteItem note) onUpdate;
  final void Function(String noteId) onDelete;

  const NotesList({
    super.key,
    required this.notes,
    required this.lessons,
    required this.colors,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  Future<void> _openEditor({NoteItem? existing}) async {
    final colors = widget.colors;
    
    // Get the initial values
    String selectedLesson = existing?.lessonTitle ?? 
        (widget.lessons.isNotEmpty ? widget.lessons.first.title : 'General');
    final controller = TextEditingController(text: existing?.content ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.backgroundElement,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'New note' : 'Edit note',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLesson,
                    decoration: const InputDecoration(
                      labelText: 'Lesson',
                      border: OutlineInputBorder()
                    ),
                    items: [
                      ...widget.lessons.map((l) => DropdownMenuItem(
                        value: l.title,
                        child: Text(l.title, overflow: TextOverflow.ellipsis)
                      )),
                      const DropdownMenuItem(
                        value: 'General',
                        child: Text('General')
                      ),
                    ],
                    onChanged: (v) => setSheetState(() {
                      if (v != null) selectedLesson = v;
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Your note',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14)
                      ),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        
                        final now = DateTime.now();
                        
                        if (existing == null) {
                          // Create new note
                          widget.onAdd(NoteItem(
                            id: 'note_${now.microsecondsSinceEpoch}',
                            lessonId: _getLessonId(selectedLesson),
                            lessonTitle: selectedLesson,
                            content: text,
                            courseId: '', // You'll need to pass this from parent
                            createdAt: now,
                            updatedAt: now,
                          ));
                        } else {
                          // Create a new NoteItem with updated values
                          final updatedNote = NoteItem(
                            id: existing.id,
                            lessonId: _getLessonId(selectedLesson),
                            lessonTitle: selectedLesson,
                            content: text,
                            courseId: existing.courseId,
                            createdAt: existing.createdAt,
                            updatedAt: now,
                          );
                          widget.onUpdate(updatedNote);
                        }
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        existing == null ? 'Save note' : 'Update note',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Helper to get lesson ID from title
  String _getLessonId(String lessonTitle) {
    if (lessonTitle == 'General') return 'general';
    final lesson = widget.lessons.firstWhere(
      (l) => l.title == lessonTitle,
      orElse: () => widget.lessons.first,
    );
    return lesson.id;
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My notes',
                style: TextStyle(
                  color: colors.text,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold
                ),
              ),
              TextButton.icon(
                onPressed: () => _openEditor(),
                icon: Icon(Icons.add, size: 18, color: colors.primary),
                label: Text(
                  'Add note',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (widget.notes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: isSmallScreen ? 30 : 40,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No notes yet — tap "Add note" to jot something down.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: isSmallScreen ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...widget.notes.map((n) => Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.backgroundElement,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.textSecondary.withValues(alpha: 0.1), // ✅ Fixed: withOpacity instead of withValues
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.lessonTitle,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: isSmallScreen ? 11 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Edit button
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _openEditor(existing: n),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: isSmallScreen ? 15 : 17,
                          color: colors.textSecondary,
                        ),
                      ),
                      // Delete button
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => widget.onDelete(n.id),
                        icon: Icon(
                          Icons.delete_outline,
                          size: isSmallScreen ? 15 : 17,
                          color: colors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    n.content,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: isSmallScreen ? 12 : 13,
                      height: 1.4,
                    ),
                  ),
                  // Show update time
                  if (n.updatedAt != n.createdAt)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Updated: ${_formatDate(n.updatedAt)}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: isSmallScreen ? 10 : 11,
                        ),
                      ),
                    ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}