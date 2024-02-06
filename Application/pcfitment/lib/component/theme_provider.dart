import 'package:flutter/material.dart';
import 'package:pcfitment/component/themes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme = ThemeClass.lightTheme;

  ThemeData get selectedTheme => _selectedTheme;

  void toggleTheme() {
    _selectedTheme = (_selectedTheme == ThemeClass.lightTheme)
        ? ThemeClass.darkTheme
        : ThemeClass.lightTheme;
    notifyListeners();
  }
}

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeProvider1 extends ChangeNotifier {
  AppThemeMode _selectedMode = AppThemeMode.system;

  AppThemeMode get selectedMode => _selectedMode;

  ThemeData get selectedTheme {
    switch (_selectedMode) {
      case AppThemeMode.light:
        return ThemeClass.lightTheme;
      case AppThemeMode.dark:
        return ThemeClass.darkTheme;
      case AppThemeMode.system:
      default:
        return ThemeClass.lightTheme;
    }
  }

  void setThemeMode(AppThemeMode mode) {
    _selectedMode = mode;
    notifyListeners();
  }
}

class ThemeProvider2 extends ChangeNotifier {
  ThemeMode _selectedMode = ThemeMode.system;

  ThemeMode get selectedMode => _selectedMode;

  ThemeData get selectedTheme {
    switch (_selectedMode) {
      case ThemeMode.light:
        return ThemeClass.lightTheme;
      case ThemeMode.dark:
        return ThemeClass.darkTheme;
      case ThemeMode.system:
        return ThemeData
            .light(); // Set default light theme if system theme is used
      default:
        return ThemeData.light();
    }
  }

  void setThemeMode(ThemeMode mode) {
    _selectedMode = mode;
    notifyListeners();
  }
}
