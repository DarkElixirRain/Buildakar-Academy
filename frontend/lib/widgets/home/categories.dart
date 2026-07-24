// lib/widgets/home/categories.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class Categories extends StatefulWidget {
  final Function(String) onCategoryPress;
  final VoidCallback onSeeAll;

  const Categories({
    Key? key,
    required this.onCategoryPress,
    required this.onSeeAll,
  }) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;
  final ApiService _apiService = ApiService();

  // Default icons mapping for fallback
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

  // Default colors for fallback
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
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

  List<Map<String, dynamic>> _getFallbackCategories() {
    return [
      {
        'id': '1',
        'name': 'Programming',
        'slug': 'programming',
        'icon': Icons.code,
        'color': const Color(0xFF6366F1),
        'courseCount': 45,
        'image': 'https://picsum.photos/400/200?random=100',
        'description': 'Learn programming languages and development',
        'isActive': true,
      },
      {
        'id': '2',
        'name': 'Design',
        'slug': 'design',
        'icon': Icons.design_services,
        'color': const Color(0xFF8B5CF6),
        'courseCount': 32,
        'image': 'https://picsum.photos/400/200?random=101',
        'description': 'UI/UX, Graphic Design, and more',
        'isActive': true,
      },
      {
        'id': '3',
        'name': 'Business',
        'slug': 'business',
        'icon': Icons.business_center,
        'color': const Color(0xFF10B981),
        'courseCount': 28,
        'image': 'https://picsum.photos/400/200?random=102',
        'description': 'Business management and entrepreneurship',
        'isActive': true,
      },
      {
        'id': '4',
        'name': 'Marketing',
        'slug': 'marketing',
        'icon': Icons.campaign,
        'color': const Color(0xFFF59E0B),
        'courseCount': 20,
        'image': 'https://picsum.photos/400/200?random=103',
        'description': 'Digital marketing and branding',
        'isActive': true,
      },
      {
        'id': '5',
        'name': 'Photography',
        'slug': 'photography',
        'icon': Icons.photo_camera,
        'color': const Color(0xFFEF4444),
        'courseCount': 15,
        'image': 'https://picsum.photos/400/200?random=104',
        'description': 'Photography techniques and editing',
        'isActive': true,
      },
      {
        'id': '6',
        'name': 'Music',
        'slug': 'music',
        'icon': Icons.music_note,
        'color': const Color(0xFFEC4899),
        'courseCount': 12,
        'image': 'https://picsum.photos/400/200?random=105',
        'description': 'Music theory and production',
        'isActive': true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get theme-aware colors
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final errorColor = AppColors.getErrorColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);

    // Responsive sizing
    double cardWidth;
    double cardHeight;
    double imageHeight;
    double fontSizeTitle;
    double fontSizeCount;
    double paddingSize;
    double gap;
    double borderRadius;

    if (screenWidth < 380) {
      // Small phones
      cardWidth = screenWidth * 0.55;
      cardHeight = screenHeight * 0.2;
      imageHeight = cardHeight * 0.55;
      fontSizeTitle = 13.0;
      fontSizeCount = 10.0;
      paddingSize = 10.0;
      gap = 8.0;
      borderRadius = 14.0;
    } else if (screenWidth < 600) {
      // Medium phones
      cardWidth = screenWidth * 0.45;
      cardHeight = screenHeight * 0.22;
      imageHeight = cardHeight * 0.55;
      fontSizeTitle = 14.0;
      fontSizeCount = 11.0;
      paddingSize = 12.0;
      gap = 10.0;
      borderRadius = 16.0;
    } else if (screenWidth < 900) {
      // Tablets
      cardWidth = screenWidth * 0.28;
      cardHeight = screenHeight * 0.24;
      imageHeight = cardHeight * 0.55;
      fontSizeTitle = 16.0;
      fontSizeCount = 12.0;
      paddingSize = 14.0;
      gap = 14.0;
      borderRadius = 18.0;
    } else {
      // Desktop / Large screens
      cardWidth = screenWidth * 0.18;
      cardHeight = screenHeight * 0.26;
      imageHeight = cardHeight * 0.55;
      fontSizeTitle = 17.0;
      fontSizeCount = 13.0;
      paddingSize = 16.0;
      gap = 16.0;
      borderRadius = 20.0;
    }

    // Clamp values
    cardWidth = cardWidth.clamp(120.0, 280.0);
    cardHeight = cardHeight.clamp(140.0, 300.0);
    imageHeight = imageHeight.clamp(70.0, 160.0);

    // Show loading state
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: screenWidth < 380 ? 20.0 : 24.0,
                  width: screenWidth < 380 ? 80.0 : 100.0,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: screenWidth < 380 ? 14.0 : 18.0,
                  width: screenWidth < 380 ? 50.0 : 60.0,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: cardHeight + 10,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: const EdgeInsets.only(right: 16),
              itemBuilder: (context, index) {
                return Container(
                  width: cardWidth,
                  height: cardHeight,
                  margin: EdgeInsets.only(right: gap),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E3135) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3D4045) : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadius),
                            topRight: Radius.circular(borderRadius),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(paddingSize),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 12.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3D4045) : const Color(0xFFD1D5DB),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                height: 10.0,
                                width: 80.0,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3D4045) : const Color(0xFFD1D5DB),
                                  borderRadius: BorderRadius.circular(4),
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
          ),
        ],
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: screenWidth < 380 ? 18.0 : 20.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: widget.onSeeAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: screenWidth < 380 ? 12.0 : 14.0,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: screenWidth < 380 ? 16.0 : 18.0,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal Scroll
        SizedBox(
          height: cardHeight + 10,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _categories.length,
            padding: const EdgeInsets.only(right: 16),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isLast = index == _categories.length - 1;
              return _buildCategoryCard(
                context,
                category,
                isLast,
                cardWidth,
                cardHeight,
                imageHeight,
                fontSizeTitle,
                fontSizeCount,
                paddingSize,
                gap,
                borderRadius,
                isDark,
                brightness,
                screenWidth,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
    bool isLast,
    double cardWidth,
    double cardHeight,
    double imageHeight,
    double fontSizeTitle,
    double fontSizeCount,
    double paddingSize,
    double gap,
    double borderRadius,
    bool isDark,
    Brightness brightness,
    double screenWidth,
  ) {
    final color = category['color'] as Color? ?? Colors.blue;
    final imageUrl = category['image'] as String? ?? '';
    final courseCount = category['courseCount'] ?? 0;
    final name = category['name'] as String? ?? 'Category';

    return GestureDetector(
      onTap: () => widget.onCategoryPress(category['id']),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(
          right: isLast ? 0 : gap,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Background Image or Color
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: color.withValues(alpha: 0.85),
                    );
                  },
                )
              else
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: color.withValues(alpha: 0.85),
                ),
              
              // Gradient Overlay
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              
              // Content - Without Icon
              Padding(
                padding: EdgeInsets.all(paddingSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category Name
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    
                    // Course Count Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: fontSizeCount + 2,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$courseCount ${courseCount == 1 ? 'Course' : 'Courses'}',
                            style: TextStyle(
                              fontSize: fontSizeCount,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}