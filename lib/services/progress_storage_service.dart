import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_progress.dart';

class ProgressStorageService {
  static const String _progressKey = 'stella_player_progress';

  Future<PlayerProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProgress = prefs.getString(_progressKey);

    if (rawProgress == null) {
      return PlayerProgress.initial();
    }

    try {
      final decoded = jsonDecode(rawProgress) as Map<String, dynamic>;
      return PlayerProgress.fromJson(decoded);
    } catch (_) {
      return PlayerProgress.initial();
    }
  }

  Future<void> saveProgress(PlayerProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(progress.toJson());
    await prefs.setString(_progressKey, encoded);
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}