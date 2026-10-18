import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard.dart';

final dashboardRemoteDataSourceProvider =
    Provider((ref) => DashboardRemoteDataSource(ref.watch(dioProvider)));

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider)),
);

final getDashboardUseCaseProvider =
    Provider((ref) => GetDashboard(ref.watch(dashboardRepositoryProvider)));

/// Dashboard data. Invalidate to refetch.
final dashboardProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final result = await ref.watch(getDashboardUseCaseProvider)(const NoParams());
  return result.getOrThrow();
});
