// lib/widgets/home/home_header.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../screens/notifications/notification_screen.dart';
import '../search/search_suggestions_dropdown.dart';

class HomeHeader extends StatefulWidget {
  final VoidCallback onNotificationPress;
  final VoidCallback? onProfilePress;
  final Function(String)? onSearchSubmitted;
  final Function(String)? onSearchChanged;

  const HomeHeader({
    Key? key,
    required this.onNotificationPress,
    this.onProfilePress,
    this.onSearchSubmitted,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with SingleTickerProviderStateMixin {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _voiceText = '';
  bool _speechAvailable = false;
  final bool _isSearching = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  // Notification count state
  int _notificationCount = 0;
  bool _isLoadingCount = true;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _searchController.addListener(_onSearchTextChanged);
    _searchFocusNode.addListener(_onFocusChange);
    _fetchNotificationCount();
    
    // Set up overlay on focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isSearchVisible) {
        _showSuggestionsOverlay();
      }
    });
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final response = await _apiService.getUnreadCount();
      if (mounted && response.success) {
        setState(() {
          _notificationCount = response.data?['count'] ?? 0;
          _isLoadingCount = false;
        });
      } else {
        setState(() {
          _isLoadingCount = false;
        });
      }
    } catch (e) {
      print('Error fetching notification count: $e');
      if (mounted) {
        setState(() {
          _isLoadingCount = false;
        });
      }
    }
  }

  // Refresh notification count when coming back to the screen
  void _refreshNotificationCount() {
    _fetchNotificationCount();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
          if (_voiceText.isNotEmpty) {
            _searchController.text = _voiceText;
            _submitSearch();
          }
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice recognition error: ${error.errorMsg}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
    setState(() {
      _speechAvailable = available;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchFocusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _speech.stop();
    _hideSuggestionsOverlay();
    super.dispose();
  }

  void _onSearchTextChanged() async {
    final query = _searchController.text;
    
    // Fetch suggestions from the search provider
    if (query.isNotEmpty && query.length >= 2) {
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      await searchProvider.getSuggestions(query);
    }
    
    // Notify parent
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(query);
    }
    
    // Show/hide suggestions overlay
    if (query.isNotEmpty && _isSearchVisible) {
      _showSuggestionsOverlay();
    } else {
      _hideSuggestionsOverlay();
    }
    
    setState(() {});
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
      _showSuggestionsOverlay();
    } else {
      _hideSuggestionsOverlay();
    }
  }

  void _showSuggestionsOverlay() {
    _hideSuggestionsOverlay();
    
    if (!_isSearchVisible) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    
    // Get the search provider to ensure suggestions are loaded
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    final hasSuggestions = searchProvider.suggestions.isNotEmpty;
    final hasRecent = searchProvider.recentSearches.isNotEmpty;
    
    // Only show overlay if there are suggestions or recent searches
    if (!hasSuggestions && !hasRecent && _searchController.text.isNotEmpty) {
      // If no suggestions yet, fetch them
      if (_searchController.text.length >= 2) {
        searchProvider.getSuggestions(_searchController.text);
      }
    }
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(16, size.height + 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: SearchSuggestionsDropdown(
              searchQuery: _searchController.text,
              onSuggestionSelected: (suggestion) {
                _searchController.text = suggestion;
                _submitSearch();
              },
              onRecentSearchSelected: (query) {
                _searchController.text = query;
                _submitSearch();
              },
              onClearRecentSearches: () {
                final searchProvider = Provider.of<SearchProvider>(context, listen: false);
                searchProvider.clearRecentSearches();
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestionsOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
          // Fetch initial suggestions if there's text
          if (_searchController.text.isNotEmpty && _searchController.text.length >= 2) {
            final searchProvider = Provider.of<SearchProvider>(context, listen: false);
            searchProvider.getSuggestions(_searchController.text);
          }
          _showSuggestionsOverlay();
        });
      } else {
        _searchController.clear();
        _searchFocusNode.unfocus();
        _hideSuggestionsOverlay();
        // Clear suggestions
        final searchProvider = Provider.of<SearchProvider>(context, listen: false);
        searchProvider.clearResults();
        if (widget.onSearchChanged != null) {
          widget.onSearchChanged!('');
        }
      }
    });
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _searchFocusNode.unfocus();
      _hideSuggestionsOverlay();
      
      // Save recent search
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      searchProvider.saveRecentSearch(query);
      
      if (widget.onSearchSubmitted != null) {
        widget.onSearchSubmitted!(query);
      }
    }
  }

  void _startVoiceSearch() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available on this device'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() {
      _isListening = true;
      _voiceText = '';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _voiceText = result.recognizedWords;
            _searchController.text = _voiceText;
          });
          if (widget.onSearchChanged != null) {
            widget.onSearchChanged!(_voiceText);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: 'en_US',
        onSoundLevelChange: (level) {
          // Update UI with sound level if needed
        },
      );
    } catch (e) {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start voice recognition: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNotificationPress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    ).then((_) {
      // Refresh notification count when coming back from notification screen
      _refreshNotificationCount();
    });
    widget.onNotificationPress();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    final String displayName = user?.name ?? 'Student';
    final String initials = _getInitials(user?.name ?? 'Student');
    final String? profileImage = user?.profileImage;
    final String greeting = _getGreeting();

    // Get theme-aware colors
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: backgroundElementColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Main Header Row
            Row(
              children: [
                // Left: Avatar and Greeting
                Expanded(
                  child: Row(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: widget.onProfilePress ?? () {},
                        child: Container(
                          width: isTablet ? 56 : 48,
                          height: isTablet ? 56 : 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: profileImage == null
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF2563EB),
                                      Color(0xFF7C3AED),
                                    ],
                                  )
                                : null,
                            image: profileImage != null
                                ? DecorationImage(
                                    image: NetworkImage(profileImage),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      print('Error loading profile image: $exception');
                                    },
                                  )
                                : null,
                          ),
                          child: profileImage == null
                              ? Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 20 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Greeting and Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$greeting 👋',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w500,
                                color: textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Actions
                Row(
                  children: [
                    // Search Button
                    Container(
                      width: isTablet ? 44 : 40,
                      height: isTablet ? 44 : 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSearchVisible
                            ? primaryColor
                            : backgroundElementColor,
                      ),
                      child: IconButton(
                        onPressed: _toggleSearch,
                        icon: Icon(
                          _isSearchVisible ? Icons.close : Icons.search,
                          size: isTablet ? 22 : 20,
                          color: _isSearchVisible
                              ? Colors.white
                              : textSecondaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Notification Button with Real Count
                    Stack(
                      children: [
                        Container(
                          width: isTablet ? 44 : 40,
                          height: isTablet ? 44 : 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: backgroundElementColor,
                          ),
                          child: IconButton(
                            onPressed: _handleNotificationPress,
                            icon: Icon(
                              Icons.notifications_outlined,
                              size: isTablet ? 24 : 22,
                              color: textSecondaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        // Show notification count badge
                        if (!_isLoadingCount && _notificationCount > 0)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: isTablet ? 22 : 20,
                              height: isTablet ? 22 : 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                                border: Border.all(
                                  color: backgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _notificationCount > 9 
                                      ? '9+' 
                                      : '$_notificationCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 11 : 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Show loading indicator
                        if (_isLoadingCount)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: SizedBox(
                              width: isTablet ? 12 : 10,
                              height: isTablet ? 12 : 10,
                              child: const CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            // Search Bar (Visible when _isSearchVisible is true)
            if (_isSearchVisible)
              Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: backgroundElementColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isListening
                        ? Colors.red
                        : primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    // Search Icon
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                    
                    // TextField
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: TextStyle(
                          color: textColor,
                          fontSize: isTablet ? 16 : 14,
                        ),
                        decoration: InputDecoration(
                          hintText: _isListening 
                              ? 'Listening...' 
                              : 'Search courses, skills, instructors...',
                          hintStyle: TextStyle(
                            color: _isListening 
                                ? Colors.red 
                                : textSecondaryColor,
                            fontSize: isTablet ? 14 : 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _submitSearch(),
                      ),
                    ),
                    
                    // Voice Search Button
                    if (_speechAvailable)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: IconButton(
                            onPressed: _startVoiceSearch,
                            icon: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: _isListening 
                                      ? Colors.red 
                                      : textSecondaryColor,
                                  size: 22,
                                ),
                                if (_isListening)
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                    ),
                                  ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    
                    // Clear button
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          // Clear suggestions when clearing text
                          final searchProvider = Provider.of<SearchProvider>(context, listen: false);
                          searchProvider.clearResults();
                          if (widget.onSearchChanged != null) {
                            widget.onSearchChanged!('');
                          }
                          _hideSuggestionsOverlay();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: textSecondaryColor,
                        ),
                        padding: const EdgeInsets.only(right: 4),
                        constraints: const BoxConstraints(),
                      ),
                    
                    // Search button
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: ElevatedButton(
                        onPressed: _isListening ? null : _submitSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          disabledBackgroundColor: isDark ? Colors.grey[700] : Colors.grey[400],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSearching)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'S';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}