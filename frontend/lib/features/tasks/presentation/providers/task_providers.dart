import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_page.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/complete_task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';

// ---- dependency injection ----------------------------------------------

final taskRemoteDataSourceProvider =
    Provider((ref) => TaskRemoteDataSource(ref.watch(dioProvider)));

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(ref.watch(taskRemoteDataSourceProvider)),
);

final getTasksUseCaseProvider =
    Provider((ref) => GetTasks(ref.watch(taskRepositoryProvider)));
final getTaskUseCaseProvider =
    Provider((ref) => GetTask(ref.watch(taskRepositoryProvider)));
final createTaskUseCaseProvider =
    Provider((ref) => CreateTask(ref.watch(taskRepositoryProvider)));
final updateTaskUseCaseProvider =
    Provider((ref) => UpdateTask(ref.watch(taskRepositoryProvider)));
final completeTaskUseCaseProvider =
    Provider((ref) => CompleteTask(ref.watch(taskRepositoryProvider)));
final deleteTaskUseCaseProvider =
    Provider((ref) => DeleteTask(ref.watch(taskRepositoryProvider)));

// ---- state -------------------------------------------------------------

/// One page of tasks for a given filter. Invalidate to refetch.
final tasksProvider = FutureProvider.autoDispose
    .family<TaskPage, TaskFilter>((ref, filter) async {
  final result = await ref.watch(getTasksUseCaseProvider)(filter);
  return result.getOrThrow();
});

/// A single task, used to pre-fill the edit form.
final taskDetailProvider =
    FutureProvider.autoDispose.family<Task, String>((ref, id) async {
  final result = await ref.watch(getTaskUseCaseProvider)(id);
  return result.getOrThrow();
});

/// Call after any task change: task counts / progress on other screens are now stale.
void refreshAfterTaskChange(WidgetRef ref) {
  ref.invalidate(tasksProvider);
  ref.invalidate(projectsProvider);
  ref.invalidate(dashboardProvider);
}
