import '../../../../core/utils/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> login({required String email, required String password});

  /// Returns the stored user if a session exists, otherwise `null`.
  Future<Result<User?>> restoreSession();

  Future<Result<void>> logout();
}
