import '../../../../core/utils/result.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_input.dart';
import '../../domain/entities/task_page.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remote);

  final TaskRemoteDataSource _remote;

  @override
  Future<Result<TaskPage>> getTasks(TaskFilter filter) =>
      runCatching<TaskPage>(() => _remote.getTasks(filter));

  @override
  Future<Result<Task>> getTask(String id) => runCatching<Task>(() => _remote.getTask(id));

  @override
  Future<Result<Task>> createTask(TaskInput input) =>
      runCatching<Task>(() => _remote.createTask(input));

  @override
  Future<Result<Task>> updateTask(String id, TaskInput input) =>
      runCatching<Task>(() => _remote.updateTask(id, input));

  @override
  Future<Result<Task>> completeTask(String id) =>
      runCatching<Task>(() => _remote.completeTask(id));

  @override
  Future<Result<void>> deleteTask(String id) =>
      runCatching<void>(() => _remote.deleteTask(id));
}
