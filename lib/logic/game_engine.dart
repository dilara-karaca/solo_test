import 'package:solo_test/core/constants/app_constants.dart';
import 'package:solo_test/models/board_state.dart';
import 'package:solo_test/models/game_result.dart';
import 'package:solo_test/models/game_theme_model.dart';
import 'package:solo_test/repositories/game_history_repository.dart';
import 'move_validator.dart';

class GameEngine {
  BoardState boardState;
  List<Map<String, int>> moveHistory = [];
  DateTime? gameStartTime;
  GameTheme? currentTheme;
  String? currentGameId;

  GameEngine({this.currentTheme})
    : boardState = BoardState.initial(AppConstants.BOARD_SIZE, theme: null);

  void initializeGame({GameTheme? theme}) {
    currentTheme = theme;
    boardState = BoardState.initial(AppConstants.BOARD_SIZE, theme: theme);
    moveHistory = [];
    gameStartTime = DateTime.now();
    // create a new history record (non-blocking)
    try {
      currentGameId = DateTime.now().millisecondsSinceEpoch.toString();
      GameHistoryRepository().createNewGame(
        boardState: boardState,
        gameId: currentGameId,
        theme: theme != null ? theme.toString().split('.').last : null,
      );
    } catch (_) {}
  }

  bool makeMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (!MoveValidator.isValidMove(
      boardState,
      fromRow,
      fromCol,
      toRow,
      toCol,
    )) {
      return false;
    }

    // Calculate middle position
    final midRow = (fromRow + toRow) ~/ 2;
    final midCol = (fromCol + toCol) ~/ 2;

    // Create new board state
    final newBoard = boardState.board.map((row) => [...row]).toList();

    // Move peg from position
    newBoard[toRow][toCol] = newBoard[fromRow][fromCol].copyWith(
      row: toRow,
      column: toCol,
      isSelected: false,
    );

    // Remove peg from original position
    newBoard[fromRow][fromCol] = newBoard[fromRow][fromCol].copyWith(
      isPeg: false,
      isSelected: false,
    );

    // Remove captured peg
    newBoard[midRow][midCol] = newBoard[midRow][midCol].copyWith(
      isPeg: false,
      isSelected: false,
    );

    // Count remaining pegs
    int remainingPegs = 0;
    for (var row in newBoard) {
      for (var piece in row) {
        if (piece.isPeg) {
          remainingPegs++;
        }
      }
    }

    // Update board state
    moveHistory.add({
      'fromRow': fromRow,
      'fromCol': fromCol,
      'toRow': toRow,
      'toCol': toCol,
      'capturedRow': midRow,
      'capturedCol': midCol,
    });

    boardState = boardState.copyWith(
      board: newBoard,
      remainingPieces: remainingPegs,
      moveHistory: moveHistory,
    );

    // persist update (non-blocking)
    try {
      if (currentGameId != null) {
        GameHistoryRepository().updateGameFromBoard(currentGameId!, boardState);
      }
    } catch (_) {}

    return true;
  }

  bool undoLastMove() {
    if (moveHistory.isEmpty) {
      return false;
    }

    final lastMove = moveHistory.removeLast();
    final fromRow = lastMove['fromRow']!;
    final fromCol = lastMove['fromCol']!;
    final toRow = lastMove['toRow']!;
    final toCol = lastMove['toCol']!;
    final capturedRow = lastMove['capturedRow']!;
    final capturedCol = lastMove['capturedCol']!;

    final newBoard = boardState.board.map((row) => [...row]).toList();

    // Move peg back
    newBoard[fromRow][fromCol] = newBoard[toRow][toCol].copyWith(
      row: fromRow,
      column: fromCol,
    );

    // Clear destination
    newBoard[toRow][toCol] = newBoard[toRow][toCol].copyWith(isPeg: false);

    // Restore captured peg
    newBoard[capturedRow][capturedCol] = newBoard[capturedRow][capturedCol]
        .copyWith(isPeg: true);

    // Recount pieces
    int remainingPegs = 0;
    for (var row in newBoard) {
      for (var piece in row) {
        if (piece.isPeg) {
          remainingPegs++;
        }
      }
    }

    boardState = boardState.copyWith(
      board: newBoard,
      remainingPieces: remainingPegs,
    );

    boardState = boardState.copyWith(moveHistory: moveHistory);

    // persist update (non-blocking)
    try {
      if (currentGameId != null) {
        GameHistoryRepository().updateGameFromBoard(currentGameId!, boardState);
      }
    } catch (_) {}

    return true;
  }

  bool isGameOver() {
    return !MoveValidator.hasValidMoves(boardState);
  }

  GameResult endGame() {
    final remainingPieces = boardState.remainingPieces;
    final score = _calculateScore(remainingPieces);
    final grade = _getGrade(remainingPieces);
    final duration =
        gameStartTime != null
            ? DateTime.now().difference(gameStartTime!)
            : Duration.zero;
    // update history status
    try {
      if (currentGameId != null) {
        final status = remainingPieces == 1 ? 'won' : 'lost';
        GameHistoryRepository().updateGameFromBoard(
          currentGameId!,
          boardState,
          status: status,
        );
      }
    } catch (_) {}

    return GameResult(
      remainingPieces: remainingPieces,
      score: score,
      grade: grade,
      totalMoves: moveHistory.length,
      playedAt: DateTime.now(),
      gameDuration: duration,
    );
  }

  int _calculateScore(int remainingPieces) {
    return AppConstants.getScoreForRemainingPieces(remainingPieces);
  }

  String _getGrade(int remainingPieces) {
    return AppConstants.getGradeForRemainingPieces(remainingPieces);
  }

  List<List<bool>> getValidMovesForBoard() {
    return MoveValidator.getValidMoves(boardState);
  }

  List<List<bool>> getValidMovesForPiece(int row, int col) {
    return MoveValidator.getValidMovesFromPiece(boardState, row, col);
  }
}
