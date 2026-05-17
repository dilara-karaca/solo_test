import 'dart:math';
import 'package:solo_test/core/constants/app_constants.dart';
import 'package:solo_test/models/game_theme_model.dart';
import 'piece.dart';

class BoardState {
  final List<List<Piece>> board;
  final int remainingPieces;
  final List<Map<String, int>> moveHistory;

  BoardState({
    required this.board,
    required this.remainingPieces,
    this.moveHistory = const [],
  });

  factory BoardState.initial(int boardSize, {GameTheme? theme}) {
    final random = Random();
    final board = List.generate(
      boardSize,
      (row) => List.generate(boardSize, (col) {
        // Create English Solitaire board (7x7)
        // Corner positions are invalid (off the board)
        if ((row < 2 || row > 4) && (col < 2 || col > 4)) {
          return Piece(row: row, column: col, isPeg: false);
        }
        // Center position is empty (hole)
        if (row == 3 && col == 3) {
          return Piece(row: row, column: col, isPeg: false);
        }
        // All other positions have pegs
        return Piece(row: row, column: col, isPeg: true);
      }),
    );

    final pegPositions = <(int, int)>[];
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if (board[row][col].isPeg) {
          pegPositions.add((row, col));
        }
      }
    }

    void assignRandomVariants(int variantCount) {
      final variants = <int>[];
      final piecesPerType = (pegPositions.length / variantCount).ceil();
      for (int i = 0; i < variantCount; i++) {
        variants.addAll(List.filled(piecesPerType, i));
      }
      variants.shuffle(random);

      for (int i = 0; i < pegPositions.length; i++) {
        final (row, col) = pegPositions[i];
        board[row][col] = board[row][col].copyWith(pieceVariant: variants[i]);
      }
    }

    void assignAlternatingVariants() {
      for (final (row, col) in pegPositions) {
        board[row][col] = board[row][col].copyWith(
          pieceVariant: (row + col) % 2,
        );
      }
    }

    switch (theme) {
      case GameTheme.fruits:
        assignRandomVariants(5);
        break;
      case GameTheme.powerpuffGirls:
        assignRandomVariants(3);
        break;
      case GameTheme.stitch:
        assignRandomVariants(2);
        break;
      case GameTheme.sungerbob:
        assignAlternatingVariants();
        break;
      default:
        break;
    }

    return BoardState(
      board: board,
      remainingPieces: AppConstants.INITIAL_PIECES,
      moveHistory: [],
    );
  }

  Piece getPiece(int row, int col) {
    if (row < 0 || row >= board.length || col < 0 || col >= board[0].length) {
      return Piece(row: row, column: col, isPeg: false);
    }
    return board[row][col];
  }

  bool isValidPosition(int row, int col) {
    if (row < 0 || row >= board.length || col < 0 || col >= board[0].length) {
      return false;
    }
    // Corner positions are invalid
    if ((row < 2 || row > 4) && (col < 2 || col > 4)) {
      return false;
    }
    return true;
  }

  BoardState copyWith({
    List<List<Piece>>? board,
    int? remainingPieces,
    List<Map<String, int>>? moveHistory,
  }) {
    return BoardState(
      board: board ?? this.board,
      remainingPieces: remainingPieces ?? this.remainingPieces,
      moveHistory: moveHistory ?? this.moveHistory,
    );
  }
}
