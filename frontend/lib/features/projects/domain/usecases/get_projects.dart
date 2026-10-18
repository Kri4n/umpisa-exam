import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjectsParams {
  const GetProjectsParams({this.filter = ProjectFilter.active, this.search});

  final ProjectFilter filter;
  final String? search;
}

class GetProjects implements UseCase<List<Project>, GetProjectsParams> {
  const GetProjects(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Result<List<Project>>> call(GetProjectsParams params) =>
      _repository.getProjects(filter: params.filter, search: params.search);
}
