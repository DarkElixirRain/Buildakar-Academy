// lib/screens/categories/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;
  final ApiService _apiService = ApiService();
  String _searchQuery = '';

  // Default icons mapping (kept for potential future use)
  final Map<String, IconData> _iconMap = {
    'programming': Icons.code,
    'design': Icons.design_services,
    'business': Icons.business_center,
    'marketing': Icons.campaign,
    'photography': Icons.photo_camera,
    'music': Icons.music_note,
    'art': Icons.art_track,
    'science': Icons.science,
    'math': Icons.calculate,
    'language': Icons.language,
    'health': Icons.health_and_safety,
    'fitness': Icons.fitness_center,
    'finance': Icons.attach_money,
    'technology': Icons.computer,
    'engineering': Icons.engineering,
    'education': Icons.school,
    'development': Icons.code,
    'mobile': Icons.phone_android,
    'web': Icons.web,
    'data': Icons.data_usage,
    'ai': Icons.psychology,
    'cloud': Icons.cloud,
    'security': Icons.security,
  };

  // Default colors
  final List<Color> _defaultColors = [
    const Color(0xFF6366F1),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFFF59E0B),
    const Color(0xFF10B981),
    const Color(0xFF3B82F6),
    const Color(0xFFEF4444),
    const Color(0xFF14B8A6),
    const Color(0xFFF97316),
    const Color(0xFF7C3AED),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getCategories();

      if (!mounted) return;

      if (response.success) {
        final List<dynamic> categoriesData = response.data ?? [];
        _categories = categoriesData.map((category) {
          return _transformCategoryData(category);
        }).toList();
        setState(() {
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load categories';
          _isLoading = false;
          _categories = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _categories = [];
      });
    }
  }

  Future<void> _refreshData() async {
    await _fetchCategories();
  }

  Map<String, dynamic> _transformCategoryData(Map<String, dynamic> category) {
    final name = category['name'] ?? 'Category';
    final slug = category['slug'] ?? name.toLowerCase().replaceAll(' ', '-');
    
    IconData icon = _iconMap[slug] ?? Icons.category;
    
    Color color;
    if (category['color'] != null && category['color'].toString().isNotEmpty) {
      try {
        color = Color(int.parse(category['color'].replaceAll('#', '0xFF')));
      } catch (e) {
        color = _getColorFromSlug(slug);
      }
    } else {
      color = _getColorFromSlug(slug);
    }

    int courseCount = 0;
    if (category['_count'] != null && category['_count']['courses'] != null) {
      courseCount = category['_count']['courses'];
    } else if (category['courseCount'] != null) {
      courseCount = category['courseCount'];
    }

    return {
      'id': category['id'] ?? '',
      'name': name,
      'slug': slug,
      'icon': icon,
      'color': color,
      'courseCount': courseCount,
      'image': category['image'] ?? '',
      'description': category['description'] ?? '',
      'isActive': category['isActive'] ?? true,
    };
  }

  Color _getColorFromSlug(String slug) {
    int hash = 0;
    for (int i = 0; i < slug.length; i++) {
      hash = slug.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % _defaultColors.length;
    return _defaultColors[index];
  }

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories.where((category) {
      final name = category['name']?.toString().toLowerCase() ?? '';
      final description = category['description']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  void _handleCategoryPress(Map<String, dynamic> category) {
    Navigator.pushNamed(
      context,
      '/category',
      arguments: {'categoryId': category['id']},
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(brightness),
      appBar: AppBar(
        title: Text(
          'Explore Categories',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.getTextColor(brightness),
            fontSize: isSmallScreen ? 20.0 : 24.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.getTextColor(brightness),
            size: 20.0,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundSelectedColor(brightness),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.getBackgroundSelectedColor(brightness),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(
                    color: AppColors.getTextSecondaryColor(brightness),
                    fontSize: 14.0,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.getTextSecondaryColor(brightness),
                    size: 22.0,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: AppColors.getTextSecondaryColor(brightness),
                            size: 20.0,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(
                  color: AppColors.getTextColor(brightness),
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.getPrimaryColor(brightness),
        backgroundColor: isDark ? AppColors.getBackgroundSelectedColor(brightness) : AppColors.getBackgroundColor(brightness),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final brightness = Theme.of(context).brightness;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isSmallScreen = screenWidth < 400;

    if (_isLoading) {
      return _buildSkeleton(isTablet, isSmallScreen);
    }

    if (_error != null && _categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: AppColors.getErrorColor(brightness).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40.0,
                color: AppColors.getErrorColor(brightness),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(brightness),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load categories',
              style: TextStyle(
                fontSize: 14.0,
                color: AppColors.getTextSecondaryColor(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor(brightness),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredCategories;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: AppColors.getTextSecondaryColor(brightness).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40.0,
                color: AppColors.getTextSecondaryColor(brightness),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(brightness),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'No categories available',
              style: TextStyle(
                fontSize: 14.0,
                color: AppColors.getTextSecondaryColor(brightness),
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: AppColors.getPrimaryColor(brightness),
                  ),
                ),
                icon: const Icon(Icons.clear_rounded, size: 20),
                label: Text(
                  'Clear Search',
                  style: TextStyle(
                    color: AppColors.getPrimaryColor(brightness),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Responsive grid
    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 1.1;
      spacing = 20.0;
    } else if (isSmallScreen) {
      crossAxisCount = 2;
      childAspectRatio = 0.9;
      spacing = 12.0;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.0;
      spacing = 16.0;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: filtered.length,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemBuilder: (context, index) {
          final category = filtered[index];
          return _buildCategoryCard(category, brightness);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, Brightness brightness) {
    final color = category['color'] as Color? ?? Colors.blue;
    final imageUrl = category['image'] as String? ?? '';
    final courseCount = category['courseCount'] ?? 0;
    final name = category['name'] as String? ?? 'Category';
    final description = category['description'] as String? ?? '';

    return GestureDetector(
      onTap: () => _handleCategoryPress(category),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              offset: const Offset(0, 8),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: color.withValues(alpha: 0.8),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.5),
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: color.withValues(alpha: 0.8),
                    );
                  },
                )
              else
                Container(
                  color: color.withValues(alpha: 0.8),
                ),
              
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Empty space to maintain layout
                    const SizedBox.shrink(),
                    
                    // Bottom Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Name
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Description
                        if (description.isNotEmpty)
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.0,
                              color: Colors.white.withValues(alpha: 0.8),
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Course Count Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 12.0,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$courseCount ${courseCount == 1 ? 'Course' : 'Courses'}',
                                style: const TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isTablet, bool isSmallScreen) {
    final brightness = Theme.of(context).brightness;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive grid values
    int crossAxisCount;
    double childAspectRatio;
    double spacing;
    int itemCount;

    if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 0.95;
      spacing = 20.0;
      itemCount = 6;
    } else if (isSmallScreen) {
      crossAxisCount = 2;
      childAspectRatio = 0.72;
      spacing = 12.0;
      itemCount = 4;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.74;
      spacing = 16.0;
      itemCount = 6;
    }

    // Adjust item count based on screen size
    if (screenWidth > 1200) {
      itemCount = 9;
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: itemCount,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSelectedColor(brightness),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.getBackgroundSelectedColor(brightness),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Image skeleton - fixed aspect ratio like real card
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                // Content skeleton
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title skeleton
                        Container(
                          height: 11.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.getBackgroundSelectedColor(brightness),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Description skeleton
                        Container(
                          height: 9.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: AppColors.getBackgroundSelectedColor(brightness),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        // Badge skeleton
                        Container(
                          height: 16.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: AppColors.getBackgroundSelectedColor(brightness),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}