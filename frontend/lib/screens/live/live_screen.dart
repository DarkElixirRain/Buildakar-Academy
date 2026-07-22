// lib/screens/live_class/live_class_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/live_class_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/live_class_model.dart';
import '../../widgets/live_class/live_class_card.dart';
import '../../widgets/live_class/skeleton_loader.dart';
import 'live_class_room_screen.dart';
import 'create_live_class_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({Key? key}) : super(key: key);

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load live classes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLiveClasses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load ALL live classes using the provider (categorized)
  Future<void> _loadLiveClasses() async {
    final provider = Provider.of<LiveClassProvider>(context, listen: false);
    await provider.loadAllStudentClasses();
  }

  // Navigate to Create Live Class screen
  void _navigateToCreateLiveClass() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateLiveClassScreen(),
      ),
    ).then((_) {
      // Refresh the list when returning from create screen
      _loadLiveClasses();
    });
  }

  // Join a live class -> launches the Jitsi meeting room
  Future<void> _joinClass(LiveClass liveClass) async {
    final provider = Provider.of<LiveClassProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Show "connecting" overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(140),
      builder: (context) => const _ConnectingDialog(),
    );

    try {
      final roomData = await provider.joinLiveClass(liveClass.id);

      if (mounted) Navigator.pop(context); // dismiss connecting overlay

      if (roomData != null && mounted) {
        // Get user info from auth provider
        final user = authProvider.user;
        String userName = 'Student';
        String? userEmail = user?.email;
        String? userAvatarUrl = user?.profileImage;

        // Build display name from user data
        if (user != null) {
          final firstName = user.firstName ?? '';
          final lastName = user.lastName ?? '';
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            userName = '$firstName $lastName'.trim();
          } else if (user.email != null && user.email!.isNotEmpty) {
            userName = user.email!.split('@').first;
          }
        }

        // Use roomData displayName if provided by backend (prefer this)
        if (roomData['displayName'] != null && roomData['displayName'].toString().isNotEmpty) {
          userName = roomData['displayName'].toString();
        }

        debugPrint('[JoinClass] Joining as: $userName');
        debugPrint('[JoinClass] Email: $userEmail');
        debugPrint('[JoinClass] Avatar: $userAvatarUrl');

        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: LiveClassRoomScreen(
                liveClass: liveClass.toJson(),
                roomData: roomData,
                userName: userName,
                userEmail: userEmail,
                userAvatarUrl: userAvatarUrl,
              ),
            ),
          ),
        );
      } else if (mounted) {
        // Show error message
        String errorMessage = provider.errorMessage.isNotEmpty
            ? provider.errorMessage
            : 'Failed to join the class. Please try again.';
        
        // Check for specific error types
        if (errorMessage.contains('not currently live')) {
          errorMessage = 'This class is not currently live. Please wait for the instructor to start the class.';
        } else if (errorMessage.contains('not enrolled')) {
          errorMessage = 'This class is linked to a course you are not enrolled in. Please enroll first.';
        } else if (errorMessage.contains('404') || errorMessage.contains('not found')) {
          errorMessage = 'This class is no longer available.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _joinClass(liveClass),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        String errorMessage = 'Error: ${e.toString()}';
        if (errorMessage.contains('SocketException')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (errorMessage.contains('Timeout')) {
          errorMessage = 'Connection timed out. Please try again.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Start a live class (instructor only)
  Future<void> _startClass(LiveClass liveClass) async {
    final provider = Provider.of<LiveClassProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Live Class'),
        content: Text('Start "${liveClass.title}" now? Students will be able to join immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Start Now'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await provider.startLiveClass(liveClass.id);
    if (success && mounted) {
      // Auto-join the class now that it's live
      _joinClass(liveClass);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage.isNotEmpty
              ? provider.errorMessage
              : 'Failed to start class'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Set reminder for a class
  void _remindMe(LiveClass liveClass) async {
    final provider = Provider.of<LiveClassProvider>(context, listen: false);
    final classId = liveClass.id;

    if (classId.isNotEmpty) {
      // Toggle follow status locally
      final isFollowing = provider.isFollowingClass(classId);
      await provider.toggleFollowClass(classId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFollowing 
                  ? 'Reminder removed for "${liveClass.title}"'
                  : 'Reminder set for "${liveClass.title}"',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            backgroundColor: isFollowing ? Colors.grey : Colors.blue,
          ),
        );
      }
    }
  }

  // Check if user is instructor or admin
  bool _isInstructorOrAdmin() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    return user?.role == 'INSTRUCTOR' || user?.role == 'ADMIN';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double horizontalPadding = screenWidth < 480
        ? 16
        : screenWidth < 900
            ? 24
            : 40;

    int crossAxisCount = 1;
    if (screenWidth > 600) crossAxisCount = 2;
    if (screenWidth > 1000) crossAxisCount = 3;
    if (screenWidth > 1400) crossAxisCount = 4;
    final isGridLayout = screenWidth >= 600;

    final liveClassProvider = Provider.of<LiveClassProvider>(context);

    final liveClasses = liveClassProvider.liveClasses ?? [];
    final upcomingClasses = liveClassProvider.upcomingClasses ?? [];
    final endedClasses = liveClassProvider.endedClasses ?? [];
    final allClasses = liveClassProvider.allClasses ?? [];
    final classSummary = liveClassProvider.classSummary ?? {};

    final isLoading = liveClassProvider.isLoading;
    final isFirstLoad = liveClassProvider.isFirstLoad;
    final hasError = liveClassProvider.hasError;
    final errorMessage = liveClassProvider.errorMessage;

    final totalCount = classSummary['total'] ?? allClasses.length;
    final liveCount = classSummary['live'] ?? liveClasses.length;
    final upcomingCount = classSummary['upcoming'] ?? upcomingClasses.length;
    final endedCount = classSummary['ended'] ?? endedClasses.length;

    final showSkeleton = isLoading && isFirstLoad;
    final isInstructor = _isInstructorOrAdmin();

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: isInstructor
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateLiveClass,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Create Class',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: hasError && isFirstLoad
            ? _buildErrorState(errorMessage, textSecondaryColor, primaryColor)
            : Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Live Classes',
                                    style: GoogleFonts.inter(
                                      fontSize: screenWidth < 480 ? 24 : 28,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                  if (isInstructor) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withAlpha(30),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Instructor',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              showSkeleton
                                  ? SkeletonBox(
                                      width: 140,
                                      height: 12,
                                      color: textSecondaryColor.withAlpha(30),
                                    )
                                  : Text(
                                      totalCount > 0
                                          ? '$totalCount session${totalCount > 1 ? 's' : ''} total'
                                          : 'No live sessions available',
                                      style: GoogleFonts.inter(
                                        fontSize: screenWidth < 480 ? 13 : 14,
                                        color: textSecondaryColor,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        if (liveCount > 0 && !showSkeleton)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.withAlpha(75)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const PulsingDot(color: Colors.red, size: 8),
                                const SizedBox(width: 8),
                                Text(
                                  '$liveCount live now',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Bar with refresh indicator - FIXED: Constrained height
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48, // Fixed height to prevent overflow
                            decoration: BoxDecoration(
                              color: textSecondaryColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withAlpha(75),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: textSecondaryColor,
                              dividerColor: Colors.transparent,
                              labelStyle: GoogleFonts.inter(
                                fontSize: screenWidth < 480 ? 11 : 13,
                                fontWeight: FontWeight.w700,
                              ),
                              unselectedLabelStyle: GoogleFonts.inter(
                                fontSize: screenWidth < 480 ? 11 : 13,
                                fontWeight: FontWeight.w600,
                              ),
                              tabs: [
                                Tab(text: 'Live (${showSkeleton ? '-' : liveCount})'),
                                Tab(text: 'Upcoming (${showSkeleton ? '-' : upcomingCount})'),
                                Tab(text: 'Ended (${showSkeleton ? '-' : endedCount})'),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading && !isFirstLoad)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: isLoading ? null : _loadLiveClasses,
                          tooltip: 'Refresh',
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          iconSize: 24,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Content - Expanded with proper constraints
                  Expanded(
                    child: showSkeleton
                        ? SkeletonLiveClassList(
                            isDark: isDark,
                            isGrid: isGridLayout,
                            crossAxisCount: crossAxisCount,
                            horizontalPadding: horizontalPadding,
                            itemCount: isGridLayout ? crossAxisCount * 2 : 4,
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildContent(
                                liveClasses,
                                horizontalPadding,
                                crossAxisCount,
                                emptyMessage: 'No classes are live right now',
                                isLive: true,
                                screenHeight: screenHeight,
                              ),
                              _buildContent(
                                upcomingClasses,
                                horizontalPadding,
                                crossAxisCount,
                                emptyMessage: 'No upcoming classes scheduled',
                                isLive: false,
                                screenHeight: screenHeight,
                              ),
                              _buildContent(
                                endedClasses,
                                horizontalPadding,
                                crossAxisCount,
                                emptyMessage: 'No past classes yet',
                                isLive: false,
                                screenHeight: screenHeight,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, Color textSecondaryColor, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.withAlpha(150)),
            const SizedBox(height: 16),
            Text(
              'Failed to load live classes',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage.isNotEmpty ? errorMessage : 'Please try again later',
              style: GoogleFonts.inter(fontSize: 14, color: textSecondaryColor.withAlpha(180)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadLiveClasses,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    List<LiveClass> items,
    double horizontalPadding,
    int crossAxisCount, {
    required String emptyMessage,
    required bool isLive,
    required double screenHeight,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final screenWidth = MediaQuery.of(context).size.width;

    final safeItems = items;

    if (safeItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLive ? Icons.people_outline_rounded : Icons.videocam_off_rounded,
                size: 64,
                color: textSecondaryColor.withAlpha(130),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLive
                    ? 'Check back later for live sessions'
                    : 'Stay tuned for upcoming classes',
                style: GoogleFonts.inter(fontSize: 14, color: textSecondaryColor.withAlpha(180)),
                textAlign: TextAlign.center,
              ),
              if (!isLive) const SizedBox(height: 16),
              if (!isLive)
                ElevatedButton.icon(
                  onPressed: _loadLiveClasses,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLiveClasses,
      color: primaryColor,
      child: screenWidth < 600
          ? ListView.builder(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
              itemCount: safeItems.length,
              itemBuilder: (context, index) {
                final liveClass = safeItems[index];
                final isFollowing = Provider.of<LiveClassProvider>(context, listen: false)
                    .isFollowingClass(liveClass.id);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final user = authProvider.user;
                final isInstructor = user?.role == 'INSTRUCTOR' || user?.role == 'ADMIN';
                final isOwnClass = liveClass.instructorId == user?.id;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LiveClassCard(
                    liveClass: liveClass.toJson(),
                    isFollowing: isFollowing,
                    isOwnClass: isOwnClass,
                    isInstructor: isInstructor,
                    onJoin: () => _joinClass(liveClass),
                    onStart: () => _startClass(liveClass),
                    onRemindMe: () => _remindMe(liveClass),
                  ),
                );
              },
            )
          : GridView.builder(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: screenWidth > 1000 ? 1.1 : 0.9,
              ),
              itemCount: safeItems.length,
              itemBuilder: (context, index) {
                final liveClass = safeItems[index];
                final isFollowing = Provider.of<LiveClassProvider>(context, listen: false)
                    .isFollowingClass(liveClass.id);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final user = authProvider.user;
                final isInstructor = user?.role == 'INSTRUCTOR' || user?.role == 'ADMIN';
                final isOwnClass = liveClass.instructorId == user?.id;
                
                return LiveClassCard(
                  liveClass: liveClass.toJson(),
                  isFollowing: isFollowing,
                  isOwnClass: isOwnClass,
                  isInstructor: isInstructor,
                  onJoin: () => _joinClass(liveClass),
                  onStart: () => _startClass(liveClass),
                  onRemindMe: () => _remindMe(liveClass),
                );
              },
            ),
    );
  }
}

/// Small polished "Connecting..." overlay shown while a join request
/// is in flight, replacing the bare CircularProgressIndicator dialog.
class _ConnectingDialog extends StatelessWidget {
  const _ConnectingDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E2028)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              'Connecting to class…',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we set up the meeting',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing dot widget for live indicator
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({
    Key? key,
    required this.color,
    this.size = 8,
  }) : super(key: key);

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}