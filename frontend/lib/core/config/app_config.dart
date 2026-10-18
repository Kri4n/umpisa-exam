import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const _apiPrefix = '/api/v1';

  /// Override at run time:
  ///   flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1
  static const _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    // The Android emulator reaches the host machine through 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000$_apiPrefix';
    }
    return 'http://localhost:3000$_apiPrefix';
  }
}
