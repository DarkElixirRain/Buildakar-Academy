// lib/providers/search_provider.dart

import 'package:flutter/material.dart';
import '../services/search_api_service.dart';
import '../models/search_suggestion.dart';
import '../models/search_results.dart';
import '../models/trending_data.dart';
import 'auth_provider.dart';

class SearchProvider extends ChangeNotifier {
  final SearchApiService _searchApiService = SearchApiService();
  final AuthProvider? authProvider;
  
  List<SearchSuggestion> _suggestions = [];
  List<String> _recentSearches = [];
  SearchResults? _searchResults;
  TrendingData? _trendingResults;
  bool _isLoadingSuggestions = false;
  bool _isLoadingResults = false;
  bool _isLoadingTrending = false;
  String _error = '';

  // Getters
  List<SearchSuggestion> get suggestions => _suggestions;
  List<String> get recentSearches => _recentSearches;
  SearchResults? get searchResults => _searchResults;
  TrendingData? get trendingResults => _trendingResults;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  bool get isLoadingResults => _isLoadingResults;
  bool get isLoadingTrending => _isLoadingTrending;
  String get error => _error;

  SearchProvider({this.authProvider}) {
    _loadRecentSearches();
  }

  // ============================================
  // SEARCH SUGGESTIONS (Autocomplete)
  // ============================================
  
  Future<void> getSuggestions(String query) async {
    if (query.isEmpty || query.length < 2) {
      _suggestions = [];
      _isLoadingSuggestions = false;
      notifyListeners();
      return;
    }

    _isLoadingSuggestions = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _searchApiService.getSuggestions(query);
      
      if (response.success && response.data != null) {
        _suggestions = response.data!;
        _error = '';
        print('✅ Suggestions updated: ${_suggestions.length}');
      } else {
        _error = response.error ?? 'Failed to load suggestions';
        _suggestions = [];
        print('❌ Error: $_error');
      }
    } catch (e) {
      _error = 'Error loading suggestions: $e';
      _suggestions = [];
      print('❌ Exception: $e');
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  // ============================================
  // UNIFIED SEARCH
  // ============================================
  
  Future<void> search({
    required String query,
    String type = 'all',
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? price,
    String sortBy = 'relevance',
  }) async {
    if (query.isEmpty) {
      _searchResults = null;
      notifyListeners();
      return;
    }

    _isLoadingResults = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _searchApiService.search(
        query: query,
        type: type,
        page: page,
        limit: limit,
        category: category,
        level: level,
        price: price,
        sortBy: sortBy,
      );
      
      if (response.success && response.data != null) {
        _searchResults = response.data!;
        _error = '';
        
        // Save recent search if authenticated
        if (authProvider?.isAuthenticated == true) {
          await saveRecentSearch(query);
        }
      } else {
        _error = response.error ?? 'Search failed';
        _searchResults = null;
      }
    } catch (e) {
      _error = 'Error searching: $e';
      _searchResults = null;
    } finally {
      _isLoadingResults = false;
      notifyListeners();
    }
  }

  // ============================================
  // GET TRENDING
  // ============================================
  
  Future<void> getTrending() async {
    if (_trendingResults != null) return;

    _isLoadingTrending = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _searchApiService.getTrending();
      
      if (response.success && response.data != null) {
        _trendingResults = response.data!;
        _error = '';
      } else {
        _error = response.error ?? 'Failed to load trending content';
        _trendingResults = null;
      }
    } catch (e) {
      _error = 'Error loading trending: $e';
      _trendingResults = null;
    } finally {
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  // ============================================
  // RECENT SEARCHES
  // ============================================
  
  Future<void> _loadRecentSearches() async {
    try {
      final response = await _searchApiService.getRecentSearches();
      
      if (response.success && response.data != null) {
        _recentSearches = response.data!;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  Future<void> saveRecentSearch(String query) async {
    if (query.isEmpty) return;

    try {
      final response = await _searchApiService.saveRecentSearch(query);
      
      if (response.success) {
        // Remove if exists and add to front
        _recentSearches.remove(query);
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches = _recentSearches.sublist(0, 10);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    try {
      final response = await _searchApiService.clearRecentSearches();
      
      if (response.success) {
        _recentSearches = [];
        notifyListeners();
      }
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  // ============================================
  // CLEAR RESULTS
  // ============================================
  
  void clearResults() {
    _searchResults = null;
    _suggestions = [];
    notifyListeners();
  }

  // ============================================
  // UPDATE SEARCH QUERY
  // ============================================
  
  Future<void> updateSearchQuery(String query) async {
    if (query.isEmpty) {
      _suggestions = [];
      _isLoadingSuggestions = false;
      notifyListeners();
      return;
    }
    await getSuggestions(query);
  }

  // ============================================
  // CLEAR ERROR
  // ============================================
  
  void clearError() {
    _error = '';
    notifyListeners();
  }
}