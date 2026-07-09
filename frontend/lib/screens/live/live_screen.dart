// lib/screens/live_class/live_class_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/live_class_provider.dart';
import '../../models/live_class_model.dart';
import '../../widgets/live_class/live_class_card.dart';
import 'live_class_room_screen.dart';

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

  // Load live classes using the provider
  Future<void> _loadLiveClasses() async {
    final provider = Provider.of<LiveClassProvider>(context, listen: false);
    await provider.loadAllClasses();
  }

  // Join a live class
  Future<void> _joinClass(LiveClass liveClass) async {
    final provider = Provider.of<LiveClassProvider>(context, listen: false);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Join the class
      final roomData = await provider.joinLiveClass(liveClass.id);
      
      // Dismiss loading dialog
      Navigator.pop(context);
      
      if (roomData != null) {
        // Navigate to the room
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveClassRoomScreen(
              liveClass: liveClass.toJson(),
              roomData: roomData,
            ),
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage.isNotEmpty 
                  ? provider.errorMessage 
                  : 'Failed to join the class. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Dismiss loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
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
      final success = await provider.toggleFollowClass(classId);
      if (success) {
        final isFollowing = provider.isFollowingClass(classId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFollowing 
                ? "We'll notify you before \"${liveClass.title}\" starts" 
                : "Reminder removed for \"${liveClass.title}\"",
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            backgroundColor: isFollowing ? Colors.green : Colors.grey,
          ),
        );
        // Refresh the class data to update the UI
        await provider.loadAllClasses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to set reminder. Please try again."),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    // Get theme-aware colors
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    
    final screenWidth = MediaQuery.of(context).size.width;

    final double horizontalPadding = screenWidth < 480
        ? 16
        : screenWidth < 900
            ? 24
            : 40;

    // Responsive grid columns
    int crossAxisCount = 1;
    if (screenWidth > 600) crossAxisCount = 2;
    if (screenWidth > 1000) crossAxisCount = 3;
    if (screenWidth > 1400) crossAxisCount = 4;

    // Get live classes from provider
    final liveClassProvider = Provider.of<LiveClassProvider>(context);
    final liveClasses = liveClassProvider.liveClasses;
    final upcomingClasses = liveClassProvider.upcomingClasses;
    final endedClasses = liveClassProvider.endedClasses;
    final isLoading = liveClassProvider.isLoading;
    final isFirstLoad = liveClassProvider.isFirstLoad;
    final hasError = liveClassProvider.hasError;
    final errorMessage = liveClassProvider.errorMessage;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: isLoading && isFirstLoad
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading live classes...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              )
            : hasError && isFirstLoad
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Colors.red.withAlpha(150),
                          ),
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
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textSecondaryColor.withAlpha(180),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadLiveClasses,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
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
                                  Text(
                                    'Live Classes',
                                    style: GoogleFonts.inter(
                                      fontSize: screenWidth < 480 ? 24 : 28,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    liveClasses.isNotEmpty
                                        ? '${liveClasses.length} session${liveClasses.length > 1 ? 's' : ''} happening now'
                                        : 'No live sessions at the moment',
                                    style: GoogleFonts.inter(
                                      fontSize: screenWidth < 480 ? 13 : 14,
                                      color: textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (liveClasses.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(40),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.red.withAlpha(75),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        duration: const Duration(milliseconds: 1500),
                                        builder: (context, value, child) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red.withAlpha((30 * (1 - value)).toInt()),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${liveClasses.length} live now',
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
                      
                      // Tab Bar with refresh indicator
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
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
                                    fontSize: screenWidth < 480 ? 12 : 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  unselectedLabelStyle: GoogleFonts.inter(
                                    fontSize: screenWidth < 480 ? 12 : 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  tabs: [
                                    Tab(text: 'Live (${liveClasses.length})'),
                                    Tab(text: 'Upcoming (${upcomingClasses.length})'),
                                    Tab(text: 'Ended (${endedClasses.length})'),
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
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildContent(
                              liveClasses,
                              horizontalPadding,
                              crossAxisCount,
                              emptyMessage: 'No classes are live right now',
                              isLive: true,
                            ),
                            _buildContent(
                              upcomingClasses,
                              horizontalPadding,
                              crossAxisCount,
                              emptyMessage: 'No upcoming classes scheduled',
                              isLive: false,
                            ),
                            _buildContent(
                              endedClasses,
                              horizontalPadding,
                              crossAxisCount,
                              emptyMessage: 'No past classes yet',
                              isLive: false,
                            ),
                          ],
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
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final screenWidth = MediaQuery.of(context).size.width;

    if (items.isEmpty) {
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
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textSecondaryColor.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
              if (!isLive)
                const SizedBox(height: 16),
              if (!isLive)
                ElevatedButton.icon(
                  onPressed: _loadLiveClasses,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // For small screens, use ListView
    if (screenWidth < 600) {
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final liveClass = items[index];
          final isFollowing = Provider.of<LiveClassProvider>(context, listen: false)
              .isFollowingClass(liveClass.id);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LiveClassCard(
              liveClass: liveClass.toJson(),
              isFollowing: isFollowing,
              onJoin: () => _joinClass(liveClass),
              onRemindMe: () => _remindMe(liveClass),
            ),
          );
        },
      );
    }

    // For tablets and desktop, use GridView
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: screenWidth > 1000 ? 1.1 : 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final liveClass = items[index];
        final isFollowing = Provider.of<LiveClassProvider>(context, listen: false)
            .isFollowingClass(liveClass.id);
        
        return LiveClassCard(
          liveClass: liveClass.toJson(),
          isFollowing: isFollowing,
          onJoin: () => _joinClass(liveClass),
          onRemindMe: () => _remindMe(liveClass),
        );
      },
    );
  }
}