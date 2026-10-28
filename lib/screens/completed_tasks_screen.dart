import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_colors.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key});

  void _reactivate(BuildContext context, Task task) {
    context.read<TaskProvider>().toggleTask(task);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task moved back to active'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = context.watch<TaskProvider>().completedTasks;
    return Scaffold(
      backgroundColor: context.colors.card,
      appBar: AppBar(
        backgroundColor: context.colors.card,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Completed Tasks',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: completedTasks.isEmpty
            ? const _CompletedEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: completedTasks.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _CompletedSummary(count: completedTasks.length);
                  }
                  final task = completedTasks[index - 1];
                  return _CompletedTaskCard(
                    task: task,
                    onReactivate: () => _reactivate(context, task),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 12),
              ),
      ),
    );
  }
}

class _CompletedSummary extends StatelessWidget {
  const _CompletedSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$count ${count == 1 ? 'task' : 'tasks'} completed',
        style: TextStyle(
          color: context.colors.muted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CompletedTaskCard extends StatelessWidget {
  const _CompletedTaskCard({required this.task, required this.onReactivate});

  final Task task;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onReactivate,
            child: Semantics(
              button: true,
              label: 'Mark ${task.title} as active',
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: context.colors.accent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: context.colors.onAccent,
                  size: 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: context.colors.muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.muted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onReactivate,
            tooltip: 'Mark task active',
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: context.colors.accent,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _CompletedEmptyState extends StatelessWidget {
  const _CompletedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: context.colors.accentTint,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                color: context.colors.accent,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No completed tasks yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finish a task and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
