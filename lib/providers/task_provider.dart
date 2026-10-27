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
  }) {
    _tasks.insert(
      0,
      Task(title: title, description: description, dueDate: dueDate),
    );
    _commit();
  }

  void updateTask(
    Task task, {
    required String title,
    required String description,
    DateTime? dueDate,
  }) {
    task
      ..title = title
      ..description = description
      ..dueDate = dueDate;
    _commit();
  }

  void toggleTask(Task task) {
    task.isCompleted = !task.isCompleted;
    _commit();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    _commit();
  }
}
