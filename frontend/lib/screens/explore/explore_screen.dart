// lib/screens/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/explore/explore_widget.dart';
import '../../widgets/explore/course_card.dart';
import '../../widgets/explore/explore_loading_skeleton.dart';

class ExploreScreen extends StatefulWidget {
  final int? initialTab;

  const ExploreScreen({
    Key? key,
    this.initialTab,
  }) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreContentState();
}

class _ExploreContentState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  String? _error;

  String _searchQuery = '';
  String _selectedCategoryId = 'all';
  String _sort = 'Newest';
  Set<String> _levelFilters = {};
  RangeValues _priceRange = const RangeValues(0, 200);

  List<Map<String, dynamic>> _allCourses = [];
  List<Map<String, dynamic>> _categories = [];
  int _currentPage = 0;
  static const int _pageSize = 12;

  List<Map<String, dynamic>> get _visibleCourses => _applyFilters(_allCourses);

  // Cache for categories to avoid reloading
  List<Map<String, dynamic>> _cachedCategories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    _loadCategoriesAndCourses();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreCourses();
    }
  }

  Future<void> _loadCategoriesAndCourses() async {
    // If categories are cached, use them immediately
    if (_cachedCategories.isNotEmpty) {
      setState(() {
        _categories = _cachedCategories;
        _isLoading = false;
      });
      // Still load courses
      await _loadCourses(reset: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load categories first
      final categoryResponse = await _apiService.getCategories();
      
      if (!mounted) return;

      if (categoryResponse.success) {
        final List<dynamic> categoriesData = categoryResponse.data ?? [];
        final List<Map<String, dynamic>> newCategories = [
          {'id': 'all', 'name': 'All', 'icon': Icons.apps_rounded},
          ...categoriesData.map((cat) {
            return {
              'id': cat['id'] ?? '',
              'name': cat['name'] ?? 'Category',
              'slug': cat['slug'] ?? '',
              'icon': _getCategoryIcon(cat['slug'] ?? ''),
              'image': cat['image'] ?? '',
              'color': cat['color'] ?? '#6366F1',
            };
          }).toList()
        ];
        
        // Cache categories
        _cachedCategories = newCategories;
        _categories = newCategories;
      }

      // Load courses using the public endpoint
      await _loadCourses(reset: true);
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load data. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCourses({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 0;
        _allCourses = [];
      });
    }

    try {
      // Use the public courses endpoint
      final response = await _apiService.getPublicCourses(
        page: _currentPage + 1,
        limit: _pageSize,
        categoryId: _selectedCategoryId != 'all' ? _selectedCategoryId : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _getSortParam(),
        level: _levelFilters.isNotEmpty ? _levelFilters.first : null,
      );

      if (!mounted) return;

      if (response.success) {
        final Map<String, dynamic> data = response.data ?? {};
        final List<dynamic> coursesData = data['data'] ?? [];
        final transformed = coursesData.map((course) => _transformCourseData(course)).toList();

        setState(() {
          if (reset) {
            _allCourses = transformed;
          } else {
            _allCourses.addAll(transformed);
          }
          _hasMore = transformed.length >= _pageSize;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load courses';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreCourses() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _loadCourses(reset: false);
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    _currentPage = 0;
    await _loadCourses(reset: true);
    if (mounted) setState(() => _isRefreshing = false);
  }

  Map<String, dynamic> _transformCourseData(dynamic course) {
    final price = _toDouble(course['price']);
    final originalPrice = _toDouble(course['originalPrice'] ?? course['price']);
    
    // Get category name
    String categoryName = '';
    if (course['category'] != null) {
      if (course['category'] is Map) {
        categoryName = course['category']['name'] ?? '';
      } else if (course['category'] is String) {
        categoryName = course['category'];
      }
    }
    
    // Get instructor name
    String instructorName = 'Unknown Instructor';
    if (course['instructor'] != null) {
      if (course['instructor'] is Map) {
        final instructor = course['instructor'];
        final firstName = instructor['firstName'] ?? '';
        final lastName = instructor['lastName'] ?? '';
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          instructorName = '$firstName $lastName'.trim();
        } else if (instructor['name'] != null) {
          instructorName = instructor['name'];
        }
      } else if (course['instructor'] is String) {
        instructorName = course['instructor'];
      }
    }

    return {
      'id': course['id']?.toString() ?? '',
      'courseId': course['id']?.toString() ?? '',
      'title': course['title'] ?? 'Untitled Course',
      'instructor': instructorName,
      'thumbnail': _getThumbnail(course),
      'image': _getThumbnail(course),
      'category': categoryName,
      'categoryId': course['categoryId'] ?? course['category']?['id'] ?? '',
      'level': course['level'] ?? 'Beginner',
      'rating': _toDouble(course['rating'] ?? course['avgRating']),
      'students': _toInt(course['studentCount'] ?? course['_count']?['enrollments']),
      'price': price,
      'oldPrice': originalPrice > price ? originalPrice : null,
      'isBookmarked': false,
      'description': course['description'] ?? '',
      'lessonCount': _toInt(course['lessonCount'] ?? course['_count']?['lessons']),
      'isFree': price == 0,
      'isBestseller': course['isBestseller'] ?? false,
      'progress': _toDouble(course['progress']),
    };
  }

  String _getThumbnail(dynamic course) {
    for (final key in ['thumbnail', 'thumbnailUrl', 'image', 'coverImage', 'cover']) {
      final v = course[key];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return '';
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

  IconData _getCategoryIcon(String slug) {
    final iconMap = {
      'programming': Icons.code_rounded,
      'design': Icons.design_services_rounded,
      'business': Icons.business_center_rounded,
      'marketing': Icons.campaign_rounded,
      'photography': Icons.photo_camera_rounded,
      'music': Icons.music_note_rounded,
      'art': Icons.art_track_rounded,
      'science': Icons.science_rounded,
      'math': Icons.calculate_rounded,
      'language': Icons.language_rounded,
      'health': Icons.health_and_safety_rounded,
      'fitness': Icons.fitness_center_rounded,
      'finance': Icons.attach_money_rounded,
      'technology': Icons.computer_rounded,
      'engineering': Icons.engineering_rounded,
      'education': Icons.school_rounded,
      'development': Icons.code_rounded,
      'mobile': Icons.phone_android_rounded,
      'web': Icons.web_rounded,
      'data': Icons.data_usage_rounded,
      'ai': Icons.psychology_rounded,
      'cloud': Icons.cloud_rounded,
      'security': Icons.security_rounded,
    };
    return iconMap[slug] ?? Icons.category_rounded;
  }

  String _getSortParam() {
    switch (_sort) {
      case 'Highest Rated':
        return 'rating';
      case 'Price: Low to High':
        return 'price_asc';
      case 'Price: High to Low':
        return 'price_desc';
      case 'Newest':
        return 'newest';
      case 'Most Popular':
      default:
        return 'popular';
    }
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> source) {
    var list = source.where((c) {
      final matchesCategory =
          _selectedCategoryId == 'all' || c['categoryId'] == _selectedCategoryId;
      final matchesQuery = _searchQuery.isEmpty ||
          (c['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c['instructor'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLevel = _levelFilters.isEmpty || _levelFilters.contains(c['level']);
      final price = (c['price'] as num).toDouble();
      final matchesPrice = price >= _priceRange.start && price <= _priceRange.end;
      return matchesCategory && matchesQuery && matchesLevel && matchesPrice;
    }).toList();

    // Apply sorting (client-side sorting since API might not support all sort types)
    switch (_sort) {
      case 'Highest Rated':
        list.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
        break;
      case 'Price: Low to High':
        list.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
        break;
      case 'Newest':
        list.sort((a, b) => (b['id'] as String).compareTo(a['id'] as String));
        break;
      default:
        list.sort((a, b) => (b['students'] as num).compareTo(a['students'] as num));
    }
    return list;
  }

  bool get _hasActiveFilters =>
      _levelFilters.isNotEmpty || _priceRange.start != 0 || _priceRange.end != 200;

  void _toggleBookmark(String courseId) {
    setState(() {
      final index = _allCourses.indexWhere((c) => c['id'] == courseId);
      if (index != -1) {
        _allCourses[index]['isBookmarked'] = !_allCourses[index]['isBookmarked'];
      }
    });
  }

  void _openCourse(String courseId) {
    Navigator.pushNamed(
      context,
      '/course',
      arguments: {'courseId': courseId},
    );
  }

  void _openFilters() {
    SortFilterSheet.show(
      context,
      initialSort: _sort,
      initialLevels: _levelFilters,
      initialPriceRange: _priceRange,
      onApply: (sort, levels, price) {
        setState(() {
          _sort = sort;
          _levelFilters = levels;
          _priceRange = price;
        });
        // Reload courses with new filters
        _currentPage = 0;
        _loadCourses(reset: true);
      },
    );
  }

  // Handle category selection with better loading experience
  void _handleCategorySelected(String id) {
    if (_selectedCategoryId == id) return;
    
    setState(() {
      _selectedCategoryId = id;
      _currentPage = 0;
      _allCourses = [];
    });
    
    // Load courses immediately
    _loadCourses(reset: true);
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
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    
    final screenWidth = MediaQuery.of(context).size.width;

    final double horizontalPadding = screenWidth < 480
        ? 16
        : screenWidth < 900
            ? 24
            : 40;

    // Fixed: Removed const so the skeleton can access ThemeProvider
    if (_isLoading && _allCourses.isEmpty) {
      return const ExploreLoadingSkeleton();
    }

    if (_error != null && _allCourses.isEmpty) {
      return ErrorState(
        message: _error!,
        onRetry: _loadCategoriesAndCourses,
      );
    }

    final courses = _visibleCourses;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: primaryColor,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
              sliver: SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Explore title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore',
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth < 600 ? 26 : 32,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find your next course',
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth < 600 ? 14 : 16,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          // Course count on large screens
                          if (screenWidth > 900 && courses.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: backgroundElementColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                '${courses.length} courses',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Search bar and filters row - now side by side on large screens
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar (flexible)
                          Expanded(
                            child: ExploreSearchBar(
                              controller: _searchController,
                              hasActiveFilters: _hasActiveFilters,
                              onFilterTap: _openFilters,
                              onChanged: (v) {
                                setState(() => _searchQuery = v);
                                // Debounce search
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (_searchQuery == v) {
                                    _currentPage = 0;
                                    _loadCourses(reset: true);
                                  }
                                });
                              },
                            ),
                          ),
                          // Sort dropdown on large screens
                          if (screenWidth > 780) ...[
                            const SizedBox(width: 12),
                            Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: backgroundElementColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sort_rounded,
                                    size: 18,
                                    color: textSecondaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: _sort,
                                    dropdownColor: backgroundElementColor,
                                    underline: const SizedBox(),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                    items: const [
                                      'Most Popular',
                                      'Newest',
                                      'Highest Rated',
                                      'Price: Low to High',
                                      'Price: High to Low',
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _sort = newValue;
                                          _currentPage = 0;
                                          _loadCourses(reset: true);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Categories chips
                      if (_categories.isNotEmpty)
                        CategoryChips(
                          categories: _categories,
                          selectedId: _selectedCategoryId,
                          onSelected: _handleCategorySelected,
                        ),
                      const SizedBox(height: 16),
                      
                      // Sort and count row (for mobile)
                      if (screenWidth <= 780)
                        Row(
                          children: [
                            Text(
                              '${courses.length} courses',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textSecondaryColor,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: _openFilters,
                              child: Row(
                                children: [
                                  Text(
                                    _sort,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Icon(
                                    Icons.expand_more_rounded,
                                    size: 18,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
            if (courses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: textSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No courses match "$_searchQuery"'
                              : 'No courses found',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try adjusting your search or filters'
                              : 'Check back later for new courses',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_hasActiveFilters) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _levelFilters = {};
                                _priceRange = const RangeValues(0, 200);
                                _searchQuery = '';
                                _searchController.clear();
                                _selectedCategoryId = 'all';
                              });
                              _currentPage = 0;
                              _loadCourses(reset: true);
                            },
                            child: Text(
                              'Clear all filters',
                              style: TextStyle(
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        children: [
                          CourseGrid(
                            courses: courses,
                            onCoursePress: _openCourse,
                            onBookmarkToggle: _toggleBookmark,
                          ),
                          if (_isLoadingMore)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                          if (!_hasMore && courses.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "You've reached the end 🎉",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}