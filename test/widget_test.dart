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
}
