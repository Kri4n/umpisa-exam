/// Thrown by the data layer (data sources). Repositories convert these to [Failure]s.
class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Cannot reach the server. Check your connection.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Your session has expired. Please sign in again.'])
      : super(statusCode: 401);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {this.fieldErrors = const {}})
      : super(statusCode: 400);

  final Map<String, List<String>> fieldErrors;
}
