import 'package:equatable/equatable.dart';

enum TaskStatus {
  pending('pending', 'Pending'),
  inProgress('in_progress', 'In progress'),
  completed('completed', 'Completed');

  const TaskStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TaskStatus fromApi(String value) =>
      values.firstWhere((s) => s.apiValue == value, orElse: () => TaskStatus.pending);
}

enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  const TaskPriority(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TaskPriority fromApi(String value) =>
      values.firstWhere((p) => p.apiValue == value, orElse: () => TaskPriority.medium);
}

class Task extends Equatable {
  const Task({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.isOverdue,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String? projectName;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isOverdue;
  final DateTime createdAt;

  bool get isCompleted => status == TaskStatus.completed;

  @override
  List<Object?> get props => [
        id, projectId, projectName, title, description,
        status, priority, dueDate, isOverdue, createdAt,
      ];
}
