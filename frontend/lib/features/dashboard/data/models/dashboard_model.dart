import '../../../projects/data/models/project_model.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardModel extends DashboardSummary {
  const DashboardModel({
    required super.totalProjects,
    required super.taskStats,
    required super.recentProjects,
    required super.upcomingDeadlines,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final tasks = json['tasks'] as Map<String, dynamic>;
    int n(String key) => (tasks[key] as num?)?.toInt() ?? 0;

    return DashboardModel(
      totalProjects: ((json['projects'] as Map<String, dynamic>)['total'] as num).toInt(),
      taskStats: TaskStats(
        total: n('total'),
        completed: n('completed'),
        pending: n('pending'),
        inProgress: n('inProgress'),
        overdue: n('overdue'),
      ),
      recentProjects: (json['recentProjects'] as List<dynamic>)
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingDeadlines: (json['upcomingDeadlines'] as List<dynamic>)
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
