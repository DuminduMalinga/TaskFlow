import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import 'task_storage.dart';

class SqliteTaskStorage implements TaskStorage {
  static const _table = 'tasks';

  Future<Database>? _db;

  Future<Database> get _database => _db ??= _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'taskflow.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          position INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          due_date TEXT,
          is_completed INTEGER NOT NULL DEFAULT 0
        )
      '''),
    );
  }

  @override
  Future<List<Task>> loadTasks() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'position ASC');
    return rows.map((row) {
      final due = row['due_date'] as String?;
      return Task(
        title: row['title'] as String,
        description: row['description'] as String,
        dueDate: due == null ? null : DateTime.tryParse(due),
        isCompleted: (row['is_completed'] as int) == 1,
      );
    }).toList();
  }

  /// Rewrites the table in one transaction; `position` keeps the list order.
  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.delete(_table);
      final batch = txn.batch();
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        batch.insert(_table, {
          'position': i,
          'title': task.title,
          'description': task.description,
          'due_date': task.dueDate?.toIso8601String(),
          'is_completed': task.isCompleted ? 1 : 0,
        });
      }
      await batch.commit(noResult: true);
    });
  }
}
