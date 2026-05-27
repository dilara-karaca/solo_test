import 'dart:convert';
import 'package:solo_test/services/hive_service.dart';
import 'package:solo_test/models/game_history.dart';
import 'package:solo_test/models/board_state.dart';
import 'package:solo_test/models/piece.dart';

class GameHistoryRepository {
  static final GameHistoryRepository _instance =
      GameHistoryRepository._internal();
  factory GameHistoryRepository() => _instance;
  GameHistoryRepository._internal();

  Future<void> init() async {
    await HiveService().init();
  }

  Future<void> createNewGame({
    required BoardState boardState,
    String? gameId,
    String? theme,
  }) async {
    final id = gameId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    final gh = GameHistory(
      gameId: id,
      startedAt: now,
      updatedAt: now,
      boardJson: boardStateToJson(boardState),
      moveCount: boardState.moveHistory.length,
      remainingPegs: boardState.remainingPieces,
      gameStatus: 'inProgress',
      theme: theme,
    );
    await HiveService().box.put(id, gh);
  }

  Future<void> updateGameFromBoard(
    String gameId,
    BoardState boardState, {
    String? status,
  }) async {
    final existing = HiveService().box.get(gameId);
    if (existing == null) return;
    final updated = GameHistory(
      gameId: existing.gameId,
      startedAt: existing.startedAt,
      updatedAt: DateTime.now(),
      boardJson: boardStateToJson(boardState),
      moveCount: boardState.moveHistory.length,
      remainingPegs: boardState.remainingPieces,
      gameStatus: status ?? existing.gameStatus,
      theme: existing.theme,
    );
    await HiveService().box.put(gameId, updated);
  }

  GameHistory? getGame(String gameId) => HiveService().box.get(gameId);

  List<GameHistory> getAllGames() {
    final list = HiveService().box.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  List<GameHistory> getInProgressGames() {
    final list =
        HiveService().box.values
            .where((g) => g.gameStatus == 'inProgress')
            .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> deleteGame(String gameId) async =>
      await HiveService().box.delete(gameId);

  Future<void> clearAll() async => await HiveService().box.clear();

  // Helpers to serialize BoardState -> JSON string and back
  String boardStateToJson(BoardState state) {
    final board =
        state.board
            .map(
              (row) =>
                  row
                      .map(
                        (p) => {
                          'row': p.row,
                          'column': p.column,
                          'isPeg': p.isPeg,
                          'isSelected': p.isSelected,
                          'pieceVariant': p.pieceVariant,
                        },
                      )
                      .toList(),
            )
            .toList();

    final map = {
      'board': board,
      'remainingPieces': state.remainingPieces,
      'moveHistory': state.moveHistory,
    };
    return jsonEncode(map);
  }

  BoardState boardStateFromJson(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final rawBoard = map['board'] as List<dynamic>;
    final board =
        rawBoard
            .map(
              (row) =>
                  (row as List<dynamic>)
                      .map(
                        (p) => Piece(
                          row: p['row'] as int,
                          column: p['column'] as int,
                          isPeg: p['isPeg'] as bool,
                          isSelected: p['isSelected'] as bool,
                          pieceVariant: p['pieceVariant'] as int?,
                        ),
                      )
                      .toList(),
            )
            .toList();

    final remaining = map['remainingPieces'] as int;
    final rawMoveHistory = map['moveHistory'] as List<dynamic>? ?? [];
    final moveHistory =
        rawMoveHistory.map<Map<String, int>>((entry) {
          final m = Map<String, dynamic>.from(entry as Map);
          return m.map<String, int>((k, v) => MapEntry(k, (v as num).toInt()));
        }).toList();

    return BoardState(
      board: board,
      remainingPieces: remaining,
      moveHistory: moveHistory,
    );
  }
}
