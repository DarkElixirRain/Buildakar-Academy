class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(success: true, data: data, message: message);
  }

  factory ApiResponse.error(String error, {String? message}) {
    return ApiResponse<T>(success: false, error: error, message: message);
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    try {
      if (json['success'] == true) {
        final data = json['data'] != null ? fromJson(json['data']) : null;
        return ApiResponse.success(data as T, message: json['message']);
      }
      return ApiResponse.error(
        json['message'] ?? 'Unknown error',
        message: json['message'],
      );
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }
}
