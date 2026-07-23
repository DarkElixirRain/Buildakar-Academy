import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/instructor_course_provider.dart';
import '../../providers/theme_provider.dart';

class InstructorReviewsScreen extends StatefulWidget {
  const InstructorReviewsScreen({super.key});

  @override
  State<InstructorReviewsScreen> createState() => _InstructorReviewsScreenState();
}

class _InstructorReviewsScreenState extends State<InstructorReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final cardColor = AppColors.getBackgroundElementColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Reviews', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor, elevation: 0, automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: textColor.withValues(alpha: 0.05), height: 1),
        ),
      ),
      body: Consumer<InstructorCourseProvider>(
        builder: (context, provider, _) {
          final revs = provider.reviews;
          if (provider.isLoading && revs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (revs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 80, color: textSecondaryColor.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No reviews yet', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Text('Reviews from students will appear here', style: GoogleFonts.inter(color: textSecondaryColor)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: revs.length,
            itemBuilder: (context, index) {
              final r = revs[index] as Map<String, dynamic>;
              final student = r['student'] as Map<String, dynamic>? ?? r['user'] as Map<String, dynamic>? ?? {};
              final name = student['name'] ?? 'Anonymous';
              final avatar = student['avatar'];
              final rating = (r['rating'] as num?)?.toDouble() ?? 0.0;
              final comment = r['comment'] ?? '';
              final date = r['createdAt'] ?? r['date'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                          child: avatar == null ? Text(name.toString()[0].toUpperCase(), style: GoogleFonts.inter(color: Colors.white, fontSize: 16)) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name.toString(), style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor)),
                              Text(date.toString(), style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor)),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < rating.round() ? Icons.star : Icons.star_border,
                            color: Colors.amber, size: 18,
                          )),
                        ),
                      ],
                    ),
                    if (comment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(comment.toString(), style: GoogleFonts.inter(color: textColor, height: 1.4)),
                    ],
                    if (r['instructorReply'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.reply, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(r['instructorReply'].toString(), style: GoogleFonts.inter(fontSize: 13, color: textSecondaryColor)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
