import '../../../../core/utils/result.dart';
import '../entities/task.dart';
import '../entities/task_filter.dart';
import '../entities/task_input.dart';
import '../entities/task_page.dart';

abstract interface class TaskRepository {
  Future<Result<TaskPage>> getTasks(TaskFilter filter);
  Future<Result<Task>> getTask(String id);
  Future<Result<Task>> createTask(TaskInput input);
  Future<Result<Task>> updateTask(String id, TaskInput input);
  Future<Result<Task>> completeTask(String id);
  Future<Result<void>> deleteTask(String id);
}
