import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/task_filter.dart';
import '../entities/task_page.dart';
import '../repositories/task_repository.dart';

class GetTasks implements UseCase<TaskPage, TaskFilter> {
  const GetTasks(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<TaskPage>> call(TaskFilter params) => _repository.getTasks(params);
}
