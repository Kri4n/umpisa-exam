import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/task.dart';
import '../entities/task_input.dart';
import '../repositories/task_repository.dart';

class CreateTask implements UseCase<Task, TaskInput> {
  const CreateTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<Task>> call(TaskInput params) => _repository.createTask(params);
}
