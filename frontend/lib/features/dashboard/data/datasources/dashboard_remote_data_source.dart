import 'package:dio/dio.dart';

import '../../../../core/network/api_guard.dart';
import '../../../../core/network/api_response.dart';
import '../models/dashboard_model.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /dashboard
  Future<DashboardModel> getDashboard() {
    return guardApi(() async {
      final res = await _dio.get<dynamic>('/dashboard');
      return DashboardModel.fromJson(res.dataMap);
    });
  }
}
