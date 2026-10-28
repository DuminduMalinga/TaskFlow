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

  Profile get profile => _profile;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      _profile = Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {
      // Corrupt data: keep the default profile.
    }
  }

  Future<void> update(Profile profile) async {
    _profile = profile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
