import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/instructor_dashboard_provider.dart';

class InstructorStudentsScreen extends StatefulWidget {
  const InstructorStudentsScreen({super.key});

  @override
  State<InstructorStudentsScreen> createState() => _InstructorStudentsScreenState();
}

class _InstructorStudentsScreenState extends State<InstructorStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorDashboardProvider>().loadStudents();
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
        title: Text('Students', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor, elevation: 0, automaticallyImplyLeading: false,
      ),
      body: Consumer<InstructorDashboardProvider>(
        builder: (context, provider, _) {
          final studentsList = provider.students?['data'] as List<dynamic>? ?? [];
          final total = provider.students?['total'] as num? ?? studentsList.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    hintStyle: GoogleFonts.inter(color: textSecondaryColor),
                    prefixIcon: Icon(Icons.search, color: textSecondaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true, fillColor: cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: GoogleFonts.inter(color: textColor),
                  onChanged: (v) => provider.loadStudents(search: v.isNotEmpty ? v : null),
                ),
              ),
              if (total > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Text('$total student${total == 1 ? '' : 's'}', style: GoogleFonts.inter(fontSize: 13, color: textSecondaryColor)),
                    ],
                  ),
                ),
              Expanded(
                child: studentsList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 80, color: textSecondaryColor.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text('No students yet', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 8),
                            Text('Students will appear here when they enroll', style: GoogleFonts.inter(color: textSecondaryColor)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: studentsList.length,
                        itemBuilder: (context, index) {
                          final student = studentsList[index] as Map<String, dynamic>;
                          final u = student['user'] as Map<String, dynamic>? ?? student;
                          final name = u['name'] ?? 'Student';
                          final email = u['email'] ?? '';
                          final avatar = u['avatar'];
                          final progress = (student['progress'] as num?)?.toDouble() ?? 0.0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                                child: avatar == null ? Text(name.toString()[0].toUpperCase(), style: GoogleFonts.inter(color: Colors.white)) : null,
                              ),
                              title: Text(name.toString(), style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor)),
                              subtitle: Text(email.toString(), style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: progress > 0
                                  ? SizedBox(
                                      width: 50,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('${progress.toInt()}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
                                          const SizedBox(height: 2),
                                          LinearProgressIndicator(value: progress / 100, backgroundColor: textSecondaryColor.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(primaryColor)),
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
