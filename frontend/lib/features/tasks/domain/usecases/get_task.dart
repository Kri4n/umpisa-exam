import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Params: the task id.
class GetTask implements UseCase<Task, String> {
  const GetTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<Task>> call(String id) => _repository.getTask(id);
}
