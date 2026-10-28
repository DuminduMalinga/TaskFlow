import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_storage.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskStorage? storage}) : _storage = storage ?? TaskStorage() {
    _load();
  }

  final TaskStorage _storage;
  final List<Task> _tasks = [];

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);

  List<Task> get activeTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  Future<void> _load() async {
    _tasks
      ..clear()
      ..addAll(await _storage.loadTasks());
    notifyListeners();
  }

  void _commit() {
    notifyListeners();
    _storage.saveTasks(_tasks);
  }

  void addTask({
    required String title,
    required String description,
    DateTime? dueDate,
    TaskCategory category = TaskCategory.personal,
  }) {
    _tasks.insert(
      0,
      Task(
        title: title,
        description: description,
        dueDate: dueDate,
        category: category,
      ),
    );
    _commit();
  }

  void updateTask(
    Task task, {
    required String title,
    required String description,
    DateTime? dueDate,
    TaskCategory? category,
  }) {
    task
      ..title = title
      ..description = description
      ..dueDate = dueDate
      ..category = category ?? task.category;
    _commit();
  }

  void toggleTask(Task task) {
    task.isCompleted = !task.isCompleted;
    _commit();
  }

  /// Removes [task] and returns its position so it can be restored.
  int deleteTask(Task task) {
    final index = _tasks.indexOf(task);
    _tasks.remove(task);
    _commit();
    return index;
  }

  void restoreTask(Task task, int index) {
    _tasks.insert(index.clamp(0, _tasks.length), task);
    _commit();
  }
}
