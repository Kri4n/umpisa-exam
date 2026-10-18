import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_page.dart';
import '../providers/task_providers.dart';

/// Tasks across all projects, or scoped to one when [projectId] is set.
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key, this.projectId, this.title = 'Tasks'});

  final String? projectId;
  final String title;

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  late TaskFilter _filter = TaskFilter(projectId: widget.projectId);
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _filter = _filter.withSearch(value.trim()));
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _complete(Task task) async {
    final result = await ref.read(completeTaskUseCaseProvider)(task.id);
    if (!mounted) return;
    result.fold<void>((f) => _showError(f.message), (_) => refreshAfterTaskChange(ref));
  }

  Future<void> _delete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await ref.read(deleteTaskUseCaseProvider)(task.id);
    if (!mounted) return;
    result.fold<void>((f) => _showError(f.message), (_) => refreshAfterTaskChange(ref));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider(_filter));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/new', extra: widget.projectId),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search tasks by title',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          _ChipRow<TaskStatus>(
            options: const <String, TaskStatus?>{
              'All': null,
              'Pending': TaskStatus.pending,
              'In progress': TaskStatus.inProgress,
              'Completed': TaskStatus.completed,
            },
            selected: _filter.status,
            onSelected: (v) => setState(() => _filter = _filter.withStatus(v)),
          ),
          _ChipRow<TaskPriority>(
            options: const <String, TaskPriority?>{
              'Any priority': null,
              'Low': TaskPriority.low,
              'Medium': TaskPriority.medium,
              'High': TaskPriority.high,
            },
            selected: _filter.priority,
            onSelected: (v) => setState(() => _filter = _filter.withPriority(v)),
          ),
          Expanded(
            child: AsyncValueView<TaskPage>(
              value: tasks,
              onRetry: () => ref.invalidate(tasksProvider),
              data: (page) {
                if (page.items.isEmpty) {
                  return const Center(child: Text('No tasks found'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(tasksProvider);
                    await ref.read(tasksProvider(_filter).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: page.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => _TaskTile(
                      task: page.items[i],
                      onComplete: () => _complete(page.items[i]),
                      onEdit: () => context.push('/tasks/${page.items[i].id}/edit'),
                      onDelete: () => _delete(page.items[i]),
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

class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({required this.options, required this.selected, required this.onSelected});

  final Map<String, T?> options;
  final T? selected;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final entry in options.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.key),
                selected: selected == entry.value,
                onSelected: (_) => onSelected(entry.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _priorityColor(BuildContext context) => switch (task.priority) {
        TaskPriority.high => Theme.of(context).colorScheme.error,
        TaskPriority.medium => Colors.orange,
        TaskPriority.low => Colors.green,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = task.dueDate;

    final details = <String>[
      if (task.projectName != null) task.projectName!,
      task.status.label,
      if (due != null) 'Due ${formatDate(due)}',
    ];

    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        // Completed tasks can't be un-completed from here (use the edit form)
        onChanged: task.isCompleted ? null : (_) => onComplete(),
      ),
      title: Text(
        task.title,
        style: task.isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(
        details.join(' • '),
        style: task.isOverdue ? TextStyle(color: theme.colorScheme.error) : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 18, color: _priorityColor(context)),
          PopupMenuButton<String>(
            onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
