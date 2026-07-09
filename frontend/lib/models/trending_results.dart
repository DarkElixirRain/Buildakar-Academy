// lib/models/trending_results.dart
import 'search_results.dart';

class TrendingData {
  final List<CourseSearchResult> trendingCourses;
  final List<InstructorSearchResult> topInstructors;
  final List<CategorySearchResult> popularCategories;

  TrendingData({
    required this.trendingCourses,
    required this.topInstructors,
    required this.popularCategories,
  });

  factory TrendingData.fromJson(Map<String, dynamic> json) {
    return TrendingData(
      trendingCourses: (json['trendingCourses'] as List?)
              ?.map((item) => CourseSearchResult.fromJson(item))
              .toList() ??
          [],
      topInstructors: (json['topInstructors'] as List?)
              ?.map((item) => InstructorSearchResult.fromJson(item))
              .toList() ??
          [],
      popularCategories: (json['popularCategories'] as List?)
              ?.map((item) => CategorySearchResult.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trendingCourses': trendingCourses.map((item) => item.toJson()).toList(),
      'topInstructors': topInstructors.map((item) => item.toJson()).toList(),
      'popularCategories': popularCategories.map((item) => item.toJson()).toList(),
    };
  }
}