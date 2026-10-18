import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/project_remote_data_source.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/usecases/create_project.dart';
import '../../domain/usecases/get_project.dart';
import '../../domain/usecases/get_projects.dart';
import '../../domain/usecases/update_project.dart';

// ---- dependency injection ----------------------------------------------

final projectRemoteDataSourceProvider =
    Provider((ref) => ProjectRemoteDataSource(ref.watch(dioProvider)));

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepositoryImpl(ref.watch(projectRemoteDataSourceProvider)),
);

final getProjectsUseCaseProvider =
    Provider((ref) => GetProjects(ref.watch(projectRepositoryProvider)));
final getProjectUseCaseProvider =
    Provider((ref) => GetProject(ref.watch(projectRepositoryProvider)));
final createProjectUseCaseProvider =
    Provider((ref) => CreateProject(ref.watch(projectRepositoryProvider)));
final updateProjectUseCaseProvider =
    Provider((ref) => UpdateProject(ref.watch(projectRepositoryProvider)));

// ---- state -------------------------------------------------------------

/// Projects list for the given filter. Invalidate to refetch.
final projectsProvider =
    FutureProvider.autoDispose.family<List<Project>, ProjectFilter>((ref, filter) async {
  final result = await ref.watch(getProjectsUseCaseProvider)(GetProjectsParams(filter: filter));
  return result.getOrThrow();
});
