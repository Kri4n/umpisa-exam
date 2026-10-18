import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/task_repository.dart';

/// Params: the task id.
class DeleteTask implements UseCase<void, String> {
  const DeleteTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteTask(id);
}
