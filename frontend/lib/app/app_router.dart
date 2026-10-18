import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/home/presentation/pages/home_shell_page.dart';
import '../features/projects/presentation/pages/project_tasks_page.dart';
import '../features/projects/presentation/pages/projects_page.dart';
import '../features/tasks/presentation/pages/task_form_page.dart';
import '../features/tasks/presentation/pages/tasks_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run `redirect` whenever the auth state changes
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => refresh.value++);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      // Still restoring the stored session
      if (auth.isLoading) return location == '/splash' ? null : '/splash';

      final signedIn = auth.valueOrNull != null;
      if (!signedIn) return location == '/login' ? null : '/login';
      if (location == '/login' || location == '/splash') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShellPage(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/projects',
              builder: (_, __) => const ProjectsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => ProjectTasksPage(
                    projectId: state.pathParameters['id']!,
                    projectName: state.extra as String?,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tasks', builder: (_, __) => const TasksPage()),
          ]),
        ],
      ),
      // Full-screen forms (outside the bottom-nav shell)
      GoRoute(
        path: '/tasks/new',
        builder: (_, state) => TaskFormPage(projectId: state.extra as String?),
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        builder: (_, state) => TaskFormPage(taskId: state.pathParameters['id']),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
