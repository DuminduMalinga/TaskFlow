import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'providers/profile_provider.dart';
import 'providers/task_provider.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Android and iOS use the sqflite plugin; desktop needs the FFI factory.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const TaskFlowApp(),
    ),
  );
}
