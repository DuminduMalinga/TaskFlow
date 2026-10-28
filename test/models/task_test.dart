import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/task.dart';

void main() {
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
