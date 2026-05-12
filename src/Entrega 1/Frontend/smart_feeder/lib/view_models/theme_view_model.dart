import 'package:flutter/material.dart';

/// ViewModel para controle do tema claro/escuro.
/// Na Entrega 1, a preferência não é persistida (sem SharedPreferences).
class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
