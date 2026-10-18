import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this.remote, required this.local});

  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  @override
  Future<Result<User>> login({required String email, required String password}) {
    return runCatching<User>(() async {
      final session = await remote.login(email: email, password: password);
      await local.saveSession(token: session.token, user: session.user);
      return session.user;
    });
  }

  @override
  Future<Result<User?>> restoreSession() => runCatching<User?>(local.getSessionUser);

  @override
  Future<Result<void>> logout() => runCatching<void>(local.clear);
}
