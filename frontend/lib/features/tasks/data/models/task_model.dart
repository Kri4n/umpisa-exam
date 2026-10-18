import '../../domain/entities/task.dart';
import '../../domain/entities/task_page.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.projectName,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    required super.dueDate,
    required super.isOverdue,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final project = json['project'] as Map<String, dynamic>?;
    final due = json['dueDate'] as String?;

    return TaskModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      projectName: project?['name'] as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: TaskStatus.fromApi(json['status'] as String),
      priority: TaskPriority.fromApi(json['priority'] as String),
      dueDate: due == null ? null : DateTime.parse(due).toLocal(),
      isOverdue: json['isOverdue'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}

class TaskPageModel extends TaskPage {
  const TaskPageModel({
    required super.items,
    required super.page,
    required super.total,
    required super.totalPages,
  });

  /// [body] is the full response: { data: [...], pagination: {...} }
  factory TaskPageModel.fromJson(Map<String, dynamic> body) {
    final pagination = body['pagination'] as Map<String, dynamic>;
    return TaskPageModel(
      items: (body['data'] as List<dynamic>)
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (pagination['page'] as num).toInt(),
      total: (pagination['total'] as num).toInt(),
      totalPages: (pagination['totalPages'] as num).toInt(),
    );
  }
}
