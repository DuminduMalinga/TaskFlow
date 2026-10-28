import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_task_screen.dart';
import 'completed_tasks_screen.dart';
import 'edit_task_screen.dart';
import 'profile_screen.dart';
import '../models/task.dart';
import '../providers/profile_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/delete_task_dialog.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          onPrimary: Colors.white,
          surface: Colors.white,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: navy,
          elevation: 0,
        ),
      ),
      home: const TaskHomePage(),
    );
  }
}

enum TaskFilter { all, active, completed }

enum TaskSort {
  newest('Newest first'),
  dueDate('Due date'),
  title('Title A–Z');

  const TaskSort(this.label);

  final String label;
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.newest;
  String _query = '';

  // Only read from build(), so watching keeps the UI in sync.
  List<Task> get _tasks => context.watch<TaskProvider>().tasks;

  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  List<Task> get _visibleTasks {
    final query = _query.trim().toLowerCase();
    final tasks = _tasks.where((task) {
      final matchesFilter = switch (_filter) {
        TaskFilter.active => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
        TaskFilter.all => true,
      };
      return matchesFilter &&
          (query.isEmpty ||
              task.title.toLowerCase().contains(query) ||
              task.description.toLowerCase().contains(query));
    }).toList();

    switch (_sort) {
      case TaskSort.newest:
        break;
      case TaskSort.dueDate:
        // Tasks without a due date go last.
        tasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case TaskSort.title:
        tasks.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }
    return tasks;
  }

  String get _dateLabel {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}\n${now.day} ${months[now.month - 1]}';
  }

  Future<void> _openTaskEditor({Task? task}) async {
    if (task == null) {
      final result = await Navigator.push<AddTaskResult>(
        context,
        MaterialPageRoute(builder: (_) => const AddTaskScreen()),
      );
      if (!mounted || result == null) return;
      context.read<TaskProvider>().addTask(
        title: result.title,
        description: result.description,
        dueDate: result.dueDate,
      );
      return;
    }

    final result = await Navigator.push<EditTaskResult>(
      context,
      MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
    );
    if (!mounted || result == null) return;
    context.read<TaskProvider>().updateTask(
      task,
      title: result.title,
      description: result.description,
      dueDate: result.dueDate,
    );
  }

  Future<void> _openCompletedTasks() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const CompletedTasksScreen()),
    );
    if (mounted) setState(() => _filter = TaskFilter.all);
  }

  Future<void> _deleteTask(Task task) async {
    final shouldDelete = await DeleteTaskDialog.show(context);
    if (shouldDelete != true || !mounted) return;
    final provider = context.read<TaskProvider>();
    final index = provider.deleteTask(task);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => provider.restoreTask(task, index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _tasks.isEmpty ? 0.0 : _completedCount / _tasks.length;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(child: _Header(dateLabel: _dateLabel)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(
                child: ProgressCard(
                  completed: _completedCount,
                  total: _tasks.length,
                  progress: progress,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _StatsRow(
                  total: _tasks.length,
                  completed: _completedCount,
                  remaining: _tasks.length - _completedCount,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: FilterTabs(
                  selected: _filter,
                  onSelected: (filter) {
                    if (filter == TaskFilter.completed) {
                      _openCompletedTasks();
                    } else {
                      setState(() => _filter = filter);
                    }
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SearchSortBar(
                  sort: _sort,
                  onQueryChanged: (value) => setState(() => _query = value),
                  onSortChanged: (value) => setState(() => _sort = value),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: _visibleTasks.isEmpty
                  ? SliverToBoxAdapter(
                      child: _EmptyState(
                        hasTasks: _tasks.isNotEmpty,
                        onAdd: _openTaskEditor,
                      ),
                    )
                  : SliverList.separated(
                      itemCount: _visibleTasks.length,
                      itemBuilder: (context, index) {
                        final task = _visibleTasks[index];
                        return TaskCard(
                          task: task,
                          onToggle: () =>
                              context.read<TaskProvider>().toggleTask(task),
                          onEdit: () => _openTaskEditor(task: task),
                          onDelete: () => _deleteTask(task),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                    ),
            ),
          ],
        ),
      ),
      // The empty state has its own "Add Your First Task" button.
      floatingActionButton: _tasks.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _openTaskEditor,
              backgroundColor: blue,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              tooltip: 'Add task',
              child: const Icon(Icons.add_rounded, size: 30),
            ),
    );
  }
}

class _SearchSortBar extends StatelessWidget {
  const _SearchSortBar({
    required this.sort,
    required this.onQueryChanged,
    required this.onSortChanged,
  });

  final TaskSort sort;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<TaskSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: border),
    );
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: navy, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search tasks',
              hintStyle: const TextStyle(color: muted, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: muted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: outline,
              enabledBorder: outline,
              focusedBorder: outline.copyWith(
                borderSide: const BorderSide(color: blue, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<TaskSort>(
          tooltip: 'Sort tasks',
          initialValue: sort,
          onSelected: onSortChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          itemBuilder: (_) => [
            for (final option in TaskSort.values)
              PopupMenuItem(value: option, child: Text(option.label)),
          ],
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: const Icon(Icons.sort_rounded, color: navy),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final photo = profile.photoBytes;
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Open profile',
          child: GestureDetector(
            key: const Key('profile-avatar'),
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(16),
                image: photo == null
                    ? null
                    : DecorationImage(
                        image: MemoryImage(photo),
                        fit: BoxFit.cover,
                      ),
              ),
              child: photo == null
                  ? Center(
                      child: Text(
                        profile.initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, ${profile.firstName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: navy,
                  fontSize: 20,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Small steps today, big wins tomorrow.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Text(
            dateLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: navy,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
    super.key,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    final remaining = total - completed;
    final caption = total == 0
        ? 'Add a task to get started'
        : remaining == 0
        ? 'All caught up. Nice work!'
        : '$remaining ${remaining == 1 ? 'task' : 'tasks'} left today';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: navy.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY PROGRESS',
                      style: TextStyle(
                        color: Colors.white.withAlpha(184),
                        fontSize: 12,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed of $total done',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      caption,
                      style: TextStyle(
                        color: Colors.white.withAlpha(184),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Semantics(
                label: '$percent percent complete',
                excludeSemantics: true,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withAlpha(41),
                        valueColor: const AlwaysStoppedAnimation<Color>(blue),
                      ),
                      Center(
                        child: Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(41),
              valueColor: const AlwaysStoppedAnimation<Color>(blue),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.total,
    required this.completed,
    required this.remaining,
  });

  final int total;
  final int completed;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(value: total, label: 'Total', icon: Icons.list_alt_rounded),
        const SizedBox(width: 12),
        _Stat(
          value: completed,
          label: 'Completed',
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(width: 12),
        _Stat(
          value: remaining,
          label: 'Remaining',
          icon: Icons.schedule_rounded,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.icon});

  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: blueTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: blue, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: const TextStyle(
                color: navy,
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterTabs extends StatelessWidget {
  const FilterTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final TaskFilter selected;
  final ValueChanged<TaskFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _FilterTab(
            label: 'All',
            selected: selected == TaskFilter.all,
            onTap: () => onSelected(TaskFilter.all),
          ),
          _FilterTab(
            label: 'Active',
            selected: selected == TaskFilter.active,
            onTap: () => onSelected(TaskFilter.active),
          ),
          _FilterTab(
            label: 'Completed',
            selected: selected == TaskFilter.completed,
            onTap: () => onSelected(TaskFilter.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? navy : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: navy.withAlpha(50),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TaskAction { edit, delete }

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static String _dueLabel(BuildContext context, DateTime due) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final date = '${months[due.month - 1]} ${due.day}';
    // Midnight means "no time set".
    if (due.hour == 0 && due.minute == 0) return date;
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(due));
    return '$date, $time';
  }

  @override
  Widget build(BuildContext context) {
    final done = task.isCompleted;
    final due = task.dueDate;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withAlpha(10),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TaskCheckbox(value: done, onTap: onToggle),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: done ? subdued : navy,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.description.isNotEmpty)
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  if (due != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _dueLabel(context, due),
                          style: const TextStyle(
                            color: muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          PopupMenuButton<_TaskAction>(
            tooltip: 'More actions',
            icon: const Icon(Icons.more_vert_rounded, color: muted),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (action) => switch (action) {
              _TaskAction.edit => onEdit(),
              _TaskAction.delete => onDelete(),
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _TaskAction.edit,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: navy),
                    SizedBox(width: 12),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _TaskAction.delete,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: danger),
                    SizedBox(width: 12),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: danger,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskCheckbox extends StatelessWidget {
  const _TaskCheckbox({required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: value ? 'Mark task as active' : 'Mark task as completed',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? blue : Colors.white,
                border: Border.all(
                  color: value ? blue : const Color(0xFF94A3B8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasTasks, required this.onAdd});

  final bool hasTasks;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (hasTasks) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: const Text(
          'No tasks here',
          style: TextStyle(color: muted, fontSize: 14),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          const _ChecklistIllustration(),
          const SizedBox(height: 16),
          const Text(
            'Your day, your progress',
            style: TextStyle(
              color: navy,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first task and start building momentum.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Your First Task'),
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistIllustration extends StatelessWidget {
  const _ChecklistIllustration();

  @override
  Widget build(BuildContext context) {
    Widget row({required bool checked, required double lineWidth}) {
      return Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: checked ? blue : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: checked
                  ? null
                  : Border.all(color: const Color(0xFF94A3B8), width: 2),
            ),
            child: checked
                ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            width: lineWidth,
            height: 8,
            decoration: BoxDecoration(
              color: checked ? const Color(0xFFC9D3EA) : border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: 'Checklist illustration',
      child: SizedBox(
        width: 96,
        height: 112,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 6,
              child: Container(
                width: 80,
                height: 104,
                padding: const EdgeInsets.fromLTRB(12, 28, 6, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC9D3EA), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    row(checked: true, lineWidth: 30),
                    const SizedBox(height: 10),
                    row(checked: false, lineWidth: 24),
                    const SizedBox(height: 10),
                    row(checked: false, lineWidth: 30),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: 32,
                height: 16,
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({this.task, super.key});

  final Task? task;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController = TextEditingController(
      text: widget.task?.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        isCompleted: widget.task?.isCompleted ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isEditing = widget.task != null;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8DDE8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing ? 'Edit task' : 'Create a new task',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  autofocus: !isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'What needs to be done?',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter a task title'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Add a little more detail',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isEditing ? 'Save changes' : 'Add task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
