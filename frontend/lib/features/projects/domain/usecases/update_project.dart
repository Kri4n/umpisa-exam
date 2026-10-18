import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class UpdateProjectParams {
  const UpdateProjectParams({required this.id, this.name, this.description, this.archived});

  final String id;
  final String? name;
  final String? description;
  final bool? archived;
}

/// Edits a project; also used to archive / unarchive it.
class UpdateProject implements UseCase<Project, UpdateProjectParams> {
  const UpdateProject(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Result<Project>> call(UpdateProjectParams params) => _repository.updateProject(
        params.id,
        name: params.name,
        description: params.description,
        archived: params.archived,
      );
}
