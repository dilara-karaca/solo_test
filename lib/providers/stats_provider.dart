import 'package:flutter/foundation.dart';
import 'package:solo_test/services/storage_service.dart';

class StatsProvider extends ChangeNotifier {
  int bestScore = 0;
  int gamesPlayed = 0;
  int totalScore = 0;

  Future<void> load() async {
    // StorageService is already initialized in main
    final storage = StorageService();
    bestScore = storage.getBestScore();
    gamesPlayed = storage.getGamesPlayed();
    totalScore = storage.getTotalScore();
    notifyListeners();
  }

  double get averageScore {
    if (gamesPlayed == 0) return 0;
    return totalScore / gamesPlayed;
  }
}
