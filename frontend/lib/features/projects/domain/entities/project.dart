import 'package:equatable/equatable.dart';

enum ProjectFilter { active, archived, all }

class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.archived,
    required this.createdAt,
    required this.taskCount,
    required this.completedCount,
    required this.pendingCount,
    required this.progress,
  });

  final String id;
  final String name;
  final String description;
  final bool archived;
  final DateTime createdAt;
  final int taskCount;
  final int completedCount;
  final int pendingCount;

  /// 0–100
  final int progress;

  @override
  List<Object?> get props => [
        id, name, description, archived, createdAt,
        taskCount, completedCount, pendingCount, progress,
      ];
}
