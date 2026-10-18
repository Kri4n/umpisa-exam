import 'package:dio/dio.dart';

import '../../../../core/network/api_guard.dart';
import '../../../../core/network/api_response.dart';
import '../models/user_model.dart';

typedef LoginResponse = ({String token, UserModel user});

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /auth/login
  Future<LoginResponse> login({required String email, required String password}) {
    return guardApi(() async {
      final res = await _dio.post<dynamic>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = res.dataMap;
      return (
        token: data['token'] as String,
        user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      );
    });
  }
}
