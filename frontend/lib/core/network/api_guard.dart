import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Wraps a Dio call and converts [DioException]s into [AppException]s.
Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw _toException(e);
  }
}

AppException _toException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    default:
      break;
  }

  final status = e.response?.statusCode;
  final body = e.response?.data;
  final message = body is Map && body['message'] is String
      ? body['message'] as String
      : (e.message ?? 'Something went wrong');

  if (status == 401) return UnauthorizedException(message);

  if (status == 400) {
    final fieldErrors = <String, List<String>>{};
    final raw = body is Map ? body['errors'] : null;
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          fieldErrors[key.toString()] = value.map((v) => v.toString()).toList();
        }
      });
    }
    return ValidationException(message, fieldErrors: fieldErrors);
  }

  return ServerException(message, statusCode: status);
}
