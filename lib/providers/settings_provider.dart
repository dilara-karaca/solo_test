import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _difficulty = 1; // 1: Easy, 2: Medium, 3: Hard

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  int get difficulty => _difficulty;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
  }

  void setDifficulty(int level) {
    if (level >= 1 && level <= 3) {
      _difficulty = level;
      notifyListeners();
    }
  }
}
