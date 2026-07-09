// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/search/search_results.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
      _performSearch();
    }
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      setState(() => _isSearching = true);
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      searchProvider.search(query: query);
      setState(() => _isSearching = false);
    }
  }

  void _onSuggestionSelected(String suggestion) {
    _controller.text = suggestion;
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: const InputDecoration(
              hintText: 'Search courses, instructors...',
              hintStyle: TextStyle(fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              searchProvider.clearResults();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _performSearch,
          ),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : searchProvider.searchResults != null
              ? SearchResultsWidget(
                  results: searchProvider.searchResults!,
                  onCourseTap: (id) {
                    // Navigate to course detail
                    Navigator.pushNamed(
                      context,
                      '/course-detail',
                      arguments: id,
                    );
                  },
                  onInstructorTap: (id) {
                    // Navigate to instructor profile
                    Navigator.pushNamed(
                      context,
                      '/instructor-profile',
                      arguments: id,
                    );
                  },
                  onCategoryTap: (id) {
                    // Navigate to category
                    Navigator.pushNamed(
                      context,
                      '/category',
                      arguments: id,
                    );
                  },
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Search for courses, instructors, and more',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}