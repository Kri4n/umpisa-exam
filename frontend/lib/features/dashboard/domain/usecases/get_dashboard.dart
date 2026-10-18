import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboard implements UseCase<DashboardSummary, NoParams> {
  const GetDashboard(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Result<DashboardSummary>> call(NoParams params) => _repository.getDashboard();
}
