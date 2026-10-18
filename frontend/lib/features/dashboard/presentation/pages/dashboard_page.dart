import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(user == null ? 'Dashboard' : 'Hi, ${user.name}'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: AsyncValueView<DashboardSummary>(
        value: dashboard,
        onRetry: () => ref.invalidate(dashboardProvider),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            await ref.read(dashboardProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatsGrid(data: data),
              const SizedBox(height: 24),
              const _SectionTitle('Recent projects'),
              if (data.recentProjects.isEmpty)
                const _Empty('No projects yet')
              else
                for (final p in data.recentProjects)
                  Card(
                    child: ListTile(
                      title: Text(p.name),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(value: p.progress / 100),
                            const SizedBox(height: 4),
                            Text(
                                '${p.completedCount}/${p.taskCount} tasks • ${p.progress}%'),
                          ],
                        ),
                      ),
                      onTap: () =>
                          context.go('/projects/${p.id}', extra: p.name),
                    ),
                  ),
              const SizedBox(height: 24),
              const _SectionTitle('Upcoming deadlines'),
              if (data.upcomingDeadlines.isEmpty)
                const _Empty('Nothing due soon')
              else
                for (final t in data.upcomingDeadlines)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(t.title),
                      subtitle: Text([
                        if (t.projectName != null) t.projectName!,
                        if (t.dueDate != null) 'Due ${formatDate(t.dueDate!)}',
                      ].join(' • ')),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.data});

  final DashboardSummary data;

  @override
  Widget build(BuildContext context) {
    final stats = data.taskStats;
    final error = Theme.of(context).colorScheme.error;

    final cards = [
      _StatCard(label: 'Projects', value: data.totalProjects),
      _StatCard(label: 'Tasks', value: stats.total),
      _StatCard(label: 'Completed', value: stats.completed),
      _StatCard(label: 'Pending', value: stats.pending + stats.inProgress),
      _StatCard(
        label: 'Overdue',
        value: stats.overdue,
        color: stats.overdue > 0 ? error : null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.color});

  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$value',
                style: theme.textTheme.headlineMedium?.copyWith(color: color)),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12), child: Text(text));
}
