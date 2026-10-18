import '../error/exceptions.dart';
import '../error/failures.dart';

/// Either a [Success] with data or an [Err] with a [Failure].
sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) =>
      switch (this) {
        Success<T>(:final data) => onSuccess(data),
        Err<T>(:final failure) => onFailure(failure),
      };

  /// Returns the data, or throws the [Failure] (handy inside FutureProviders / notifiers).
  T getOrThrow() => switch (this) {
        Success<T>(:final data) => data,
        Err<T>(:final failure) => throw failure,
      };
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Runs [action] and converts data-layer exceptions into a [Failure].
Future<Result<T>> runCatching<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on ValidationException catch (e) {
    return Err(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
  } on UnauthorizedException catch (e) {
    return Err(UnauthorizedFailure(e.message));
  } on NetworkException catch (e) {
    return Err(NetworkFailure(e.message));
  } on AppException catch (e) {
    return Err(ServerFailure(e.message, statusCode: e.statusCode));
  } catch (e) {
    return Err(UnexpectedFailure(e.toString()));
  }
}
