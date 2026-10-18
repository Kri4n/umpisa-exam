import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_input.dart';
import '../../domain/usecases/update_task.dart';
import '../providers/task_providers.dart';

/// Create (taskId == null) or edit a task.
class TaskFormPage extends ConsumerWidget {
  const TaskFormPage({super.key, this.taskId, this.projectId});

  /// `null` = create mode.
  final String? taskId;

  /// Pre-selected project when creating from a project screen.
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = taskId;
    final title = id == null ? 'New task' : 'Edit task';

    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: _TaskForm(initialProjectId: projectId),
      );
    }

    // Edit mode: load the task first, then show the form pre-filled
    final task = ref.watch(taskDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AsyncValueView<Task>(
        value: task,
        onRetry: () => ref.invalidate(taskDetailProvider(id)),
        data: (t) => _TaskForm(task: t),
      ),
    );
  }
}

class _TaskForm extends ConsumerStatefulWidget {
  const _TaskForm({this.task, this.initialProjectId});

  final Task? task;
  final String? initialProjectId;

  @override
  ConsumerState<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<_TaskForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title =
      TextEditingController(text: widget.task?.title);
  late final TextEditingController _description =
      TextEditingController(text: widget.task?.description);

  late String? _projectId = widget.task?.projectId ?? widget.initialProjectId;
  late TaskStatus _status = widget.task?.status ?? TaskStatus.pending;
  late TaskPriority _priority = widget.task?.priority ?? TaskPriority.medium;
  late DateTime? _dueDate = widget.task?.dueDate;

  bool _saving = false;
  String? _error;
  Map<String, List<String>> _serverErrors = {};

  bool get _isEdit => widget.task != null;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _serverError(String field) => _serverErrors[field]?.first;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    // End of day, so a task due "today" isn't overdue until the day is over
    setState(() =>
        _dueDate = DateTime(picked.year, picked.month, picked.day, 23, 59));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
      _error = null;
      _serverErrors = {};
    });

    final input = TaskInput(
      projectId: _projectId!,
      title: _title.text.trim(),
      description: _description.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _dueDate,
    );

    final task = widget.task;
    final result = task == null
        ? await ref.read(createTaskUseCaseProvider)(input)
        : await ref.read(updateTaskUseCaseProvider)(
            UpdateTaskParams(id: task.id, input: input),
          );
    if (!mounted) return;

    switch (result) {
      case Success():
        refreshAfterTaskChange(ref);
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/tasks');
        }
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.message;
          _serverErrors =
              failure is ValidationFailure ? failure.fieldErrors : {};
        });
    }
  }

  Widget _projectField(List<Project> projects) {
    final originalProjectId = widget.task?.projectId;
    final hasUsableProject = projects.any((p) => !p.archived);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: projects.any((p) => p.id == _projectId) ? _projectId : null,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Project',
            errorText: _serverError('projectId'),
          ),
          items: [
            for (final p in projects)
              DropdownMenuItem<String>(
                value: p.id,
                // Tasks can't be added to / moved into archived projects
                enabled: !p.archived || p.id == originalProjectId,
                child: Text(
                  p.archived ? '${p.name} (archived)' : p.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => _projectId = value),
          validator: (value) => value == null ? 'Select a project' : null,
        ),
        if (!hasUsableProject)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
                'No active projects. Create a project first from the Projects tab.'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = ref.watch(projectsProvider(ProjectFilter.all));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _title,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: 'Title', errorText: _serverError('title')),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Title is required';
              if (value.length > 200)
                return 'Title must be 200 characters or less';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _description,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              alignLabelWithHint: true,
              errorText: _serverError('description'),
            ),
            validator: (v) => (v?.trim().length ?? 0) > 2000
                ? 'Description must be 2000 characters or less'
                : null,
          ),
          const SizedBox(height: 16),
          projects.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            ),
            error: (error, _) => Row(
              children: [
                Expanded(
                  child: Text(
                    errorMessage(error),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(projectsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
            data: _projectField,
          ),
          const SizedBox(height: 20),
          _ChoiceField<TaskPriority>(
            label: 'Priority',
            options: TaskPriority.values,
            selected: _priority,
            labelOf: (p) => p.label,
            onSelected: (v) => setState(() => _priority = v),
          ),
          const SizedBox(height: 20),
          _ChoiceField<TaskStatus>(
            label: 'Status',
            options: TaskStatus.values,
            selected: _status,
            labelOf: (s) => s.label,
            onSelected: (v) => setState(() => _status = v),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Due date',
                errorText: _serverError('dueDate'),
                suffixIcon: _dueDate == null
                    ? const Icon(Icons.calendar_today)
                    : IconButton(
                        tooltip: 'Clear due date',
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dueDate = null),
                      ),
              ),
              child: Text(
                  _dueDate == null ? 'No due date' : formatDate(_dueDate!)),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEdit ? 'Save changes' : 'Create task'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceField<T> extends StatelessWidget {
  const _ChoiceField({
    required this.label,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String label;
  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(labelOf(option)),
                selected: option == selected,
                onSelected: (_) => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}
