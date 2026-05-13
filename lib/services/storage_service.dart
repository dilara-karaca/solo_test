import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_test/models/game_result.dart';
import 'package:solo_test/core/constants/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveGameResult(GameResult result) async {
    final resultsList = _prefs.getStringList('game_results') ?? [];
    resultsList.add(result.toJson().toString());
    await _prefs.setStringList('game_results', resultsList);

    // Update statistics
    await _updateStatistics(result);
  }

  Future<void> _updateStatistics(GameResult result) async {
    // Update best score
    final currentBest = getBestScore();
    if (result.score > currentBest) {
      await _prefs.setInt(AppConstants.PREF_BEST_SCORE, result.score);
    }

    // Update games played
    final gamesPlayed = getGamesPlayed() + 1;
    await _prefs.setInt(AppConstants.PREF_GAMES_PLAYED, gamesPlayed);

    // Update total score
    final totalScore = getTotalScore() + result.score;
    await _prefs.setInt(AppConstants.PREF_TOTAL_SCORE, totalScore);
  }

  int getBestScore() {
    return _prefs.getInt(AppConstants.PREF_BEST_SCORE) ?? 0;
  }

  int getGamesPlayed() {
    return _prefs.getInt(AppConstants.PREF_GAMES_PLAYED) ?? 0;
  }

  int getTotalScore() {
    return _prefs.getInt(AppConstants.PREF_TOTAL_SCORE) ?? 0;
  }

  double getAverageScore() {
    final games = getGamesPlayed();
    if (games == 0) return 0;
    return getTotalScore() / games;
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
