import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class CreateProjectParams {
  const CreateProjectParams({required this.name, this.description = ''});

  final String name;
  final String description;
}

class CreateProject implements UseCase<Project, CreateProjectParams> {
  const CreateProject(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Result<Project>> call(CreateProjectParams params) =>
      _repository.createProject(name: params.name, description: params.description);
}
