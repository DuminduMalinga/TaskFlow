import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider() {
    _load();
  }

  static const _key = 'profile';

  Profile _profile = const Profile();
  bool _isLoaded = false;

  Profile get profile => _profile;

  /// False until the saved profile has been read from storage.
  bool get isLoaded => _isLoaded;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _profile = Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // Corrupt data: keep the default profile.
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> update(Profile profile) async {
    _profile = profile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
