// lib/widgets/explore/explore_widgets.dart
//
// Shared small widgets used across the Explore screen:
// - ExploreSearchBar   : search field + filter trigger
// - CategoryChips      : horizontal scrollable category selector
// - SortFilterSheet    : bottom sheet for sort + filter options
// - LevelBadge/RatingPill: small decorative badges used on cards

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

/// ---------------------------------------------------------------------
/// Search bar with an attached filter button. Tapping the field opens
/// (or navigates to) a full search flow via [onTap]; typing triggers
/// [onChanged] for live filtering. The filter icon opens [onFilterTap].
/// ---------------------------------------------------------------------
class ExploreSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  const ExploreSearchBar({
    Key? key,
    required this.controller,
    this.onChanged,
    this.onFilterTap,
    this.hasActiveFilters = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundElementColor(brightness),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.getBackgroundSelectedColor(brightness)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.inter(fontSize: 15, color: textColor),
              cursorColor: primaryColor,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search courses, instructors...',
                hintStyle: GoogleFonts.inter(fontSize: 15, color: textSecondaryColor),
                prefixIcon: Icon(Icons.search_rounded, color: textSecondaryColor, size: 22),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, color: textSecondaryColor, size: 18),
                        onPressed: () {
                          controller.clear();
                          onChanged?.call('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: hasActiveFilters ? primaryColor : AppColors.getBackgroundElementColor(brightness),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasActiveFilters ? primaryColor : AppColors.getBackgroundSelectedColor(brightness),
                  ),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: hasActiveFilters ? Colors.white : textColor,
                  size: 22,
                ),
              ),
            ),
            if (hasActiveFilters)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.getBackgroundColor(brightness), width: 2),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Horizontal scrollable list of category chips.
/// ---------------------------------------------------------------------
class CategoryChips extends StatelessWidget {
  final List<Map<String, dynamic>> categories; // {id, name, icon, color}
  final String selectedId;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    Key? key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool selected = cat['id'] == selectedId;
          return InkWell(
            onTap: () => onSelected(cat['id'] as String),
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? primaryColor : AppColors.getBackgroundElementColor(brightness),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? primaryColor : AppColors.getBackgroundSelectedColor(brightness),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat['icon'] != null) ...[
                    Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: selected ? Colors.white : textColor,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    cat['name'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Small level badge, e.g. "Beginner" / "Intermediate" / "Advanced".
/// ---------------------------------------------------------------------
class LevelBadge extends StatelessWidget {
  final String level;
  final Brightness brightness;
  const LevelBadge({Key? key, required this.level, required this.brightness}) : super(key: key);

  Color _color() {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.getSuccessColor(brightness);
      case 'intermediate':
        return AppColors.getWarningColor(brightness);
      case 'advanced':
        return AppColors.getErrorColor(brightness);
      default:
        return AppColors.getPrimaryColor(brightness);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        level,
        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Small rating pill with star icon.
/// ---------------------------------------------------------------------
class RatingPill extends StatelessWidget {
  final double rating;
  const RatingPill({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final textColor = AppColors.getTextColor(brightness);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 15, color: AppColors.getWarningColor(brightness)),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Bottom sheet with sort options and filter toggles.
/// Returns the selected sort/filter state via [onApply].
/// ---------------------------------------------------------------------
class SortFilterSheet extends StatefulWidget {
  final String initialSort;
  final Set<String> initialLevels;
  final RangeValues initialPriceRange;
  final void Function(String sort, Set<String> levels, RangeValues price) onApply;

  const SortFilterSheet({
    Key? key,
    required this.initialSort,
    required this.initialLevels,
    required this.initialPriceRange,
    required this.onApply,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String initialSort,
    required Set<String> initialLevels,
    required RangeValues initialPriceRange,
    required void Function(String sort, Set<String> levels, RangeValues price) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SortFilterSheet(
        initialSort: initialSort,
        initialLevels: initialLevels,
        initialPriceRange: initialPriceRange,
        onApply: onApply,
      ),
    );
  }

  @override
  State<SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<SortFilterSheet> {
  late String _sort;
  late Set<String> _levels;
  late RangeValues _price;

  static const _sortOptions = ['Most Popular', 'Newest', 'Highest Rated', 'Price: Low to High', 'Price: High to Low'];
  static const _levelOptions = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _sort = widget.initialSort;
    _levels = {...widget.initialLevels};
    _price = widget.initialPriceRange;
  }

  @override
  Widget build(BuildContext context) {
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    
    final maxSheetWidth = MediaQuery.of(context).size.width > 700 ? 500.0 : double.infinity;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxSheetWidth),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: backgroundElementColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSelectedColor(brightness),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort & Filter',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _sort = _sortOptions.first;
                          _levels = {};
                          _price = const RangeValues(0, 200);
                        });
                      },
                      child: Text(
                        'Reset',
                        style: GoogleFonts.inter(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Sort by',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sortOptions.map((opt) {
                    final selected = _sort == opt;
                    return ChoiceChip(
                      label: Text(
                        opt,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: selected ? Colors.white : textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: selected,
                      onSelected: (_) => setState(() => _sort = opt),
                      selectedColor: primaryColor,
                      backgroundColor: AppColors.getBackgroundColor(brightness),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: selected ? primaryColor : AppColors.getBackgroundSelectedColor(brightness)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Level',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _levelOptions.map((lvl) {
                    final selected = _levels.contains(lvl);
                    return FilterChip(
                      label: Text(
                        lvl,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: selected ? Colors.white : textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: selected,
                      onSelected: (v) => setState(() => v ? _levels.add(lvl) : _levels.remove(lvl)),
                      selectedColor: primaryColor,
                      backgroundColor: AppColors.getBackgroundColor(brightness),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: selected ? primaryColor : AppColors.getBackgroundSelectedColor(brightness)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Price range',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSecondaryColor,
                  ),
                ),
                RangeSlider(
                  values: _price,
                  min: 0,
                  max: 200,
                  divisions: 20,
                  activeColor: primaryColor,
                  labels: RangeLabels('रु ${_price.start.round()}', 'रु ${_price.end.round()}'),
                  onChanged: (v) => setState(() => _price = v),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_sort, _levels, _price);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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
}