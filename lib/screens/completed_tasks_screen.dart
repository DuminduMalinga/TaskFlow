import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';

class CompletedTasksScreen extends StatefulWidget {
  const CompletedTasksScreen({
    required this.tasks,
    required this.onTaskReactivated,
    super.key,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onTaskReactivated;

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  late final List<Task> _completedTasks;

  @override
  void initState() {
    super.initState();
    _completedTasks = List<Task>.from(widget.tasks);
  }

  void _reactivate(Task task) {
    widget.onTaskReactivated(task);
    setState(() => _completedTasks.remove(task));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task moved back to active'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        child: _completedTasks.isEmpty
            ? const _CompletedEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: _completedTasks.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _CompletedSummary(count: _completedTasks.length);
                  }
                  final task = _completedTasks[index - 1];
                  return _CompletedTaskCard(
                    task: task,
                    onReactivate: () => _reactivate(task),
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
        style: const TextStyle(
          color: muted,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
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
                  color: blue,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
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
                  style: const TextStyle(
                    color: muted,
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
                  style: const TextStyle(
                    color: muted,
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
            color: blue,
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
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.task_alt_rounded, color: blue, size: 38),
            ),
            const SizedBox(height: 20),
            const Text(
              'No completed tasks yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Finish a task and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
