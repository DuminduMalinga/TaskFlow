import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/services/task_storage.dart';

class _MemoryStorage implements TaskStorage {
  _MemoryStorage([List<Task>? initial]) : saved = initial ?? [];

  List<Task> saved;

  @override
  Future<List<Task>> loadTasks() async => List.of(saved);

  @override
  Future<void> saveTasks(List<Task> tasks) async => saved = List.of(tasks);
}

Future<TaskProvider> _provider([_MemoryStorage? storage]) async {
  final provider = TaskProvider(storage: storage ?? _MemoryStorage());
  await Future<void>.delayed(Duration.zero); // let the initial load finish
  return provider;
}

void main() {
  test('loads saved tasks on creation', () async {
    final storage = _MemoryStorage([Task(title: 'Saved', description: '')]);

    final provider = await _provider(storage);

    expect(provider.tasks.map((t) => t.title), ['Saved']);
  });

  test('addTask inserts at the top and persists', () async {
    final storage = _MemoryStorage();
    final provider = await _provider(storage);

    provider.addTask(title: 'First', description: 'a');
    provider.addTask(title: 'Second', description: 'b');

    expect(provider.tasks.map((t) => t.title), ['Second', 'First']);
    expect(storage.saved.map((t) => t.title), ['Second', 'First']);
  });

  test('updateTask changes the fields and persists', () async {
    final storage = _MemoryStorage();
    final provider = await _provider(storage);
    provider.addTask(title: 'Old', description: 'old');

    provider.updateTask(
      provider.tasks.first,
      title: 'New',
      description: 'new',
      dueDate: DateTime(2026, 12, 1),
    );

    expect(storage.saved.single.title, 'New');
    expect(storage.saved.single.description, 'new');
    expect(storage.saved.single.dueDate, DateTime(2026, 12, 1));
  });

  test('toggleTask flips completion and updates the task lists', () async {
    final provider = await _provider();
    provider.addTask(title: 'Task', description: '');
    final task = provider.tasks.first;

    provider.toggleTask(task);
    expect(provider.completedTasks, [task]);
    expect(provider.activeTasks, isEmpty);

    provider.toggleTask(task);
    expect(provider.completedTasks, isEmpty);
    expect(provider.activeTasks, [task]);
  });

  test('deleteTask removes the task and returns its index', () async {
    final storage = _MemoryStorage();
    final provider = await _provider(storage);
    provider.addTask(title: 'A', description: '');
    provider.addTask(title: 'B', description: '');
    final a = provider.tasks.last;

    final index = provider.deleteTask(a);

    expect(index, 1);
    expect(provider.tasks.map((t) => t.title), ['B']);
    expect(storage.saved.map((t) => t.title), ['B']);
  });

  test('restoreTask puts a deleted task back in its position', () async {
    final storage = _MemoryStorage();
    final provider = await _provider(storage);
    provider.addTask(title: 'A', description: '');
    provider.addTask(title: 'B', description: '');
    provider.addTask(title: 'C', description: '');
    final b = provider.tasks[1];

    final index = provider.deleteTask(b);
    provider.restoreTask(b, index);

    expect(provider.tasks.map((t) => t.title), ['C', 'B', 'A']);
    expect(storage.saved.map((t) => t.title), ['C', 'B', 'A']);
  });

  test('notifies listeners on every change', () async {
    final provider = await _provider();
    var notifications = 0;
    provider.addListener(() => notifications++);

    provider.addTask(title: 'A', description: '');
    provider.toggleTask(provider.tasks.first);
    provider.deleteTask(provider.tasks.first);

    expect(notifications, 3);
  });
}
