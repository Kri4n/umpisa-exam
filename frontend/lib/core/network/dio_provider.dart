import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';
import 'session_expired.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      readToken: () => ref.read(tokenStorageProvider).read(),
      onUnauthorized: () => ref.read(sessionExpiredProvider.notifier).trigger(),
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestHeader: false, responseHeader: false));
  }

  return dio;
});
