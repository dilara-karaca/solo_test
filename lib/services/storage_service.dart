import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_test/models/game_result.dart';
import 'package:solo_test/repositories/game_history_repository.dart';
import 'package:solo_test/models/game_history.dart';
import 'package:solo_test/core/constants/app_constants.dart';
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

    // Avoid duplicate saves by checking for either exact playedAt match or
    // a matching tuple of (remainingPieces, score, totalMoves).
    final iso = result.playedAt.toIso8601String();
    bool exists = false;
    for (final e in resultsList) {
      try {
        final decoded = jsonDecode(e) as Map<String, dynamic>;
        if (decoded['playedAt'] == iso) {
          exists = true;
          break;
        }

        final rem = decoded['remainingPieces'] as int?;
        final sc = decoded['score'] as int?;
        final moves = decoded['totalMoves'] as int?;
        if (rem != null && sc != null && moves != null) {
          if (rem == result.remainingPieces &&
              sc == result.score &&
              moves == result.totalMoves) {
            exists = true;
            break;
          }
        }
      } catch (_) {
        // ignore parse errors
      }
    }

    if (!exists) {
      resultsList.add(jsonEncode(result.toJson()));
      await _prefs.setStringList('game_results', resultsList);
    }

    // Recompute aggregated statistics from the full stored results to avoid
    // increment/duplicate-count issues.
    final all = await getGameResults();
    final best =
        all.isEmpty
            ? 0
            : all.map((r) => r.score).reduce((a, b) => a > b ? a : b);
    final gamesPlayed = all.length;
    final totalScore = all.fold<int>(0, (p, r) => p + r.score);

    await _prefs.setInt(AppConstants.PREF_BEST_SCORE, best);
    await _prefs.setInt(AppConstants.PREF_GAMES_PLAYED, gamesPlayed);
    await _prefs.setInt(AppConstants.PREF_TOTAL_SCORE, totalScore);
  }

  /// Remove duplicate stored GameResult entries by (remaining,score,totalMoves) key.
  /// Keeps the entry with the latest playedAt when duplicates are found.
  Future<void> dedupeStoredGameResults() async {
    final list = _prefs.getStringList('game_results') ?? [];
    final Map<String, Map<String, dynamic>> seen = {};

    for (final s in list) {
      try {
        final decoded = jsonDecode(s) as Map<String, dynamic>;
        final key =
            '${decoded['remainingPieces']}_${decoded['score']}_${decoded['totalMoves']}';
        final existing = seen[key];
        if (existing == null) {
          seen[key] = decoded;
        } else {
          final existingDt =
              DateTime.tryParse(existing['playedAt'] as String) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final thisDt =
              DateTime.tryParse(decoded['playedAt'] as String) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          if (thisDt.isAfter(existingDt)) {
            seen[key] = decoded;
          }
        }
      } catch (_) {
        // ignore
      }
    }

    final cleaned = seen.values.map((m) => jsonEncode(m)).toList();
    await _prefs.setStringList('game_results', cleaned);

    // recompute stats
    final all = await getGameResults();
    final best =
        all.isEmpty
            ? 0
            : all.map((r) => r.score).reduce((a, b) => a > b ? a : b);
    final gamesPlayed = all.length;
    final totalScore = all.fold<int>(0, (p, r) => p + r.score);
    await _prefs.setInt(AppConstants.PREF_BEST_SCORE, best);
    await _prefs.setInt(AppConstants.PREF_GAMES_PLAYED, gamesPlayed);
    await _prefs.setInt(AppConstants.PREF_TOTAL_SCORE, totalScore);
  }

  Future<List<GameResult>> getGameResults() async {
    final resultsList = _prefs.getStringList('game_results') ?? [];
    final List<GameResult> results = [];

    for (final entry in resultsList) {
      try {
        final decoded = jsonDecode(entry) as Map<String, dynamic>;
        results.add(GameResult.fromJson(decoded));
      } catch (_) {
        // try to parse legacy Dart Map.toString() format
        final parsed = _parseLegacyEntry(entry);
        if (parsed != null) results.add(parsed);
      }
    }

    // sort by playedAt descending
    results.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return results;
  }

  GameResult? _parseLegacyEntry(String s) {
    try {
      final int? remainingPieces = _extractInt(s, r'remainingPieces:\s*(\d+)');
      final int? score = _extractInt(s, r'score:\s*(\d+)');
      final String grade = _extractString(s, r'grade:\s*([^,}\n]+)') ?? '';
      final int? totalMoves = _extractInt(s, r'totalMoves:\s*(\d+)');
      final String? playedAtRaw = _extractString(s, r'playedAt:\s*([^,}\n]+)');
      final int? durationSeconds = _extractInt(
        s,
        r'gameDurationSeconds:\s*(\d+)',
      );

      if (score == null ||
          remainingPieces == null ||
          totalMoves == null ||
          playedAtRaw == null ||
          durationSeconds == null)
        return null;

      final playedAt = DateTime.tryParse(playedAtRaw) ?? DateTime.now();

      return GameResult(
        remainingPieces: remainingPieces,
        score: score,
        grade: grade.trim(),
        totalMoves: totalMoves,
        playedAt: playedAt,
        gameDuration: Duration(seconds: durationSeconds),
      );
    } catch (_) {
      return null;
    }
  }

  int? _extractInt(String s, String pattern) {
    final reg = RegExp(pattern);
    final m = reg.firstMatch(s);
    if (m == null) return null;
    return int.tryParse(m.group(1)!.trim());
  }

  String? _extractString(String s, String pattern) {
    final reg = RegExp(pattern);
    final m = reg.firstMatch(s);
    if (m == null) return null;
    return m.group(1)?.trim();
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

  /// Import completed games from Hive GameHistory into SharedPreferences
  /// Creates GameResult entries for any history item that is not inProgress
  /// and isn't already present in the stored game_results list.
  Future<void> importCompletedFromHive() async {
    try {
      final all = GameHistoryRepository().getAllGames();
      for (final g in all) {
        if (g.gameStatus == 'inProgress') continue;

        final result = GameResult(
          remainingPieces: g.remainingPegs,
          score: AppConstants.getScoreForRemainingPieces(g.remainingPegs),
          grade: AppConstants.getGradeForRemainingPieces(g.remainingPegs),
          totalMoves: g.moveCount,
          playedAt: g.updatedAt,
          gameDuration: Duration.zero,
        );
        await saveGameResult(result);
      }
      // Clean up any duplicates that may have been introduced by earlier runs
      await dedupeStoredGameResults();
    } catch (e) {
      // don't crash app on migration issues
    }
  }
}
