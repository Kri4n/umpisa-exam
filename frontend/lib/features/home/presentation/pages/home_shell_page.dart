import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shell around the Dashboard / Projects / Tasks tabs.
class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
        ],
      ),
    );
  }
}
