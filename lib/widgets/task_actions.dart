import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/add_task_screen.dart';
import '../screens/edit_task_screen.dart';
import 'delete_task_dialog.dart';

/// Opens the add screen, or the edit screen when [task] is given, and saves
/// the result.
Future<void> openTaskEditor(BuildContext context, {Task? task}) async {
  final provider = context.read<TaskProvider>();
  if (task == null) {
    final result = await Navigator.push<AddTaskResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (result == null) return;
    provider.addTask(
      title: result.title,
      description: result.description,
      dueDate: result.dueDate,
      category: result.category,
    );
    return;
  }

  final result = await Navigator.push<EditTaskResult>(
    context,
    MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
  );
  if (result == null) return;
  provider.updateTask(
    task,
    title: result.title,
    description: result.description,
    dueDate: result.dueDate,
    category: result.category,
  );
}

/// Confirms, deletes [task], and offers an undo.
Future<void> deleteTaskWithUndo(BuildContext context, Task task) async {
  final shouldDelete = await DeleteTaskDialog.show(context);
  if (shouldDelete != true || !context.mounted) return;
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
