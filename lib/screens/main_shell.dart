import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'profile_screen.dart';
import 'task_home_screen.dart';
import 'tasks_screen.dart';

/// Hosts the Home, Tasks and Profile tabs behind a bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _homeTab = 0;
  static const _profileTab = 2;
  int _index = _homeTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tabs stay mounted so scroll position and unsaved profile edits survive.
      body: IndexedStack(
        index: _index,
        children: [
          TaskHomePage(
            onOpenProfile: () => setState(() => _index = _profileTab),
          ),
          const TasksScreen(),
          ProfileScreen(
            embedded: true,
            onSaved: () => setState(() => _index = _homeTab),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: context.colors.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: context.colors.accentTint,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? context.colors.text
                : context.colors.muted,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: context.colors.muted),
            selectedIcon: Icon(Icons.home_rounded, color: context.colors.text),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded, color: context.colors.muted),
            selectedIcon: Icon(
              Icons.checklist_rounded,
              color: context.colors.text,
            ),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
              color: context.colors.muted,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: context.colors.text,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
