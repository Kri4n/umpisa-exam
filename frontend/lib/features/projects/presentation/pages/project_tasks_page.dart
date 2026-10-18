import 'package:flutter/material.dart';

import '../../../tasks/presentation/pages/tasks_page.dart';

/// Opening a project shows the tasks screen scoped to that project.
class ProjectTasksPage extends StatelessWidget {
  const ProjectTasksPage({super.key, required this.projectId, this.projectName});

  final String projectId;
  final String? projectName;

  @override
  Widget build(BuildContext context) {
    return TasksPage(projectId: projectId, title: projectName ?? 'Project tasks');
  }
}
