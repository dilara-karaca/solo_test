import 'package:flutter/material.dart';
import '../models/game_theme_model.dart';

class ThemeProvider extends ChangeNotifier {
  GameTheme _currentTheme = GameTheme.classic;

  GameTheme get currentTheme => _currentTheme;
  GameThemeData get themeData => allThemes[_currentTheme]!;

  void setTheme(GameTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
