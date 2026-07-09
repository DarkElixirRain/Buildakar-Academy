// lib/widgets/search/search_suggestions_dropdown.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/search_suggestion.dart';

class SearchSuggestionsDropdown extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSuggestionSelected;
  final Function(String) onRecentSearchSelected;
  final VoidCallback onClearRecentSearches;

  const SearchSuggestionsDropdown({
    Key? key,
    required this.searchQuery,
    required this.onSuggestionSelected,
    required this.onRecentSearchSelected,
    required this.onClearRecentSearches,
  }) : super(key: key);

  @override
  State<SearchSuggestionsDropdown> createState() => _SearchSuggestionsDropdownState();
}

class _SearchSuggestionsDropdownState extends State<SearchSuggestionsDropdown> {
  void _handleSuggestionTap(SearchSuggestion suggestion) {
    // Close the dropdown
    widget.onSuggestionSelected(suggestion.title);
    
    // Navigate based on type
    switch (suggestion.type) {
      case 'course':
        Navigator.pushNamed(
          context,
          '/course',
          arguments: {'courseId': suggestion.id},
        );
        break;
      case 'instructor':
        Navigator.pushNamed(
          context,
          '/instructor',
          arguments: {'instructorId': suggestion.id},
        );
        break;
      case 'category':
        Navigator.pushNamed(
          context,
          '/category',
          arguments: {'categoryId': suggestion.id},
        );
        break;
      default:
        // If type is unknown, just do a search
        widget.onSuggestionSelected(suggestion.title);
        break;
    }
  }

  void _handleRecentSearchTap(String query) {
    widget.onRecentSearchSelected(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    
    // Get theme from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    final suggestions = searchProvider.suggestions;
    final recentSearches = searchProvider.recentSearches;
    final isLoading = searchProvider.isLoadingSuggestions;

    // Get theme-aware colors with non-nullable values
    final backgroundColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final textSecondaryColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final textMutedColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final surfaceColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final dividerColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.searchQuery.isEmpty && recentSearches.isNotEmpty)
            _buildRecentSearches(
              context, 
              recentSearches, 
              isDark, 
              textColor, 
              textSecondaryColor, 
              textMutedColor, 
              dividerColor
            ),
          
          if (widget.searchQuery.isNotEmpty)
            _buildSuggestionsSection(
              context, 
              suggestions, 
              isLoading, 
              isDark, 
              textColor, 
              textSecondaryColor, 
              textMutedColor
            ),
          
          if (widget.searchQuery.isNotEmpty && !isLoading && suggestions.isEmpty)
            _buildNoResults(isDark, textSecondaryColor),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(
    BuildContext context,
    List<String> recentSearches,
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
    Color textMutedColor,
    Color dividerColor,
  ) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondaryColor,
                ),
              ),
              TextButton(
                onPressed: widget.onClearRecentSearches,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...recentSearches.map((query) => ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(
            Icons.history,
            size: 20,
            color: textMutedColor,
          ),
          title: Text(
            query,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.close,
              size: 16,
              color: textMutedColor,
            ),
            onPressed: () {
              searchProvider.removeRecentSearch(query);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 16,
          ),
          onTap: () => _handleRecentSearchTap(query),
          tileColor: Colors.transparent,
          splashColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          hoverColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
        )),
        Divider(
          height: 1,
          color: dividerColor,
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(
    BuildContext context,
    List<SearchSuggestion> suggestions,
    bool isLoading,
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
    Color textMutedColor,
  ) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isDark ? Colors.blue[400] : Colors.blue[600],
            ),
          ),
        ),
      );
    }

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: textMutedColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        ...suggestions.map((suggestion) => _buildSuggestionTile(
          context, 
          suggestion, 
          isDark, 
          textColor, 
          textSecondaryColor,
        )),
      ],
    );
  }

  Widget _buildSuggestionTile(
    BuildContext context,
    SearchSuggestion suggestion,
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
  ) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: _buildSuggestionIcon(suggestion, isDark),
      title: Text(
        suggestion.title,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: suggestion.type == 'course' ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: suggestion.subtitle.isNotEmpty
          ? Text(
              suggestion.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: textSecondaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () {
        // Save the search
        searchProvider.saveRecentSearch(suggestion.title);
        // Handle the tap with navigation
        _handleSuggestionTap(suggestion);
      },
      tileColor: Colors.transparent,
      splashColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
      hoverColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
    );
  }

  Widget _buildSuggestionIcon(SearchSuggestion suggestion, bool isDark) {
    // Theme-aware colors with non-nullable values
    final primaryColor = isDark ? Colors.blue[400]! : Colors.blue[600]!;
    final primaryLightColor = isDark ? Colors.blue[900]! : Colors.blue[50]!;
    final secondaryColor = isDark ? Colors.purple[400]! : Colors.purple[600]!;
    final secondaryLightColor = isDark ? Colors.purple[900]! : Colors.purple[50]!;
    final tertiaryColor = isDark ? Colors.orange[400]! : Colors.orange[600]!;
    final tertiaryLightColor = isDark ? Colors.orange[900]! : Colors.orange[50]!;

    switch (suggestion.type) {
      case 'course':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: suggestion.image != null && suggestion.image!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(suggestion.image!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: primaryLightColor,
          ),
          child: suggestion.image == null || suggestion.image!.isEmpty
              ? Icon(
                  Icons.school,
                  size: 20,
                  color: primaryColor,
                )
              : null,
        );
      case 'instructor':
        return CircleAvatar(
          radius: 20,
          backgroundImage: suggestion.image != null && suggestion.image!.isNotEmpty
              ? NetworkImage(suggestion.image!)
              : null,
          backgroundColor: secondaryLightColor,
          child: suggestion.image == null || suggestion.image!.isEmpty
              ? Icon(
                  Icons.person,
                  size: 20,
                  color: secondaryColor,
                )
              : null,
        );
      case 'category':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tertiaryLightColor,
          ),
          child: Icon(
            suggestion.icon != null && suggestion.icon!.isNotEmpty
                ? _getIconFromString(suggestion.icon!)
                : Icons.folder,
            size: 20,
            color: tertiaryColor,
          ),
        );
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          ),
          child: Icon(
            Icons.search,
            size: 20,
            color: isDark ? Colors.grey[500]! : Colors.grey[400]!,
          ),
        );
    }
  }

  Widget _buildNoResults(bool isDark, Color textSecondaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
            const SizedBox(height: 8),
            Text(
              'No results found for "${widget.searchQuery}"',
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'folder':
        return Icons.folder;
      case 'folder_open':
        return Icons.folder_open;
      case 'book':
        return Icons.book;
      case 'school':
        return Icons.school;
      case 'science':
        return Icons.science;
      case 'computer':
        return Icons.computer;
      case 'music_note':
        return Icons.music_note;
      case 'sports':
        return Icons.sports;
      case 'art_track':
        return Icons.art_track;
      case 'business':
        return Icons.business;
      case 'code':
        return Icons.code;
      case 'design_services':
        return Icons.design_services;
      case 'business_center':
        return Icons.business_center;
      case 'campaign':
        return Icons.campaign;
      case 'photo_camera':
        return Icons.photo_camera;
      default:
        return Icons.folder;
    }
  }
}