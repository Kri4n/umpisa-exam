import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.readToken, required this.onUnauthorized});

  final Future<String?> Function() readToken;
  final void Function() onUnauthorized;

  static const _publicPaths = ['/auth/login'];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isPublic = _publicPaths.any(err.requestOptions.path.endsWith);
    if (err.response?.statusCode == 401 && !isPublic) {
      onUnauthorized();
    }
    handler.next(err);
  }
}
