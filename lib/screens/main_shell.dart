import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/task_actions.dart';
import 'completed_tasks_screen.dart';
import 'profile_screen.dart';
import 'task_home_screen.dart';
import 'tasks_screen.dart';

/// Hosts the Home, Tasks, Completed and Profile tabs behind a floating pill
/// dock with an amber add button in the middle.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _homeTab = 0;
  static const _profileTab = 3;
  int _index = _homeTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // Tabs stay mounted so scroll position and unsaved profile edits survive.
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: [
              TaskHomePage(
                onOpenProfile: () => setState(() => _index = _profileTab),
              ),
              const TasksScreen(),
              const CompletedTasksScreen(embedded: true),
              ProfileScreen(
                embedded: true,
                onSaved: () => setState(() => _index = _homeTab),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 14,
            child: _Dock(
              index: _index,
              onSelect: (value) => setState(() => _index = value),
              onAdd: () => openTaskEditor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  const _Dock({
    required this.index,
    required this.onSelect,
    required this.onAdd,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(33),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(33),
            border: Border.all(color: colors.border),
            color: dark
                ? const Color(0xCC322E26)
                : Colors.white.withValues(alpha: 0.9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavButton(
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                selected: index == 0,
                onTap: () => onSelect(0),
              ),
              _NavButton(
                label: 'Tasks',
                icon: Icons.checklist_rounded,
                selected: index == 1,
                onTap: () => onSelect(1),
              ),
              Semantics(
                button: true,
                label: 'Add task',
                child: Tooltip(
                  message: 'Add task',
                  child: GestureDetector(
                    key: const Key('dock-add'),
                    onTap: onAdd,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.header,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 28,
                        color: AppColors.onHeader,
                      ),
                    ),
                  ),
                ),
              ),
              _NavButton(
                label: 'Completed',
                icon: Icons.check_circle_outline_rounded,
                selectedIcon: Icons.check_circle_rounded,
                selected: index == 2,
                onTap: () => onSelect(2),
              ),
              _NavButton(
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                selected: index == 3,
                onTap: () => onSelect(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Amber text is unreadable on the light dock, so use ink there.
    final active = Theme.of(context).brightness == Brightness.dark
        ? colors.accent
        : colors.text;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? active : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              selected ? (selectedIcon ?? icon) : icon,
              size: 23,
              color: selected ? active : colors.text,
            ),
          ),
        ),
      ),
    );
  }
}
