import 'package:flutter/material.dart';
import 'dart:async';
import '../../constants/colors.dart';

class SearchBar extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final Function(String) onSearch;

  const SearchBar({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  bool _isFocused = false;
  List<String> _recentSearches = [];
  bool _isLoadingRecent = false;

  // Default recent searches
  final List<String> _defaultSearches = [
    'Flutter Development',
    'Machine Learning',
    'UI/UX Design',
    'Python Programming',
    'React Native',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );

    _focusNode.addListener(_onFocusChange);
    _loadRecentSearches();
  }

  @override
  void didUpdateWidget(SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _scaleController.forward();
      _loadRecentSearches();
    } else {
      _scaleController.reverse();
      // Delay hiding recent searches to allow clicks
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    setState(() => _isLoadingRecent = true);
    try {
      // Load from shared preferences or local storage
      // For demo, using default searches
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _recentSearches = _defaultSearches;
      });
    } catch (e) {
      print('Failed to load recent searches: $e');
    } finally {
      setState(() => _isLoadingRecent = false);
    }
  }

  void _saveRecentSearch(String query) {
    final updated = [query, ..._recentSearches.where((s) => s != query)]
        .take(5)
        .toList();
    setState(() {
      _recentSearches = updated;
    });
    // Save to local storage
    // In production, save to shared_preferences
  }

  void _handleSubmit() {
    final query = widget.value.trim();
    if (query.isNotEmpty) {
      _saveRecentSearch(query);
      _focusNode.unfocus();
      widget.onSearch(query);
    }
  }

  void _handleRecentSearchPress(String search) {
    _controller.text = search;
    widget.onChanged(search);
    _focusNode.unfocus();
    widget.onSearch(search);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
    _focusNode.requestFocus();
  }

  void _handleVoiceSearch() {
    // Implement voice search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search coming soon! 🎤'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleClearAll() {
    setState(() {
      _recentSearches = [];
    });
    _focusNode.requestFocus();
  }

  void _handleRemoveSingleSearch(String searchToRemove) {
    setState(() {
      _recentSearches = _recentSearches.where((s) => s != searchToRemove).toList();
    });
    _focusNode.requestFocus();
  }

  void _handleCloseSearchBar() {
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar with Animation
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundElementColor(brightness),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isFocused
                        ? AppColors.getPrimaryColor(brightness).withValues(alpha: 0.5)
                        : AppColors.getBackgroundSelectedColor(brightness),
                    width: _isFocused ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Search Icon
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.getTextSecondaryColor(brightness),
                      ),
                    ),
                    // Input Field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: TextStyle(
                          color: AppColors.getTextColor(brightness),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search courses, skills, instructors...',
                          hintStyle: TextStyle(
                            color: AppColors.getTextSecondaryColor(brightness),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: widget.onChanged,
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                    ),
                    // Right Actions
                    if (widget.value.isNotEmpty)
                      IconButton(
                        onPressed: _clearSearch,
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.getTextSecondaryColor(brightness),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    // Voice Search Button
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: _handleVoiceSearch,
                        icon: Icon(
                          Icons.mic,
                          size: 18,
                          color: AppColors.getTextSecondaryColor(brightness),
                        ),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Recent Searches Dropdown
        if (_isFocused && _recentSearches.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.getBackgroundElementColor(brightness),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.getBackgroundSelectedColor(brightness),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getTextSecondaryColor(brightness),
                        ),
                      ),
                      IconButton(
                        onPressed: _handleCloseSearchBar,
                        icon: Icon(
                          Icons.keyboard_arrow_up,
                          size: 20,
                          color: AppColors.getTextSecondaryColor(brightness),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Search Items
                ..._recentSearches.map((search) => _buildRecentSearchItem(
                  search,
                  brightness,
                  isDark,
                )),
                // Clear All
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: TextButton(
                      onPressed: _handleClearAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getPrimaryColor(brightness),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentSearchItem(String search, Brightness brightness, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _handleRecentSearchPress(search),
            icon: Icon(
              Icons.access_time,
              size: 16,
              color: AppColors.getTextSecondaryColor(brightness),
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _handleRecentSearchPress(search),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  search,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextColor(brightness),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _handleRemoveSingleSearch(search),
            icon: Icon(
              Icons.close,
              size: 16,
              color: AppColors.getTextSecondaryColor(brightness),
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}