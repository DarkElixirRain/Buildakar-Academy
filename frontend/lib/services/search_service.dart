import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/search_results.dart';
import '../models/search_suggestion.dart';
import '../models/trending_data.dart';
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class SearchApiServiceImpl extends BaseApiService {
  Future<ApiResponse<List<SearchSuggestion>>> getSuggestions(String query) async {
    try {
      final headers = await getHeaders(requireAuth: false);
      final url = '${AppConfig.apiBaseUrl}/search/suggestions?q=${Uri.encodeComponent(query)}';
      final response = await http.get(Uri.parse(url), headers: headers);

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
      final queryParams = <String, String>{
        'q': query.trim(),
        'type': type,
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
      };

      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (level != null && level.isNotEmpty) queryParams['level'] = level;
      if (price != null && price.isNotEmpty) queryParams['price'] = price;

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/search').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await getHeaders(requireAuth: false));
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
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/search/trending'),
        headers: await getHeaders(requireAuth: false),
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
      final token = await getToken();
      if (token == null) {
        return ApiResponse.success([]);
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/search/recent'),
        headers: await getHeaders(requireAuth: true),
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
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/search/recent'),
        headers: await getHeaders(requireAuth: true),
        body: jsonEncode({'query': query.trim()}),
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
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/search/recent'),
        headers: await getHeaders(requireAuth: true),
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
