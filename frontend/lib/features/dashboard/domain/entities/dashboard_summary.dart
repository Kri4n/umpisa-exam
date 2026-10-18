import 'package:equatable/equatable.dart';

import '../../../projects/domain/entities/project.dart';
import '../../../tasks/domain/entities/task.dart';

class TaskStats extends Equatable {
  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.inProgress,
    required this.overdue,
  });

  final int total;
  final int completed;
  final int pending;
  final int inProgress;

  /// Not completed and past due; can overlap with pending / inProgress.
  final int overdue;

  @override
  List<Object?> get props => [total, completed, pending, inProgress, overdue];
}

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalProjects,
    required this.taskStats,
    required this.recentProjects,
    required this.upcomingDeadlines,
  });

  final int totalProjects;
  final TaskStats taskStats;
  final List<Project> recentProjects;
  final List<Task> upcomingDeadlines;

  @override
  List<Object?> get props => [totalProjects, taskStats, recentProjects, upcomingDeadlines];
}
