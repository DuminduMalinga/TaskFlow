import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo/screens/task_home_screen.dart';

void main() {
  testWidgets('renders the TaskFlow dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('Daily progress'), findsOneWidget);
    expect(find.text('Design the dashboard'), findsOneWidget);
    expect(find.byTooltip('Add task'), findsOneWidget);
  });

  testWidgets('can switch to active tasks', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    expect(find.text('Design the dashboard'), findsOneWidget);
    expect(find.text('Plan the day'), findsNothing);
  });

  testWidgets('can create a task', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'e.g. Plan the team meeting'),
      'Call the dentist',
    );
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Add details to help you complete this task',
      ),
      'Book an appointment',
    );
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    expect(find.text('Call the dentist'), findsOneWidget);
  });

  testWidgets('can open and save the edit task screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.tap(find.byTooltip('Edit task').first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);
    expect(
      find.text('Update the details of your existing task.'),
      findsOneWidget,
    );
    expect(find.text('Plan the day'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter a task title'),
      'Plan the week',
    );
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Plan the week'), findsOneWidget);
  });

  testWidgets('can open completed tasks and reactivate a task', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.tap(find.text('Completed').last);
    await tester.pumpAndSettle();

    expect(find.text('Completed Tasks'), findsOneWidget);
    expect(find.text('2 tasks completed'), findsOneWidget);
    expect(find.text('Plan the day'), findsOneWidget);

    await tester.tap(find.byTooltip('Mark task active').first);
    await tester.pumpAndSettle();

    expect(find.text('1 task completed'), findsOneWidget);
  });

  testWidgets('can cancel and confirm task deletion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.tap(find.byTooltip('Delete task').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete this task?'), findsOneWidget);
    expect(find.text('This action cannot be undone.'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Plan the day'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete task').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Plan the day'), findsNothing);
  });
}
