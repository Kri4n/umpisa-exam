import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_store.dart';

class TokenStorage {
  TokenStorage(this._store);

  final SecureStore _store;
  static const _key = 'auth_token';

  Future<String?> read() => _store.read(_key);
  Future<void> save(String token) => _store.write(_key, token);
  Future<void> clear() => _store.delete(_key);
}

final tokenStorageProvider =
    Provider<TokenStorage>((ref) => TokenStorage(ref.watch(secureStoreProvider)));
