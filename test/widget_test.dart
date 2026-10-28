import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/providers/profile_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/services/prefs_task_storage.dart';

import 'package:todo/screens/task_home_screen.dart';

const _seedTasks = [
  {
    'title': 'Plan the day',
    'description': 'Review priorities',
    'isCompleted': true,
  },
  {'title': 'Design the dashboard', 'description': 'Clean layout'},
  {
    'title': 'Team stand-up meeting',
    'description': 'Share progress',
    'isCompleted': true,
  },
];

Future<void> pumpApp(WidgetTester tester) async {
  // A phone-sized, taller screen so every task card is on screen.
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'tasks': jsonEncode(_seedTasks)});
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(storage: PrefsTaskStorage()),
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const TaskFlowApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pickDate(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.calendar_today_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the TaskFlow dashboard', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('Daily progress'), findsOneWidget);
    expect(find.text('Design the dashboard'), findsOneWidget);
    expect(find.byTooltip('Add task'), findsOneWidget);
  });

  testWidgets('can switch to active tasks', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    expect(find.text('Design the dashboard'), findsOneWidget);
    expect(find.text('Plan the day'), findsNothing);
  });

  testWidgets('can create a task', (WidgetTester tester) async {
    await pumpApp(tester);
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
    await pickDate(tester);
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    expect(find.text('Call the dentist'), findsOneWidget);
  });

  testWidgets('can open and save the edit task screen', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('More actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
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
    await pickDate(tester);
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Plan the week'), findsOneWidget);
  });

  testWidgets('can open completed tasks and reactivate a task', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
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
    await pumpApp(tester);
    await tester.tap(find.byTooltip('More actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this task?'), findsOneWidget);
    expect(
      find.text('You can undo this right after deleting.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Plan the day'), findsOneWidget);

    await tester.tap(find.byTooltip('More actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Plan the day'), findsNothing);
  });

  testWidgets('can search tasks', (WidgetTester tester) async {
    await pumpApp(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Search tasks'),
      'dash',
    );
    await tester.pumpAndSettle();

    expect(find.text('Design the dashboard'), findsOneWidget);
    expect(find.text('Plan the day'), findsNothing);
  });

  testWidgets('can undo a deletion', (WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('More actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Plan the day'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Plan the day'), findsOneWidget);
  });

  testWidgets('requires a due date to create a task', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'e.g. Plan the team meeting'),
      'No date task',
    );
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a due date'), findsOneWidget);
    expect(find.text('Add New Task'), findsOneWidget);
  });

  testWidgets('can update the profile', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('profile-avatar')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Alex'),
      'Sam Lee',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '+94 77 123 4567'),
      '0771234567',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'name@example.com'),
      'sam@example.com',
    );
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Sam'), findsOneWidget);
  });

  testWidgets('validates profile fields', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('profile-avatar')));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Alex'), '');
    await tester.enterText(
      find.widgetWithText(TextFormField, '+94 77 123 4567'),
      '12',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'name@example.com'),
      'nope',
    );
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Enter a valid mobile number'), findsOneWidget);
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });
}
