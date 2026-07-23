import 'dart:convert';

import '../models/search_results.dart';
import '../models/search_suggestion.dart';
import '../models/trending_data.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class SearchApiServiceImpl extends BaseApiService {
  Future<ApiResponse<List<SearchSuggestion>>> getSuggestions(String query) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/search/suggestions?q=${Uri.encodeComponent(query)}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final suggestions = (data['data'] as List)
              .map((item) => SearchSuggestion.fromJson(item))
              .toList();
          return ApiResponse.success(suggestions, message: data['message']);
        }
        return ApiResponse.error(data['message'] ?? 'Failed to get suggestions');
      }
      return ApiResponse.error('Failed to get suggestions');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<SearchResults>> search({
    required String query,
    String type = 'all',
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? price,
    String sortBy = 'relevance',
  }) async {
    try {
      final qParams = <String>[
        'q=${Uri.encodeComponent(query.trim())}',
        'type=$type',
        'page=$page',
        'limit=$limit',
        'sortBy=$sortBy',
      ];
      if (category != null && category.isNotEmpty) qParams.add('category=${Uri.encodeComponent(category)}');
      if (level != null && level.isNotEmpty) qParams.add('level=${Uri.encodeComponent(level)}');
      if (price != null && price.isNotEmpty) qParams.add('price=${Uri.encodeComponent(price)}');

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/search?${qParams.join('&')}',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final results = SearchResults.fromJson(data['data']);
        return ApiResponse.success(results, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Search failed');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<SearchResults>> searchByType({
    required String type,
    required String query,
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? price,
    String sortBy = 'relevance',
  }) async {
    return search(
      query: query,
      type: type,
      page: page,
      limit: limit,
      category: category,
      level: level,
      price: price,
      sortBy: sortBy,
    );
  }

  Future<ApiResponse<TrendingData>> getTrending() async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/search/trending',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final trending = TrendingData.fromJson(data['data']);
        return ApiResponse.success(trending, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to get trending');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<String>>> getRecentSearches() async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/search/recent',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final searches = (data['data'] as List).map((item) => item.toString()).toList();
        return ApiResponse.success(searches, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to get recent searches');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> saveRecentSearch(String query) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'POST',
        endpoint: '/search/recent',
        body: {'query': query.trim()},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to save recent search');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> clearRecentSearches() async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'DELETE',
        endpoint: '/search/recent',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null, message: data['message']);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to clear recent searches');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
