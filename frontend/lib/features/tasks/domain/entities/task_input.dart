import 'task.dart';

/// Values entered in the create / edit task form.
class TaskInput {
  const TaskInput({
    required this.projectId,
    required this.title,
    this.description = '',
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;

  /// `null` means no due date (clears it when editing).
  final DateTime? dueDate;
}
