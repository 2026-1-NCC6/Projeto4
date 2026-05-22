import 'package:flutter/material.dart';
import 'package:smart_feeder/services/cache_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final CacheService _cacheService;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeViewModel(this._cacheService) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    final String? savedMode = _cacheService.getThemeMode();
    if (savedMode != null) {
      _themeMode = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _cacheService.saveThemeMode(_themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }
}
