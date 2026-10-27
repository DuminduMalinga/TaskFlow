import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_task_screen.dart';
import 'completed_tasks_screen.dart';
import 'edit_task_screen.dart';
import '../models/task.dart';
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
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
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
                  ? const SliverToBoxAdapter(child: _EmptyState())
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openTaskEditor,
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 4,
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
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search tasks',
              prefixIcon: Icon(Icons.search_rounded),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        PopupMenuButton<TaskSort>(
          tooltip: 'Sort tasks',
          icon: const Icon(Icons.sort_rounded, color: navy),
          initialValue: sort,
          onSelected: onSortChanged,
          itemBuilder: (_) => [
            for (final option in TaskSort.values)
              PopupMenuItem(value: option, child: Text(option.label)),
          ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Alex',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: navy,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dateLabel,
                style: const TextStyle(
                  color: muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: navy.withAlpha(35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  completed == total && total > 0
                      ? 'All done for today!'
                      : '$completed of $total tasks completed',
                  style: const TextStyle(
                    color: Color(0xFFB8C6E5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withAlpha(35),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF60A5FA),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 66,
            height: 66,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withAlpha(25),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF60A5FA),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
        _Stat(value: total, label: 'Total'),
        const SizedBox(width: 10),
        _Stat(value: completed, label: 'Completed', accent: true),
        const SizedBox(width: 10),
        _Stat(value: remaining, label: 'Remaining'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.accent = false});

  final int value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: accent ? blue : navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
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
        color: const Color(0xFFEEF1F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _FilterTab(
            label: 'All tasks',
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
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: navy.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? navy : muted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: task.isCompleted ? muted : navy,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TaskCheckbox(value: task.isCompleted, onTap: onToggle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: titleStyle),
                const SizedBox(height: 5),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Edit task',
            icon: const Icon(Icons.edit_outlined, size: 19),
            color: muted,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Delete task',
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: muted,
            visualDensity: VisualDensity.compact,
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
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: value ? blue : Colors.white,
            border: Border.all(
              color: value ? blue : const Color(0xFFB7C0D1),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: value
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 17)
              : null,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 52),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.checklist_rounded, color: blue, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks here',
            style: TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You are all caught up.',
            style: TextStyle(color: muted, fontSize: 13),
          ),
        ],
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
