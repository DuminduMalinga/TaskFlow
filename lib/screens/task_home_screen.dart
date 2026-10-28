import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'completed_tasks_screen.dart';
import '../models/task.dart';
import '../providers/profile_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/task_actions.dart';
import '../widgets/task_card.dart';

enum TaskFilter { all, active, completed }

enum TaskSort {
  newest('Newest first'),
  dueDate('Due date'),
  title('Title A–Z');

  const TaskSort(this.label);

  final String label;
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({required this.onOpenProfile, super.key});

  final VoidCallback onOpenProfile;

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

  Future<void> _openCompletedTasks() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const CompletedTasksScreen()),
    );
    if (mounted) setState(() => _filter = TaskFilter.all);
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
              sliver: SliverToBoxAdapter(
                child: _Header(
                  dateLabel: _dateLabel,
                  onOpenProfile: widget.onOpenProfile,
                ),
              ),
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
                        onAdd: () => openTaskEditor(context),
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
                          onEdit: () => openTaskEditor(context, task: task),
                          onDelete: () => deleteTaskWithUndo(context, task),
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
              // Both tabs have one, so they can't share the default hero tag.
              heroTag: null,
              onPressed: () => openTaskEditor(context),
              backgroundColor: context.colors.accent,
              foregroundColor: context.colors.onAccent,
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
      borderSide: BorderSide(color: context.colors.border),
    );
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: context.colors.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search tasks',
              hintStyle: TextStyle(color: context.colors.muted, fontSize: 14),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.colors.muted,
              ),
              filled: true,
              fillColor: context.colors.card,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: outline,
              enabledBorder: outline,
              focusedBorder: outline.copyWith(
                borderSide: BorderSide(color: context.colors.accent, width: 2),
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
              color: context.colors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(Icons.sort_rounded, color: context.colors.text),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dateLabel, required this.onOpenProfile});

  final String dateLabel;
  final VoidCallback onOpenProfile;

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
            onTap: onOpenProfile,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.accent,
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
                        style: TextStyle(
                          color: context.colors.onAccent,
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
                style: TextStyle(
                  color: context.colors.text,
                  fontSize: 20,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Small steps today, big wins tomorrow.',
                style: TextStyle(
                  color: context.colors.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: Text(
            dateLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.text,
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
    // The card is dark in both themes, so it uses the light-on-dark accent.
    final heroAccent = AppColors.dark.accent;
    final colors = context.colors;
    final track = Theme.of(context).brightness == Brightness.dark
        ? colors.progressTrack
        : colors.progressTrack.withAlpha(64);
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
        color: context.colors.hero,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
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
                        backgroundColor: track,
                        valueColor: AlwaysStoppedAnimation<Color>(heroAccent),
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
              backgroundColor: track,
              valueColor: AlwaysStoppedAnimation<Color>(heroAccent),
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
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.colors.accentTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: context.colors.accent, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: TextStyle(
                color: context.colors.text,
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: context.colors.muted,
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
        color: context.colors.border,
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
              color: selected ? context.colors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? context.colors.onAccent
                    : context.colors.muted,
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
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Text(
          'No tasks here',
          style: TextStyle(color: context.colors.muted, fontSize: 14),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          const _ChecklistIllustration(),
          const SizedBox(height: 16),
          Text(
            'Your day, your progress',
            style: TextStyle(
              color: context.colors.text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task and start building momentum.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.muted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Your First Task'),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.accent,
              foregroundColor: context.colors.onAccent,
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
              color: checked ? context.colors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: checked
                  ? null
                  : Border.all(color: context.colors.muted, width: 2),
            ),
            child: checked
                ? Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: context.colors.onAccent,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            width: lineWidth,
            height: 8,
            decoration: BoxDecoration(
              color: checked
                  ? context.colors.accent.withAlpha(110)
                  : context.colors.border,
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
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border, width: 2),
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
                  color: context.colors.accent,
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
        color: context.colors.card,
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
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing ? 'Edit task' : 'Create a new task',
                  style: TextStyle(
                    color: context.colors.text,
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
                      backgroundColor: context.colors.accent,
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
