import 'dart:convert';

import '../../../../core/storage/secure_store.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource({required TokenStorage tokens, required SecureStore store})
      : _tokens = tokens,
        _store = store;

  final TokenStorage _tokens;
  final SecureStore _store;

  static const _userKey = 'auth_user';

  Future<void> saveSession({required String token, required UserModel user}) async {
    await _tokens.save(token);
    await _store.write(_userKey, jsonEncode(user.toJson()));
  }

  /// The stored user, or `null` when there is no complete session.
  Future<UserModel?> getSessionUser() async {
    final token = await _tokens.read();
    final raw = await _store.read(_userKey);
    if (token == null || raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clear() async {
    await _tokens.clear();
    await _store.delete(_userKey);
  }
}
