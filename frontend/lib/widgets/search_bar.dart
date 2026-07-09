// lib/widgets/search_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String hintText;
  final bool autoFocus;
  final VoidCallback? onClear;
  final VoidCallback? onTap;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search...',
    this.autoFocus = false,
    this.onClear,
    this.onTap,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            color: AppColors.getTextSecondaryColor(brightness),
            size: isTablet ? 24 : 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              autofocus: widget.autoFocus,
              onChanged: widget.onSearch,
              onTap: widget.onTap,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.inter(
                  color: AppColors.getTextSecondaryColor(brightness),
                  fontSize: isTablet ? 16 : 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: GoogleFonts.inter(
                color: AppColors.getTextColor(brightness),
                fontSize: isTablet ? 16 : 14,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSearch,
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: AppColors.getTextSecondaryColor(brightness),
                size: isTablet ? 22 : 20,
              ),
              onPressed: () {
                widget.controller.clear();
                widget.onSearch('');
                if (widget.onClear != null) {
                  widget.onClear!();
                }
                setState(() {});
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 8),
          Container(
            height: 30,
            width: 1,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: AppColors.getPrimaryColor(brightness),
              size: isTablet ? 24 : 22,
            ),
            onPressed: () {
              // Show filter dialog
              _showFilterDialog(context);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.getBackgroundColor(brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Options',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextColor(brightness),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Coming soon...'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}