import 'package:flutter/material.dart';
import 'package:solo_test/models/board_state.dart';
import 'package:solo_test/core/constants/app_colors.dart';
import 'chess_piece.dart';

class ChessBoard extends StatefulWidget {
  final BoardState boardState;
  final int? selectedRow;
  final int? selectedCol;
  final List<List<bool>> validMoves;
  final Function(int, int) onPieceSelected;
  final Function(int, int) onMoveMade;

  const ChessBoard({
    super.key,
    required this.boardState,
    required this.selectedRow,
    required this.selectedCol,
    required this.validMoves,
    required this.onPieceSelected,
    required this.onMoveMade,
  });

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = widget.boardState.board.length;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.boardBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.boardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.22),
              blurRadius: 32,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, _) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boardSize,
                childAspectRatio: 1,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: boardSize * boardSize,
              itemBuilder: (context, index) {
                final row = index ~/ boardSize;
                final col = index % boardSize;
                final piece = widget.boardState.getPiece(row, col);
                final isValid = widget.boardState.isValidPosition(row, col);
                final isSelected =
                    widget.selectedRow == row && widget.selectedCol == col;
                final isValidMove =
                    widget.validMoves[row][col] && widget.selectedRow != null;

                return GestureDetector(
                  onTap: () {
                    if (isSelected || (piece.isPeg && isValid)) {
                      widget.onPieceSelected(row, col);
                    } else if (isValidMove) {
                      widget.onMoveMade(row, col);
                    }
                  },
                  child: _BoardCell(
                    isValid: isValid,
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    pulseValue: _pulseAnim.value,
                    child: piece.isPeg && isValid
                        ? ChessPiece(piece: piece, isSelected: isSelected)
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  final bool isValid;
  final bool isSelected;
  final bool isValidMove;
  final double pulseValue;
  final Widget? child;

  const _BoardCell({
    required this.isValid,
    required this.isSelected,
    required this.isValidMove,
    required this.pulseValue,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isValid) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.boardEmpty,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    if (isValidMove) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.validMoveColor.withOpacity(0.06 + pulseValue * 0.08),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: AppColors.validMoveColor.withOpacity(pulseValue * 0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.validMoveColor.withOpacity(pulseValue * 0.22),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.validMoveColor.withOpacity(pulseValue * 0.75),
            ),
          ),
        ),
      );
    }

    if (isSelected) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.pieceSelected.withOpacity(0.12),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: AppColors.pieceSelected.withOpacity(0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.pieceSelected.withOpacity(0.3),
              blurRadius: 12,
            ),
          ],
        ),
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.boardHole,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
