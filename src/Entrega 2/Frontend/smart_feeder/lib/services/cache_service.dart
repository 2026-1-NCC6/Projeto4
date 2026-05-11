import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_feeder/models/feeder_data.dart';

class CacheService {
  static const String _feederDataKey = 'cached_feeder_data';
  static const String _lastUserEmailKey = 'last_user_email'; // "Cookie" simulation
  static const String _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  // --- Feeder Data Cache ---
  
  Future<void> cacheFeederData(FeederData data) async {
    final String jsonString = jsonEncode(data.toMap());
    await _prefs.setString(_feederDataKey, jsonString);
  }

  FeederData? getCachedFeederData() {
    final String? jsonString = _prefs.getString(_feederDataKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        return FeederData.fromMap(map);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // --- "Cookies" (Persistent UI state) ---

  Future<void> saveLastUserEmail(String email) async {
    await _prefs.setString(_lastUserEmailKey, email);
  }

  String? getLastUserEmail() {
    return _prefs.getString(_lastUserEmailKey);
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(_themeModeKey);
  }

  Future<void> clearCache() async {
    await _prefs.remove(_feederDataKey);
  }
}
