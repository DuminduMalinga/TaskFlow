import 'package:flutter/foundation.dart';

import '../models/task.dart';
import 'prefs_task_storage.dart';
import 'sqlite_task_storage.dart';

abstract class TaskStorage {
  /// SQLite everywhere it is available; the browser has no native SQLite,
  /// so the web build falls back to SharedPreferences.
  factory TaskStorage() => kIsWeb ? PrefsTaskStorage() : SqliteTaskStorage();

  Future<List<Task>> loadTasks();

  Future<void> saveTasks(List<Task> tasks);
}
