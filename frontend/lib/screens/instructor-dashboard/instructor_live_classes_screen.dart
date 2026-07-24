import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/live_class_provider.dart';
import '../../models/live_class_model.dart';
import '../../services/api_service.dart';
import '../../providers/theme_provider.dart';
import '../live/live_class_room_screen.dart';

class InstructorLiveClassesScreen extends StatefulWidget {
  const InstructorLiveClassesScreen({super.key});

  @override
  State<InstructorLiveClassesScreen> createState() => _InstructorLiveClassesScreenState();
}

class _InstructorLiveClassesScreenState extends State<InstructorLiveClassesScreen> {
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveClassProvider>().loadInstructorClasses();
    });
  }

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
        title: Text('Live Classes', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor, elevation: 0, automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: () => context.read<LiveClassProvider>().loadInstructorClasses(),
          ),
        ],
      ),
      body: Consumer<LiveClassProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allClasses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final classes = provider.allClasses;
          if (classes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off_outlined, size: 80, color: textSecondaryColor.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No live classes', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Text('Create a live class to connect with students', style: GoogleFonts.inter(color: textSecondaryColor)),
                ],
              ),
            );
          }

          final sorted = List<LiveClass>.from(classes)..sort((a, b) {
            const priority = {'live': 0, 'scheduled': 1, 'ended': 2, 'cancelled': 3};
            final pa = priority[a.status] ?? 4;
            final pb = priority[b.status] ?? 4;
            if (pa != pb) return pa.compareTo(pb);
            if (a.scheduledTime != b.scheduledTime) return a.scheduledTime.compareTo(b.scheduledTime);
            return 0;
          });

          return RefreshIndicator(
            onRefresh: () => provider.loadInstructorClasses(),
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final lc = sorted[index];
                final isLive = lc.status == 'live';
                final isUpcoming = lc.status == 'scheduled';
                final isEnded = lc.status == 'ended';
                Color statusColor;
                String statusLabel;
                if (isLive) { statusColor = Colors.green; statusLabel = 'LIVE'; }
                else if (isUpcoming) { statusColor = Colors.blue; statusLabel = 'Scheduled'; }
                else if (isEnded) { statusColor = Colors.grey; statusLabel = 'Ended'; }
                else { statusColor = Colors.red; statusLabel = 'Cancelled'; }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLive ? Colors.green.withValues(alpha: 0.3) : Colors.transparent),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showActions(context, lc),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                                child: Text(statusLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                              ),
                              const SizedBox(width: 8),
                              if (isLive)
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                ),
                              const Spacer(),
                              Icon(Icons.more_vert, color: textSecondaryColor, size: 20),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(lc.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                          const SizedBox(height: 4),
                          if (lc.description.isNotEmpty)
                            Text(lc.description, style: GoogleFonts.inter(fontSize: 13, color: textSecondaryColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: textSecondaryColor),
                              const SizedBox(width: 4),
                              Text(_formatDate(lc.scheduledTime), style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor)),
                              if (lc.category.isNotEmpty) ...[
                                const SizedBox(width: 16),
                                Icon(Icons.category, size: 14, color: textSecondaryColor),
                                const SizedBox(width: 4),
                                Text(lc.category, style: GoogleFonts.inter(fontSize: 12, color: textSecondaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                          if (isLive || isUpcoming) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (isLive)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _joinLiveClass(lc),
                                      icon: const Icon(Icons.videocam, size: 18),
                                      label: const Text('Join'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    ),
                                  ),
                                if (isUpcoming) ...[
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _startLiveClass(lc),
                                      icon: const Icon(Icons.play_arrow, size: 18),
                                      label: const Text('Start'),
                                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _cancelLiveClass(lc),
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: const Text('Cancel'),
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showActions(BuildContext context, LiveClass lc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lc.status == 'scheduled') ...[
                ListTile(leading: const Icon(Icons.play_arrow, color: Colors.green), title: const Text('Start'), onTap: () { Navigator.pop(ctx); _startLiveClass(lc); }),
                ListTile(leading: const Icon(Icons.cancel, color: Colors.red), title: const Text('Cancel'), onTap: () { Navigator.pop(ctx); _cancelLiveClass(lc); }),
              ],
              if (lc.status == 'live')
                ListTile(leading: const Icon(Icons.videocam, color: Colors.blue), title: const Text('Join'), onTap: () { Navigator.pop(ctx); _joinLiveClass(lc); }),
              if (lc.status != 'cancelled' && lc.status != 'ended')
                ListTile(leading: const Icon(Icons.stop, color: Colors.red), title: const Text('End'), onTap: () { Navigator.pop(ctx); _endLiveClass(lc); }),
              if (lc.status == 'ended' || lc.status == 'cancelled')
                ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('Delete'), onTap: () { Navigator.pop(ctx); _deleteLiveClass(lc); }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinLiveClass(LiveClass lc) async {
    final result = await _api.joinLiveClass(lc.id);
    if (result.success && result.data != null && context.mounted) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => LiveClassRoomScreen(
          liveClass: lc.toJson(),
          roomData: result.data!,
          userName: result.data!['displayName'] ?? 'Instructor',
        ),
      ));
    }
  }

  Future<void> _startLiveClass(LiveClass lc) async {
    final result = await _api.startLiveClass(lc.id);
    if (result.success && context.mounted) {
      context.read<LiveClassProvider>().loadInstructorClasses();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live class started'), backgroundColor: Colors.green));
    }
  }

  Future<void> _endLiveClass(LiveClass lc) async {
    final result = await _api.endLiveClass(lc.id);
    if (result.success && context.mounted) {
      context.read<LiveClassProvider>().loadInstructorClasses();
    }
  }

  Future<void> _cancelLiveClass(LiveClass lc) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Cancel Live Class'),
      content: Text('Cancel "${lc.title}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Yes, Cancel')),
      ],
    ));
    if (confirm == true) {
      await _api.cancelLiveClass(lc.id);
      if (context.mounted) {
        context.read<LiveClassProvider>().loadInstructorClasses();
      }
    }
  }

  Future<void> _deleteLiveClass(LiveClass lc) async {
    await _api.cancelLiveClass(lc.id);
    if (context.mounted) {
      context.read<LiveClassProvider>().loadInstructorClasses();
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
