import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'screens/launch_gate.dart';
import 'theme/app_colors.dart';

ThemeData _buildTheme(AppColors colors, Brightness brightness) {
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.accent,
      brightness: brightness,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      surface: colors.card,
      onSurface: colors.text,
      error: colors.danger,
    ),
    fontFamily: 'Inter',
    extensions: [colors],
    dividerColor: colors.border,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colors.card,
      surfaceTintColor: Colors.transparent,
      shape: shape,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.card,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.card,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.text,
      contentTextStyle: TextStyle(color: colors.background),
      actionTextColor: colors.accent,
    ),
  );
}

class DonezoApp extends StatelessWidget {
  const DonezoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeProvider>().mode;
    return MaterialApp(
      title: 'The Donezo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(AppColors.light, Brightness.light),
      darkTheme: _buildTheme(AppColors.dark, Brightness.dark),
      themeMode: mode,
      home: const LaunchGate(),
    );
  }
}
