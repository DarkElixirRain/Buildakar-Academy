import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../theme/app_colors.dart';

class StudyMaterialList extends StatefulWidget {
  final List<StudyMaterial> materials;
  final bool isEnrolled;
  final AppColors colors;

  const StudyMaterialList({
    super.key,
    required this.materials,
    required this.isEnrolled,
    required this.colors,
  });

  @override
  State<StudyMaterialList> createState() => _StudyMaterialListState();
}

class _StudyMaterialListState extends State<StudyMaterialList> {
  final Map<String, double> _downloadProgress = {}; // 0..1, 1 = done

  IconData _iconFor(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.pdf:
        return Icons.picture_as_pdf_outlined;
      case StudyMaterialType.doc:
        return Icons.description_outlined;
      case StudyMaterialType.zip:
        return Icons.folder_zip_outlined;
      case StudyMaterialType.link:
        return Icons.link;
      case StudyMaterialType.slides:
        return Icons.slideshow_outlined;
    }
  }

  Future<void> _simulateDownload(StudyMaterial material) async {
    if (!widget.isEnrolled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enroll in this course to download materials')),
      );
      return;
    }
    setState(() => _downloadProgress[material.id] = 0);
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _downloadProgress[material.id] = i / 10);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${material.title} downloaded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    if (widget.materials.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text('No study materials yet.', style: TextStyle(color: colors.textSecondary)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resources & downloads',
            style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Slides, source code, and reference docs to go along with the lessons.',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ...widget.materials.map((m) {
            final progress = _downloadProgress[m.id];
            final downloading = progress != null && progress < 1;
            final done = progress == 1;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.backgroundElement,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: colors.badgeBg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(_iconFor(m.type), color: colors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          m.relatedSectionTitle != null ? '${m.sizeLabel} • ${m.relatedSectionTitle}' : m.sizeLabel,
                          style: TextStyle(color: colors.textSecondary, fontSize: 11),
                        ),
                        if (downloading) ...[
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: colors.backgroundSelected,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: downloading ? null : () => _simulateDownload(m),
                    icon: Icon(
                      done
                          ? Icons.check_circle
                          : m.type == StudyMaterialType.link
                              ? Icons.open_in_new
                              : Icons.download_outlined,
                      color: done ? colors.success : colors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}