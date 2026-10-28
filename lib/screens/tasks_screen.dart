import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/task_actions.dart';
import '../widgets/task_card.dart';

/// Every task, grouped by when it is due and searchable.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  /// `null` shows every group.
  TaskBucket? _bucket;
  String _query = '';

  static const _filters = [
    TaskBucket.overdue,
    TaskBucket.today,
    TaskBucket.tomorrow,
    TaskBucket.upcoming,
  ];

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final now = DateTime.now();
    final query = _query.trim().toLowerCase();

    final groups = {for (final bucket in TaskBucket.values) bucket: <Task>[]};
    for (final task in tasks) {
      final matches =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.category.label.toLowerCase().contains(query);
      if (matches) groups[task.bucketAt(now)]!.add(task);
    }
    for (final group in groups.values) {
      group.sort((a, b) {
        if (a.dueDate == null || b.dueDate == null) return 0;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    }

    final shown = [
      for (final bucket in TaskBucket.values)
        if (_bucket == null ? true : bucket == _bucket)
          if (groups[bucket]!.isNotEmpty) bucket,
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Tasks',
                  style: TextStyle(
                    color: navy,
                    fontSize: 24,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SearchField(
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 68,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  children: [
                    _BucketChip(
                      label: 'All',
                      count: null,
                      selected: _bucket == null,
                      onTap: () => setState(() => _bucket = null),
                    ),
                    for (final bucket in _filters) ...[
                      const SizedBox(width: 8),
                      _BucketChip(
                        label: bucket.label,
                        count: groups[bucket]!.length,
                        selected: _bucket == bucket,
                        isAlert: bucket == TaskBucket.overdue,
                        onTap: () => setState(() => _bucket = bucket),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (shown.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverToBoxAdapter(
                  child: _EmptyTasks(hasTasks: tasks.isNotEmpty),
                ),
              )
            else
              for (final bucket in shown) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: _GroupHeader(
                      bucket: bucket,
                      count: groups[bucket]!.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    bucket == shown.last ? 100 : 0,
                  ),
                  sliver: SliverList.separated(
                    itemCount: groups[bucket]!.length,
                    itemBuilder: (context, index) {
                      final task = groups[bucket]![index];
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
          ],
        ),
      ),
      floatingActionButton: tasks.isEmpty
          ? null
          : FloatingActionButton(
              // Both tabs have one, so they can't share the default hero tag.
              heroTag: null,
              onPressed: () => openTaskEditor(context),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: border),
    );
    return TextField(
      onChanged: onChanged,
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
    );
  }
}

class _BucketChip extends StatelessWidget {
  const _BucketChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.isAlert = false,
  });

  final String label;
  final int? count;
  final bool selected;
  final bool isAlert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alert = isAlert && (count ?? 0) > 0;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? navy : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? navy : border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 8),
                Text(
                  '$count',
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withAlpha(200)
                        : alert
                        ? danger
                        : muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.bucket, required this.count});

  final TaskBucket bucket;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          bucket.label.toUpperCase(),
          style: TextStyle(
            color: bucket == TaskBucket.overdue ? danger : muted,
            fontSize: 12,
            letterSpacing: 0.7,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.hasTasks});

  final bool hasTasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hasTasks ? 'No tasks here' : 'No tasks yet',
            style: const TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasTasks
                ? 'Try another filter or search.'
                : 'Add your first task to see it here.',
            style: const TextStyle(color: muted, fontSize: 13),
          ),
          if (!hasTasks) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => openTaskEditor(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Your First Task'),
              style: FilledButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
