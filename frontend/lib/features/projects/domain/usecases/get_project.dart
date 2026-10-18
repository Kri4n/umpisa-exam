import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Params: the project id.
class GetProject implements UseCase<Project, String> {
  const GetProject(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Result<Project>> call(String id) => _repository.getProject(id);
}
