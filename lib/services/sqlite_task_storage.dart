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
      version: 2,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          position INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          due_date TEXT,
          is_completed INTEGER NOT NULL DEFAULT 0,
          category TEXT NOT NULL DEFAULT 'personal'
        )
      '''),
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE $_table ADD COLUMN category TEXT NOT NULL DEFAULT 'personal'",
          );
        }
      },
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
        category: TaskCategory.fromName(row['category'] as String?),
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
          'category': task.category.name,
        });
      }
      await batch.commit(noResult: true);
    });
  }
}
