import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/task.dart';

void main() {
  taskBucketTests();
  group('Task JSON', () {
    test('round-trips every field', () {
      final task = Task(
        title: 'Write tests',
        description: 'Cover the model',
        dueDate: DateTime(2026, 11, 5, 9, 30),
        isCompleted: true,
      );

      final copy = Task.fromJson(task.toJson());

      expect(copy.title, task.title);
      expect(copy.description, task.description);
      expect(copy.dueDate, task.dueDate);
      expect(copy.isCompleted, isTrue);
    });

    test('keeps a missing due date null', () {
      final copy = Task.fromJson(Task(title: 'a', description: 'b').toJson());

      expect(copy.dueDate, isNull);
      expect(copy.isCompleted, isFalse);
    });

    test('falls back to defaults for missing or invalid fields', () {
      final task = Task.fromJson({'dueDate': 'not a date'});

      expect(task.title, '');
      expect(task.description, '');
      expect(task.dueDate, isNull);
      expect(task.isCompleted, isFalse);
    });
  });
}

void taskBucketTests() {
  final now = DateTime(2026, 10, 28, 12);
  Task due(DateTime? date, {bool done = false}) =>
      Task(title: 't', description: '', dueDate: date, isCompleted: done);

  test('Task buckets by due date relative to today', () {
    expect(due(DateTime(2026, 10, 27)).bucketAt(now), TaskBucket.overdue);
    expect(due(DateTime(2026, 10, 28)).bucketAt(now), TaskBucket.today);
    expect(due(DateTime(2026, 10, 28, 18)).bucketAt(now), TaskBucket.today);
    expect(due(DateTime(2026, 10, 28, 9)).bucketAt(now), TaskBucket.overdue);
    expect(due(DateTime(2026, 10, 29)).bucketAt(now), TaskBucket.tomorrow);
    expect(due(DateTime(2026, 10, 30)).bucketAt(now), TaskBucket.upcoming);
    expect(
      due(DateTime(2026, 10, 1), done: true).bucketAt(now),
      TaskBucket.completed,
    );
  });

  test('Task category round-trips and defaults to personal', () {
    final task = Task(
      title: 't',
      description: '',
      category: TaskCategory.financial,
    );
    expect(Task.fromJson(task.toJson()).category, TaskCategory.financial);
    expect(Task.fromJson({'title': 'x'}).category, TaskCategory.personal);
  });
}
