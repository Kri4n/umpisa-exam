import 'package:equatable/equatable.dart';

import 'task.dart';

/// Query for the tasks list. Immutable + Equatable so it can key a provider family.
class TaskFilter extends Equatable {
  const TaskFilter({
    this.projectId,
    this.status,
    this.priority,
    this.search = '',
    this.page = 1,
    this.limit = 50,
  });

  final String? projectId;
  final TaskStatus? status;
  final TaskPriority? priority;
  final String search;
  final int page;
  final int limit;

  // Explicit "with" methods so a filter can be set back to null ("All").
  TaskFilter withStatus(TaskStatus? value) => TaskFilter(
      projectId: projectId, status: value, priority: priority, search: search, limit: limit);

  TaskFilter withPriority(TaskPriority? value) => TaskFilter(
      projectId: projectId, status: status, priority: value, search: search, limit: limit);

  TaskFilter withSearch(String value) => TaskFilter(
      projectId: projectId, status: status, priority: priority, search: value, limit: limit);

  @override
  List<Object?> get props => [projectId, status, priority, search, page, limit];
}
