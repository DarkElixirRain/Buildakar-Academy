class SearchSuggestion {
  final String id;
  final String type; // 'course', 'instructor', 'category'
  final String title;
  final String subtitle;
  final String? image;
  final String? icon;

  SearchSuggestion({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle = '',
    this.image,
    this.icon,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'course',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'icon': icon,
    };
  }
}