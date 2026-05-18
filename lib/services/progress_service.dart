import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _unlockedLevelKey = 'unlocked_level';
  static const int _defaultUnlockedLevel = 1;

  Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLevel = prefs.getInt(_unlockedLevelKey) ?? _defaultUnlockedLevel;
    if (savedLevel < 1) {
      return _defaultUnlockedLevel;
    }
    if (savedLevel > 10) {
      return 10;
    }
    return savedLevel;
  }

  Future<void> setUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unlockedLevelKey, level.clamp(1, 10));
  }

  Future<void> resetProgress() async {
    await setUnlockedLevel(_defaultUnlockedLevel);
  }
}
