// lib/config/app_config.dart

class AppConfig {
  static const String apiBaseUrl = 'http://192.168.1.11:3000/api';
  static const String authBaseUrl = '$apiBaseUrl/auth';
  static const String googleAuthUrl = '$authBaseUrl/google';
  static const String googleCallbackUrl = '$apiBaseUrl/auth/google/callback';

  static const String googleWebClientId =
      '743824025812-73jkos8mjp03muupgkuj9h24p4chh7hk.apps.googleusercontent.com';

  static const String googleAndroidClientId =
      '743824025812-jvsj6lh60uuedh2hrcooq4a8h1loi5ls.apps.googleusercontent.com';
}