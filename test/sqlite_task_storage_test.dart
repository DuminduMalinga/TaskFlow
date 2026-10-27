import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/sqlite_task_storage.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('tasks survive reopening the database', () async {
    await databaseFactory.deleteDatabase(
      '${await databaseFactory.getDatabasesPath()}/taskflow.db',
    );
    await SqliteTaskStorage().saveTasks([
      Task(title: 'B', description: 'two', dueDate: DateTime(2026, 11, 1)),
      Task(title: 'A', description: 'one', isCompleted: true),
    ]);

    final loaded = await SqliteTaskStorage().loadTasks();

    expect(loaded.map((t) => t.title), ['B', 'A']);
    expect(loaded[0].dueDate, DateTime(2026, 11, 1));
    expect(loaded[1].isCompleted, isTrue);
  });
}
