import '../../../../core/utils/result.dart';
import '../entities/project.dart';

abstract interface class ProjectRepository {
  Future<Result<List<Project>>> getProjects({
    ProjectFilter filter = ProjectFilter.active,
    String? search,
  });

  Future<Result<Project>> getProject(String id);

  Future<Result<Project>> createProject({required String name, String description = ''});

  /// Only the non-null fields are sent. Archive a project with `archived: true`.
  Future<Result<Project>> updateProject(
    String id, {
    String? name,
    String? description,
    bool? archived,
  });
}
