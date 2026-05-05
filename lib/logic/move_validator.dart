import 'package:solo_test/models/board_state.dart';

class MoveValidator {
  static bool isValidMove(
    BoardState boardState,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) {
    // Check if from position is valid
    if (!boardState.isValidPosition(fromRow, fromCol)) {
      return false;
    }

    // Check if to position is valid
    if (!boardState.isValidPosition(toRow, toCol)) {
      return false;
    }

    // Check if from position has a peg
    final fromPiece = boardState.getPiece(fromRow, fromCol);
    if (!fromPiece.isPeg) {
      return false;
    }

    // Check if to position is empty
    final toPiece = boardState.getPiece(toRow, toCol);
    if (toPiece.isPeg) {
      return false;
    }

    // Check if move is 2 spaces away (horizontally or vertically)
    final rowDiff = (toRow - fromRow).abs();
    final colDiff = (toCol - fromCol).abs();

    if (!((rowDiff == 2 && colDiff == 0) || (rowDiff == 0 && colDiff == 2))) {
      return false;
    }

    // Check if there's a peg in the middle to capture
    final midRow = (fromRow + toRow) ~/ 2;
    final midCol = (fromCol + toCol) ~/ 2;
    final midPiece = boardState.getPiece(midRow, midCol);

    if (!midPiece.isPeg) {
      return false;
    }

    return true;
  }

  static List<List<bool>> getValidMoves(BoardState boardState) {
    final boardSize = boardState.board.length;
    final validMoves = List.generate(
      boardSize,
      (i) => List.generate(boardSize, (j) => false),
    );

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final piece = boardState.getPiece(row, col);
        if (piece.isPeg) {
          // Check all four directions
          final directions = [
            (row - 2, col), // Up
            (row + 2, col), // Down
            (row, col - 2), // Left
            (row, col + 2), // Right
          ];

          for (var (toRow, toCol) in directions) {
            if (isValidMove(boardState, row, col, toRow, toCol)) {
              validMoves[toRow][toCol] = true;
            }
          }
        }
      }
    }

    return validMoves;
  }

  static bool hasValidMoves(BoardState boardState) {
    final validMoves = getValidMoves(boardState);
    for (var row in validMoves) {
      for (var hasMove in row) {
        if (hasMove) {
          return true;
        }
      }
    }
    return false;
  }
}
