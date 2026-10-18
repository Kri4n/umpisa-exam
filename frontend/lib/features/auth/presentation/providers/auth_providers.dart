import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/session_expired.dart';
import '../../../../core/storage/secure_store.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/restore_session.dart';

// ---- dependency injection ----------------------------------------------

final authRemoteDataSourceProvider =
    Provider((ref) => AuthRemoteDataSource(ref.watch(dioProvider)));

final authLocalDataSourceProvider = Provider(
  (ref) => AuthLocalDataSource(
    tokens: ref.watch(tokenStorageProvider),
    store: ref.watch(secureStoreProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  ),
);

final loginUseCaseProvider = Provider((ref) => Login(ref.watch(authRepositoryProvider)));
final restoreSessionUseCaseProvider =
    Provider((ref) => RestoreSession(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider((ref) => Logout(ref.watch(authRepositoryProvider)));

// ---- session state -----------------------------------------------------

/// Holds the signed-in user (`null` = signed out). Loading while the stored
/// session is being restored at app start-up.
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Sign out automatically when the API rejects our token (401)
    ref.listen<int>(sessionExpiredProvider, (_, __) => _onSessionExpired());

    final result = await ref.read(restoreSessionUseCaseProvider)(const NoParams());
    return result.fold<User?>((_) => null, (user) => user);
  }

  void setAuthenticated(User user) => state = AsyncData(user);

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)(const NoParams());
    state = const AsyncData(null);
  }

  Future<void> _onSessionExpired() async {
    if (state.valueOrNull == null) return;
    await logout();
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);

// ---- login form state --------------------------------------------------

class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    final result = await ref.read(loginUseCaseProvider)(
      LoginParams(email: email, password: password),
    );

    switch (result) {
      case Success(:final data):
        state = const AsyncData(null);
        ref.read(authControllerProvider.notifier).setAuthenticated(data);
      case Err(:final failure):
        state = AsyncError(failure, StackTrace.current);
    }
  }
}

final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(LoginController.new);
