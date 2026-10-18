import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/task.dart';
import '../entities/task_input.dart';
import '../repositories/task_repository.dart';

class UpdateTaskParams {
  const UpdateTaskParams({required this.id, required this.input});

  final String id;
  final TaskInput input;
}

class UpdateTask implements UseCase<Task, UpdateTaskParams> {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<Task>> call(UpdateTaskParams params) =>
      _repository.updateTask(params.id, params.input);
}
