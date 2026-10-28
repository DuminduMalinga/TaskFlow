import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_shell.dart';
import 'splash_screen.dart';
import 'welcome_screen.dart';

/// Shows the splash, then the welcome screen on first run, then the app.
class LaunchGate extends StatefulWidget {
  const LaunchGate({
    super.key,
    this.splashDuration = const Duration(milliseconds: 1800),
  });

  final Duration splashDuration;

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  static const _key = 'welcomeSeen';

  bool _splashDone = false;
  bool? _welcomeSeen;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final minimum = Future.delayed(widget.splashDuration);
    var seen = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      seen = prefs.getBool(_key) ?? false;
    } catch (_) {
      // Treat storage failures as a first run.
    }
    await minimum;
    if (!mounted) return;
    setState(() {
      _welcomeSeen = seen;
      _splashDone = true;
    });
  }

  Future<void> _finishWelcome() async {
    setState(() => _welcomeSeen = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {
      // The welcome screen may show again next launch.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) return const SplashScreen();
    if (_welcomeSeen == false) {
      return WelcomeScreen(onContinue: _finishWelcome);
    }
    return const MainShell();
  }
}
