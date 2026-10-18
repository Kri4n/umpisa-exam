import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.archived,
    required super.createdAt,
    required super.taskCount,
    required super.completedCount,
    required super.pendingCount,
    required super.progress,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        archived: json['archived'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
        completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
        pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
        progress: (json['progress'] as num?)?.toInt() ?? 0,
      );
}
