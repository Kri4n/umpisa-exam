import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_value_view.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/create_project.dart';
import '../../domain/usecases/update_project.dart';
import '../providers/project_providers.dart';

class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  ProjectFilter _filter = ProjectFilter.active;

  void _refreshAll() {
    ref.invalidate(projectsProvider);
    ref.invalidate(dashboardProvider);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _create() async {
    final input = await showDialog<({String name, String description})>(
      context: context,
      builder: (_) => const _NewProjectDialog(),
    );
    if (input == null) return;

    final result = await ref.read(createProjectUseCaseProvider)(
      CreateProjectParams(name: input.name, description: input.description),
    );
    if (!mounted) return;
    result.fold<void>((failure) => _showError(failure.message), (_) => _refreshAll());
  }

  Future<void> _toggleArchive(Project project) async {
    final result = await ref.read(updateProjectUseCaseProvider)(
      UpdateProjectParams(id: project.id, archived: !project.archived),
    );
    if (!mounted) return;
    result.fold<void>((failure) => _showError(failure.message), (_) => _refreshAll());
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider(_filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('New project'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<ProjectFilter>(
              segments: const [
                ButtonSegment(value: ProjectFilter.active, label: Text('Active')),
                ButtonSegment(value: ProjectFilter.archived, label: Text('Archived')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Project>>(
              value: projects,
              onRetry: () => ref.invalidate(projectsProvider),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No projects here yet'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(projectsProvider);
                    await ref.read(projectsProvider(_filter).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _ProjectCard(
                      project: items[i],
                      onTap: () => context.push('/projects/${items[i].id}', extra: items[i].name),
                      onToggleArchive: () => _toggleArchive(items[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onToggleArchive,
  });

  final Project project;
  final VoidCallback onTap;
  final VoidCallback onToggleArchive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(project.name, style: theme.textTheme.titleMedium)),
                  PopupMenuButton<String>(
                    onSelected: (_) => onToggleArchive(),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'archive',
                        child: Text(project.archived ? 'Unarchive' : 'Archive'),
                      ),
                    ],
                  ),
                ],
              ),
              if (project.description.isNotEmpty) ...[
                Text(project.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
              ],
              LinearProgressIndicator(value: project.progress / 100),
              const SizedBox(height: 8),
              Text(
                '${project.completedCount}/${project.taskCount} tasks done • ${project.progress}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewProjectDialog extends StatefulWidget {
  const _NewProjectDialog();

  @override
  State<_NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<_NewProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New project'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Name is required';
                if (value.length > 100) return 'Max 100 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              validator: (v) => (v?.length ?? 0) > 1000 ? 'Max 1000 characters' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, (
                name: _name.text.trim(),
                description: _description.text.trim(),
              ));
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
