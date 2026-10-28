import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'theme/app_colors.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          onPrimary: Colors.white,
          surface: Colors.white,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: navy,
          elevation: 0,
        ),
      ),
      home: const MainShell(),
    );
  }
}
