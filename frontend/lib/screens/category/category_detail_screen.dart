// lib/screens/category_detail_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';

enum _SortOption { newest, popular, ratingHigh, priceLow, priceHigh }
enum _ViewMode { grid, list }

class CategoryDetailScreen extends StatefulWidget {
  final String categoryId;
  final String categorySlug;
  final String categoryName;
  final Color? categoryColor;
  final IconData? categoryIcon;
  final String? categoryImage;
  final String? categoryDescription;
  final int? initialCourseCount;

  const CategoryDetailScreen({
    Key? key,
    required this.categoryId,
    required this.categorySlug,
    required this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.categoryImage,
    this.categoryDescription,
    this.initialCourseCount,
  }) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  static const int _limit = 12;

  List<Map<String, dynamic>> _allCourses = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  String _searchQuery = '';
  String _selectedLevel = 'All';
  _SortOption _sortOption = _SortOption.newest;
  _ViewMode _viewMode = _ViewMode.grid;
  bool _searchFocused = false;
  double _headerCollapseProgress = 0.0;

  late String _categoryName;
  String? _categoryImage;
  String? _categoryDescription;
  int? _courseCountFromApi;

  final List<String> _levels = const ['All', 'Beginner', 'Intermediate', 'Advanced'];

  late final Color _accentColor;
  late final IconData _accentIcon;

  static const double _expandedHeaderHeight = 260.0;
  static const double _collapsedHeaderHeight = 90.0;

  @override
  void initState() {
    super.initState();
    _categoryName = widget.categoryName;
    _categoryImage = widget.categoryImage;
    _categoryDescription = widget.categoryDescription;
    _courseCountFromApi = widget.initialCourseCount;
    _accentColor = widget.categoryColor ?? const Color(0xFF6366F1);
    _accentIcon = widget.categoryIcon ?? Icons.category;
    
    _fetchCategoryAndCourses();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final maxExtent = _scrollController.position.maxScrollExtent;
    final pixels = _scrollController.position.pixels;

    final collapseRange = _expandedHeaderHeight - _collapsedHeaderHeight;
    final progress = (pixels / collapseRange).clamp(0.0, 1.0);
    if ((progress - _headerCollapseProgress).abs() > 0.01) {
      setState(() => _headerCollapseProgress = progress);
    }

    if (pixels >= maxExtent - 400 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _loadMoreCourses();
    }
  }

  String _sortKey(_SortOption o) {
    switch (o) {
      case _SortOption.newest:
        return 'newest';
      case _SortOption.popular:
        return 'popular';
      case _SortOption.ratingHigh:
        return 'rating';
      case _SortOption.priceLow:
        return 'price_asc';
      case _SortOption.priceHigh:
        return 'price_desc';
    }
  }

  String _sortLabel(_SortOption o) {
    switch (o) {
      case _SortOption.newest:
        return 'Newest';
      case _SortOption.popular:
        return 'Most Popular';
      case _SortOption.ratingHigh:
        return 'Highest Rated';
      case _SortOption.priceLow:
        return 'Price: Low to High';
      case _SortOption.priceHigh:
        return 'Price: High to Low';
    }
  }

  Future<void> _fetchCategoryAndCourses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getCategoryBySlug(
        widget.categorySlug,
        includeCourses: true,
        limit: _limit,
        offset: 0,
        sortBy: _sortKey(_sortOption),
      );

      if (!mounted) return;

      if (response.success) {
        final Map<String, dynamic> payload = response.data ?? {};
        
        // Update category info
        if (payload['name'] != null && payload['name'].toString().isNotEmpty) {
          _categoryName = payload['name'];
        }
        if (payload['image'] != null && payload['image'].toString().isNotEmpty) {
          _categoryImage = payload['image'];
        }
        if (payload['description'] != null && payload['description'].toString().isNotEmpty) {
          _categoryDescription = payload['description'];
        }
        if (payload['_count'] != null && payload['_count']['courses'] != null) {
          _courseCountFromApi = payload['_count']['courses'];
        }
        
        final List<dynamic> rawCourses = (payload['courses'] as List?) ??
            (payload['Course'] as List?) ??
            (payload['data'] as List?) ??
            [];

        final transformed = rawCourses
            .map((c) => _transformCourseData(c as Map<String, dynamic>))
            .toList();

        setState(() {
          _allCourses = transformed;
          _hasMore = transformed.length >= _limit;
          _isLoading = false;
        });
      } else {
        // If slug fails, try by ID
        await _fetchCategoryById();
      }
    } catch (e) {
      await _fetchCategoryById();
    }
  }

  Future<void> _fetchCategoryById() async {
    try {
      final response = await _apiService.getCategoryById(widget.categoryId);
      
      if (!mounted) return;

      if (response.success) {
        final Map<String, dynamic> payload = response.data ?? {};
        
        // Update category info
        if (payload['name'] != null && payload['name'].toString().isNotEmpty) {
          _categoryName = payload['name'];
        }
        if (payload['image'] != null && payload['image'].toString().isNotEmpty) {
          _categoryImage = payload['image'];
        }
        if (payload['description'] != null && payload['description'].toString().isNotEmpty) {
          _categoryDescription = payload['description'];
        }
        if (payload['_count'] != null && payload['_count']['courses'] != null) {
          _courseCountFromApi = payload['_count']['courses'];
        }
        
        final List<dynamic> rawCourses = (payload['courses'] as List?) ??
            (payload['Course'] as List?) ??
            (payload['data'] as List?) ??
            [];

        if (rawCourses.isNotEmpty) {
          final transformed = rawCourses
              .map((c) => _transformCourseData(c as Map<String, dynamic>))
              .toList();
          setState(() {
            _allCourses = transformed;
            _hasMore = transformed.length >= _limit;
          });
        } else {
          // If no courses in category response, fetch public courses
          await _fetchPublicCourses();
        }
        
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load category';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPublicCourses() async {
    try {
      final response = await _apiService.getPublicCourses(
        page: 1,
        limit: _limit,
        categoryId: widget.categoryId,
        sortBy: _sortKey(_sortOption),
      );

      if (!mounted) return;

      if (response.success) {
        final Map<String, dynamic> data = response.data ?? {};
        final List<dynamic> coursesData = data['data'] ?? [];
        
        final transformed = coursesData
            .map((c) => _transformCourseData(c as Map<String, dynamic>))
            .toList();
            
        setState(() {
          _allCourses = transformed;
          _hasMore = transformed.length >= _limit;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'No courses found';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load courses';
      });
    }
  }

  Future<void> _loadMoreCourses() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() => _isLoadingMore = true);

    try {
      final offset = _allCourses.length;
      final response = await _apiService.getCategoryBySlug(
        widget.categorySlug,
        includeCourses: true,
        limit: _limit,
        offset: offset,
        sortBy: _sortKey(_sortOption),
      );

      if (!mounted) return;

      if (response.success) {
        final Map<String, dynamic> payload = response.data ?? {};
        
        final List<dynamic> rawCourses = (payload['courses'] as List?) ??
            (payload['Course'] as List?) ??
            (payload['data'] as List?) ??
            [];

        if (rawCourses.isNotEmpty) {
          final transformed = rawCourses
              .map((c) => _transformCourseData(c as Map<String, dynamic>))
              .toList();
          setState(() {
            _allCourses.addAll(transformed);
            _hasMore = transformed.length >= _limit;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _hasMore = false;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _hasMore = false;
      });
    }
  }

  Map<String, dynamic> _transformCourseData(Map<String, dynamic> c) {
    final price = _toDouble(c['price']);
    final originalPrice = _toDouble(c['originalPrice'] ?? c['price']);
    
    String instructorName = 'Unknown Instructor';
    if (c['instructor'] != null) {
      if (c['instructor'] is Map) {
        final instructor = c['instructor'];
        final firstName = instructor['firstName'] ?? '';
        final lastName = instructor['lastName'] ?? '';
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          instructorName = '$firstName $lastName'.trim();
        } else if (instructor['name'] != null) {
          instructorName = instructor['name'];
        }
      } else if (c['instructor'] is String) {
        instructorName = c['instructor'];
      }
    }
    
    String thumbnail = '';
    for (final key in ['thumbnail', 'thumbnailUrl', 'image', 'coverImage']) {
      final v = c[key];
      if (v != null && v.toString().isNotEmpty) {
        thumbnail = v.toString();
        break;
      }
    }
    
    return {
      'id': c['id']?.toString() ?? '',
      'title': c['title'] ?? 'Untitled Course',
      'instructor': instructorName,
      'thumbnail': thumbnail,
      'rating': _toDouble(c['rating'] ?? c['avgRating']),
      'reviewCount': _toInt(c['reviewCount'] ?? c['_count']?['reviews']),
      'studentCount': _toInt(c['studentCount'] ?? c['_count']?['enrollments']),
      'price': price,
      'originalPrice': originalPrice,
      'level': c['level'] ?? 'Beginner',
      'lessonCount': _toInt(c['lessonCount'] ?? c['_count']?['lessons']),
      'isBestseller': c['isBestseller'] ?? false,
      'isFree': price == 0,
    };
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    if (v is num) return v.toDouble();
    return 0.0;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is num) return v.toInt();
    return 0;
  }

  List<Map<String, dynamic>> get _filteredCourses {
    return _allCourses.where((course) {
      final matchesSearch = _searchQuery.isEmpty ||
          (course['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (course['instructor'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLevel =
          _selectedLevel == 'All' || course['level'] == _selectedLevel;
      return matchesSearch && matchesLevel;
    }).toList();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value.trim());
    });
  }

  void _onSortChanged(_SortOption opt) {
    setState(() => _sortOption = opt);
    _fetchCategoryAndCourses();
  }

  void _openSortSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _SortSheet(
          isDark: isDark,
          accentColor: _accentColor,
          current: _sortOption,
          labelBuilder: _sortLabel,
          onSelected: (opt) {
            Navigator.pop(context);
            _onSortChanged(opt);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    final bool isSmallPhone = screenWidth < 380;
    final bool isPhone = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    final double horizontalPadding = _getResponsivePadding(screenWidth);
    final double contentMaxWidth = isDesktop ? 1200.0 : double.infinity;

    final gridConfig = _getGridConfig(screenWidth, isTablet, isPhone, isSmallPhone);
    
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = AppColors.getBackgroundElementColor(brightness);
    final cardBorderColor = AppColors.getBackgroundSelectedColor(brightness);

    final filtered = _filteredCourses;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        color: _accentColor,
        onRefresh: _fetchCategoryAndCourses,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            _buildSliverHeader(context, isDark, isSmallPhone, screenWidth),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(isDark, isSmallPhone, surfaceColor, cardBorderColor),
                        const SizedBox(height: 12),
                        _buildFilterRow(isDark, isSmallPhone, screenWidth),
                        const SizedBox(height: 14),
                        _buildResultsHeader(isDark, isSmallPhone, filtered.length, screenWidth),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBody(
              filtered: filtered,
              isDark: isDark,
              contentMaxWidth: contentMaxWidth,
              horizontalPadding: horizontalPadding,
              gridConfig: gridConfig,
              isSmallPhone: isSmallPhone,
              surfaceColor: surfaceColor,
              cardBorderColor: cardBorderColor,
            ),
          ],
        ),
      ),
    );
  }

  double _getResponsivePadding(double screenWidth) {
    if (screenWidth < 380) return 12.0;
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 900) return 24.0;
    if (screenWidth < 1200) return 32.0;
    return 48.0;
  }

  _GridConfig _getGridConfig(double screenWidth, bool isTablet, bool isPhone, bool isSmallPhone) {
    int columns;
    double spacing;
    double childAspectRatio;
    double verticalSpacing;

    if (screenWidth >= 1400) {
      columns = 4;
      spacing = 20.0;
      childAspectRatio = 0.85;
      verticalSpacing = 24.0;
    } else if (screenWidth >= 1024) {
      columns = 3;
      spacing = 18.0;
      childAspectRatio = 0.82;
      verticalSpacing = 22.0;
    } else if (isTablet) {
      columns = 2;
      spacing = 16.0;
      childAspectRatio = 0.78;
      verticalSpacing = 20.0;
    } else if (isPhone) {
      if (_viewMode == _ViewMode.list) {
        columns = 1;
        childAspectRatio = 2.6;
      } else {
        columns = 2;
        childAspectRatio = isSmallPhone ? 0.72 : 0.74;
      }
      spacing = 12.0;
      verticalSpacing = 16.0;
    } else {
      columns = 2;
      spacing = 14.0;
      childAspectRatio = 0.78;
      verticalSpacing = 18.0;
    }

    if (_viewMode == _ViewMode.list) {
      columns = 1;
      childAspectRatio = isPhone ? 2.4 : 3.0;
    }

    return _GridConfig(
      columns: columns,
      spacing: spacing,
      verticalSpacing: verticalSpacing,
      childAspectRatio: childAspectRatio,
    );
  }

  // =====================================================================
  // SLIVER HEADER
  // =====================================================================
  Widget _buildSliverHeader(BuildContext context, bool isDark, bool isSmallPhone, double screenWidth) {
    final imageUrl = _categoryImage ?? '';
    final description = _categoryDescription ?? '';
    final isSmallScreen = screenWidth < 400;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: _expandedHeaderHeight,
      collapsedHeight: _collapsedHeaderHeight,
      backgroundColor: _accentColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _RoundIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).maybePop(),
          isDark: isDark,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: _RoundIconButton(
            icon: Icons.share_outlined,
            onTap: () {},
            isDark: isDark,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        titlePadding: EdgeInsets.only(left: isSmallPhone ? 56 : 64, right: 16, bottom: 16),
        title: Opacity(
          opacity: _headerCollapseProgress > 0.5 ? 1.0 : 0.0,
          child: Text(
            _categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(color: _accentColor),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accentColor, _accentColor.withValues(alpha: 0.7)],
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 10,
              child: Icon(_accentIcon, size: 140, color: Colors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              left: isSmallScreen ? 12 : 20,
              right: isSmallScreen ? 12 : 20,
              bottom: 60,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                      ),
                      child: Icon(_accentIcon, color: Colors.white, size: isSmallScreen ? 20 : 24),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        _categoryName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallPhone ? 20 : isSmallScreen ? 22 : 26,
                          height: 1.2,
                          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10)],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: isSmallPhone ? 11.5 : 13,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Flexible(
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: Colors.white.withValues(alpha: 0.85), size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _courseCountFromApi != null
                                  ? '$_courseCountFromApi courses'
                                  : '${_allCourses.length}${_hasMore ? '+' : ''} courses',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // SEARCH BAR
  // =====================================================================
  Widget _buildSearchBar(bool isDark, bool isSmallPhone, Color surfaceColor, Color borderColor) {
    final b = isDark ? Brightness.dark : Brightness.light;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isSmallPhone ? 44 : 50,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _searchFocused ? _accentColor : borderColor, width: _searchFocused ? 1.5 : 1),
        boxShadow: [
          BoxShadow(color: AppColors.getTextColor(b).withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: AppColors.getTextSecondaryColor(b), size: isSmallPhone ? 18 : 22),
          const SizedBox(width: 8),
          Expanded(
            child: Focus(
              onFocusChange: (has) => setState(() => _searchFocused = has),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: AppColors.getTextColor(b), fontSize: isSmallPhone ? 13 : 15),
                decoration: InputDecoration(
                  hintText: 'Search in $_categoryName',
                  hintStyle: TextStyle(color: AppColors.getTextSecondaryColor(b), fontSize: isSmallPhone ? 12.5 : 14.5),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: isSmallPhone 
                      ? const EdgeInsets.symmetric(vertical: 8)
                      : const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.getTextSecondaryColor(b),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              padding: const EdgeInsets.all(4),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }

  // =====================================================================
  // FILTER ROW
  // =====================================================================
  Widget _buildFilterRow(bool isDark, bool isSmallPhone, double screenWidth) {
    final b = isDark ? Brightness.dark : Brightness.light;
    final textSecondary = AppColors.getTextSecondaryColor(b);
    final bool isSmallScreen = screenWidth < 500;

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _levels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final level = _levels[index];
                final selected = level == _selectedLevel;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLevel = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? _accentColor : (AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: selected ? _accentColor : (AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light))),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.getTextColor(b),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _RoundIconButton(
                icon: _viewMode == _ViewMode.grid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                filled: true,
                isDark: isDark,
                size: 32,
                onTap: () => setState(() => _viewMode = _viewMode == _ViewMode.grid ? _ViewMode.list : _ViewMode.grid),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _openSortSheet(isDark),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_vert_rounded, size: 16, color: textSecondary),
                      const SizedBox(width: 3),
                      Icon(Icons.expand_more_rounded, size: 14, color: textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _levels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final level = _levels[index];
                final selected = level == _selectedLevel;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLevel = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? _accentColor : (AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? _accentColor : (AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light))),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        fontSize: isSmallPhone ? 11 : 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.getTextColor(b),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          icon: _viewMode == _ViewMode.grid ? Icons.view_list_rounded : Icons.grid_view_rounded,
          filled: true,
          isDark: isDark,
          size: 36,
          onTap: () => setState(() => _viewMode = _viewMode == _ViewMode.grid ? _ViewMode.list : _ViewMode.grid),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _openSortSheet(isDark),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_vert_rounded, size: 18, color: textSecondary),
                const SizedBox(width: 4),
                Icon(Icons.expand_more_rounded, size: 16, color: textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsHeader(bool isDark, bool isSmallPhone, int filteredCount, double screenWidth) {
    final b = isDark ? Brightness.dark : Brightness.light;
    final bool isSmallScreen = screenWidth < 400;
    
    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLoading ? 'Loading courses…' : '$filteredCount ${filteredCount == 1 ? 'course' : 'courses'} found',
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w600, 
              color: AppColors.getTextColor(b),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _sortLabel(_sortOption),
            style: TextStyle(
              fontSize: 11.5, 
              color: AppColors.getTextSecondaryColor(b), 
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            _isLoading ? 'Loading courses…' : '$filteredCount ${filteredCount == 1 ? 'course' : 'courses'} found',
            style: TextStyle(
              fontSize: isSmallPhone ? 13 : 14.5, 
              fontWeight: FontWeight.w600, 
              color: AppColors.getTextColor(b),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            _sortLabel(_sortOption),
            style: TextStyle(
              fontSize: isSmallPhone ? 11.5 : 12.5, 
              color: AppColors.getTextSecondaryColor(b), 
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // BODY
  // =====================================================================
  Widget _buildBody({
    required List<Map<String, dynamic>> filtered,
    required bool isDark,
    required double contentMaxWidth,
    required double horizontalPadding,
    required _GridConfig gridConfig,
    required bool isSmallPhone,
    required Color surfaceColor,
    required Color cardBorderColor,
  }) {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: _buildShimmerGrid(
                isDark: isDark,
                gridConfig: gridConfig,
                surfaceColor: surfaceColor,
              ),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(hasScrollBody: false, child: _buildErrorState(isDark));
    }

    if (filtered.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState(isDark));
    }

    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridConfig.columns,
                    crossAxisSpacing: gridConfig.spacing,
                    mainAxisSpacing: gridConfig.verticalSpacing,
                    childAspectRatio: gridConfig.childAspectRatio,
                  ),
                  itemBuilder: (context, index) => _buildCourseCard(
                    filtered[index],
                    isDark: isDark,
                    isListStyle: gridConfig.columns == 1,
                    isSmallPhone: isSmallPhone,
                    surfaceColor: surfaceColor,
                    cardBorderColor: cardBorderColor,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SizedBox(
                      width: 26, 
                      height: 26, 
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5, 
                        color: _accentColor,
                      ),
                    ),
                  )
                else if (!_hasMore && _allCourses.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      "You've reached the end 🎉",
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(
                          isDark ? Brightness.dark : Brightness.light
                        ), 
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    final b = isDark ? Brightness.dark : Brightness.light;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.getErrorColor(b).withValues(alpha: 0.1), 
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded, 
                size: 42, 
                color: AppColors.getErrorColor(b),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Something went wrong', 
              style: TextStyle(
                fontSize: 17, 
                fontWeight: FontWeight.bold, 
                color: AppColors.getTextColor(b),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error ?? 'Failed to load courses. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5, 
                color: AppColors.getTextSecondaryColor(b),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _fetchCategoryAndCourses(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final b = isDark ? Brightness.dark : Brightness.light;
    final hasFilters = _searchQuery.isNotEmpty || _selectedLevel != 'All';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.1), 
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.filter_alt_off_rounded : Icons.inbox_rounded, 
                size: 42, 
                color: _accentColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasFilters ? 'No matching courses' : 'No courses yet',
              style: TextStyle(
                fontSize: 17, 
                fontWeight: FontWeight.bold, 
                color: AppColors.getTextColor(b),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters ? 'Try adjusting your search or filters' : 'Check back soon for new courses in this category',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5, 
                color: AppColors.getTextSecondaryColor(b),
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedLevel = 'All';
                  });
                },
                child: Text(
                  'Clear filters', 
                  style: TextStyle(color: _accentColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid({
    required bool isDark,
    required _GridConfig gridConfig,
    required Color surfaceColor,
  }) {
    final baseColor = AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light);
    final highlightColor = AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light);
    final isListStyle = gridConfig.columns == 1;
    final itemCount = isListStyle ? 4 : gridConfig.columns * 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridConfig.columns,
        crossAxisSpacing: gridConfig.spacing,
        mainAxisSpacing: gridConfig.verticalSpacing,
        childAspectRatio: gridConfig.childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor, 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: baseColor),
          ),
          child: isListStyle
              ? Row(
                  children: [
                    Container(
                      width: 110,
                      decoration: BoxDecoration(
                        color: baseColor, 
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16), 
                          bottomLeft: Radius.circular(16)
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 12, width: double.infinity, color: baseColor),
                                const SizedBox(height: 8),
                                Container(height: 10, width: 100, color: baseColor),
                              ],
                            ),
                            Container(height: 10, width: 60, color: highlightColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: baseColor, 
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16), 
                            topRight: Radius.circular(16)
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 11, width: double.infinity, color: baseColor),
                                const SizedBox(height: 6),
                                Container(height: 9, width: 80, color: baseColor),
                              ],
                            ),
                            Container(height: 9, width: 50, color: highlightColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCourseCard(
    Map<String, dynamic> course, {
    required bool isDark,
    required bool isListStyle,
    required bool isSmallPhone,
    required Color surfaceColor,
    required Color cardBorderColor,
  }) {
    final b = isDark ? Brightness.dark : Brightness.light;
    final title = course['title'] as String;
    final instructor = course['instructor'] as String;
    final thumbnail = course['thumbnail'] as String;
    final rating = course['rating'] as double;
    final reviewCount = course['reviewCount'];
    final price = course['price'] as double;
    final originalPrice = course['originalPrice'] as double;
    final level = course['level'] as String;
    final lessonCount = course['lessonCount'];
    final isBestseller = course['isBestseller'] as bool;
    final isFree = course['isFree'] as bool;
    final hasDiscount = originalPrice > price && price > 0;

    final textColor = AppColors.getTextColor(b);
    final textSecondary = AppColors.getTextSecondaryColor(b);

    final thumb = ClipRRect(
      borderRadius: isListStyle
          ? const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16))
          : const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          thumbnail.isNotEmpty
              ? Image.network(
                  thumbnail, 
                  fit: BoxFit.cover, 
                  errorBuilder: (context, error, stack) => Container(
                    color: _accentColor.withValues(alpha: 0.15),
                  ),
                )
              : Container(color: _accentColor.withValues(alpha: 0.15)),
          if (isBestseller)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.getWarningColor(isDark ? Brightness.dark : Brightness.light), 
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'BESTSELLER', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 9, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final contentPadding = isSmallPhone && !isListStyle ? 8.0 : (isListStyle ? 12.0 : 10.0);

    final content = Padding(
      padding: EdgeInsets.all(contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            maxLines: 2, 
            overflow: TextOverflow.ellipsis, 
            style: TextStyle(
              fontSize: isSmallPhone ? 12 : 14, 
              fontWeight: FontWeight.w700, 
              color: textColor, 
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            instructor, 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis, 
            style: TextStyle(
              fontSize: isSmallPhone ? 10 : 11.5, 
              color: textSecondary,
            ),
          ),
          if (!isListStyle) const SizedBox(height: 2),
          if (!isListStyle)
            Row(
              children: [
                Icon(Icons.star_rounded, size: 13, color: AppColors.getWarningColor(b)),
                const SizedBox(width: 2),
                Text(
                  rating.toStringAsFixed(1), 
                  style: TextStyle(
                    fontSize: isSmallPhone ? 10 : 11, 
                    fontWeight: FontWeight.bold, 
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    '($reviewCount)', 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmallPhone ? 9 : 10, 
                      color: textSecondary,
                    ),
                  ),
                ),
                if (level.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.12), 
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        level, 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmallPhone ? 7 : 8.5, 
                          fontWeight: FontWeight.w600, 
                          color: _accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          const Spacer(),
          Row(
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline_rounded, size: 12, color: textSecondary),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '$lessonCount lessons', 
                        style: TextStyle(
                          fontSize: isSmallPhone ? 9 : 10.5, 
                          color: textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              if (isFree)
                Text(
                  'FREE', 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.getSuccessColor(b),
                  ),
                )
              else
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasDiscount) ...[
                        Flexible(
                          child: Text(
                            'रु ${originalPrice.toStringAsFixed(0)}', 
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isSmallPhone ? 9 : 10, 
                              color: textSecondary, 
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                      Text(
                        'रु ${price.toStringAsFixed(0)}', 
                        style: TextStyle(
                          fontSize: isSmallPhone ? 11.5 : 13, 
                          fontWeight: FontWeight.bold, 
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/course',
          arguments: {'courseId': course['id']},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.getTextColor(b).withValues(alpha: 0.06), 
              blurRadius: 10, 
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isListStyle
            ? Row(
                children: [
                  SizedBox(width: 110, height: double.infinity, child: thumb),
                  Expanded(child: content),
                ],
              )
            : Column(
                children: [
                  AspectRatio(aspectRatio: 16 / 10, child: thumb),
                  Expanded(child: content),
                ],
              ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final bool isDark;
  final double size;

  const _RoundIconButton({
    required this.icon, 
    required this.onTap, 
    this.filled = false, 
    this.isDark = false, 
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled 
              ? (AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light)) 
              : Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: filled 
              ? Border.all(color: AppColors.getBackgroundSelectedColor(isDark ? Brightness.dark : Brightness.light)) 
              : null,
        ),
        child: Icon(
          icon, 
          color: filled ? AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light) : Colors.white, 
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final bool isDark;
  final Color accentColor;
  final _SortOption current;
  final String Function(_SortOption) labelBuilder;
  final ValueChanged<_SortOption> onSelected;

  const _SortSheet({
    required this.isDark, 
    required this.accentColor, 
    required this.current, 
    required this.labelBuilder, 
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.getBackgroundElementColor(isDark ? Brightness.dark : Brightness.light);
    final textColor = AppColors.getTextColor(isDark ? Brightness.dark : Brightness.light);

    return Container(
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, 
            height: 4, 
            decoration: BoxDecoration(
              color: AppColors.getTextSecondaryColor(isDark ? Brightness.dark : Brightness.light).withValues(alpha: 0.4), 
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Sort by', 
                  style: TextStyle(
                    fontSize: 17, 
                    fontWeight: FontWeight.bold, 
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...(_SortOption.values.map((opt) {
            final selected = opt == current;
            return ListTile(
              onTap: () => onSelected(opt),
              title: Text(
                labelBuilder(opt), 
                style: TextStyle(
                  color: selected ? accentColor : textColor, 
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal, 
                  fontSize: 14.5,
                ),
              ),
              trailing: selected 
                  ? Icon(Icons.check_circle_rounded, color: accentColor, size: 20) 
                  : null,
            );
          })),
        ],
      ),
    );
  }
}

class _GridConfig {
  final int columns;
  final double spacing;
  final double verticalSpacing;
  final double childAspectRatio;

  _GridConfig({
    required this.columns,
    required this.spacing,
    required this.verticalSpacing,
    required this.childAspectRatio,
  });
}