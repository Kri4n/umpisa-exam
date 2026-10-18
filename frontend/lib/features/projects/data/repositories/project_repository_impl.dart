import '../../../../core/utils/result.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl(this._remote);

  final ProjectRemoteDataSource _remote;

  @override
  Future<Result<List<Project>>> getProjects({
    ProjectFilter filter = ProjectFilter.active,
    String? search,
  }) {
    final archived = switch (filter) {
      ProjectFilter.active => 'false',
      ProjectFilter.archived => 'true',
      ProjectFilter.all => 'all',
    };
    return runCatching<List<Project>>(
      () => _remote.getProjects(archived: archived, search: search),
    );
  }

  @override
  Future<Result<Project>> getProject(String id) =>
      runCatching<Project>(() => _remote.getProject(id));

  @override
  Future<Result<Project>> createProject({required String name, String description = ''}) =>
      runCatching<Project>(
        () => _remote.createProject(name: name, description: description),
      );

  @override
  Future<Result<Project>> updateProject(
    String id, {
    String? name,
    String? description,
    bool? archived,
  }) {
    return runCatching<Project>(
      () => _remote.updateProject(id, {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (archived != null) 'archived': archived,
      }),
    );
  }
}
