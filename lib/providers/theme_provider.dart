import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which theme the app uses: follow the device, or force light or dark.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _load();
  }

  static const _key = 'themeMode';

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      _mode = ThemeMode.values.firstWhere(
        (mode) => mode.name == saved,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    } catch (_) {
      // Keep following the device theme.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
