// lib/config/app_config.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // --- API base URL ---
  static String get _host {
    if (kIsWeb) {
      return 'localhost';
    }
    if (Platform.isAndroid) {
      return '192.168.1.10';
    }
    if (Platform.isIOS) {
      return '192.168.1.10';
    }
    return '192.168.1.10';
  }

  static String get _port => '3000';
  
  static String get apiBaseUrl => 'http://$_host:$_port/api';
  static String get authBaseUrl => '$apiBaseUrl/auth';
  static String get googleAuthUrl => '$authBaseUrl/google';
  static String get googleCallbackUrl => '$apiBaseUrl/auth/google/callback';

  static const String googleWebClientId =
      '743824025812-73jkos8mjp03muupgkuj9h24p4chh7hk.apps.googleusercontent.com';

  static const String googleAndroidClientId =
      '743824025812-jvsj6lh60uuedh2hrcooq4a8h1loi5ls.apps.googleusercontent.com';

  static String get currentFrontendUrl {
    return 'http://$_host:$_port';
  }

  static String get webUrl => 'http://$_host:$_port';

  static void printConfig() {
    print('=== AppConfig ===');
    print('Platform: ${kIsWeb ? "Web" : "Native"}');
    print('Host: $_host');
    print('API Base URL: $apiBaseUrl');
    print('Current Frontend URL: $currentFrontendUrl');
    print('Google Client ID: $googleWebClientId');
    print('================');
  }
}