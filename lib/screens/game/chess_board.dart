import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/models/board_state.dart';
import 'package:solo_test/models/game_theme_model.dart';
import 'package:solo_test/models/piece.dart';
import 'package:solo_test/providers/theme_provider.dart';

import 'chess_piece.dart';

class ChessBoard extends StatefulWidget {
  final BoardState boardState;
  final int? selectedRow;
  final int? selectedCol;
  final List<List<bool>> validMoves;
  final Function(int, int) onPieceSelected;
  final Function(int, int, int, int) onMoveMade;

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

class _DragPieceData {
  final int row;
  final int col;
  const _DragPieceData({required this.row, required this.col});
}

class _ChessBoardState extends State<ChessBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  int? _draggingRow;
  int? _draggingCol;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool _isDragTarget(int row, int col) =>
      widget.selectedRow != null && widget.validMoves[row][col];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().themeData;
    final boardSize = widget.boardState.board.length;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.boardBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.boardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.22),
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
                final isTarget = _isDragTarget(row, col);
                final isDraggingSource =
                    _draggingRow == row && _draggingCol == col;

                final pieceWidget =
                    piece.isPeg && isValid
                        ? Draggable<_DragPieceData>(
                          data: _DragPieceData(row: row, col: col),
                          dragAnchorStrategy: pointerDragAnchorStrategy,
                          onDragStarted: () {
                            setState(() {
                              _draggingRow = row;
                              _draggingCol = col;
                            });
                            widget.onPieceSelected(row, col);
                          },
                          onDraggableCanceled: (_, __) {
                            if (mounted)
                              setState(() {
                                _draggingRow = null;
                                _draggingCol = null;
                              });
                          },
                          onDragEnd: (_) {
                            if (mounted)
                              setState(() {
                                _draggingRow = null;
                                _draggingCol = null;
                              });
                          },
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 62,
                              height: 62,
                              child: ChessPiece(
                                piece: piece,
                                isSelected: true,
                                isDragging: true,
                                themeData: theme,
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.2,
                            child: ChessPiece(
                              piece: piece,
                              isSelected: isSelected,
                              isDragging: isDraggingSource,
                              themeData: theme,
                            ),
                          ),
                          child: ChessPiece(
                            piece: piece,
                            isSelected: isSelected,
                            isDragging: isDraggingSource,
                            themeData: theme,
                          ),
                        )
                        : null;

                final cell = GestureDetector(
                  onTap: () {
                    if (piece.isPeg && isValid) {
                      widget.onPieceSelected(row, col);
                      return;
                    }
                    if (isTarget &&
                        widget.selectedRow != null &&
                        widget.selectedCol != null) {
                      widget.onMoveMade(
                        widget.selectedRow!,
                        widget.selectedCol!,
                        row,
                        col,
                      );
                    }
                  },
                  child: _BoardCell(
                    isValid: isValid,
                    isSelected: isSelected,
                    isValidMove: isTarget,
                    pulseValue: _pulseAnim.value,
                    theme: theme,
                    child: pieceWidget,
                  ),
                );

                if (!isTarget) return cell;

                return DragTarget<_DragPieceData>(
                  onWillAcceptWithDetails:
                      (details) =>
                          details.data.row == widget.selectedRow &&
                          details.data.col == widget.selectedCol,
                  onAcceptWithDetails: (details) {
                    widget.onMoveMade(
                      details.data.row,
                      details.data.col,
                      row,
                      col,
                    );
                  },
                  builder: (context, candidateData, rejectedData) {
                    return _BoardCell(
                      isValid: isValid,
                      isSelected: isSelected,
                      isValidMove: true,
                      pulseValue:
                          candidateData.isNotEmpty ? 1.0 : _pulseAnim.value,
                      isDragHover: candidateData.isNotEmpty,
                      theme: theme,
                      child: cell,
                    );
                  },
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
  final bool isDragHover;
  final double pulseValue;
  final GameThemeData theme;
  final Widget? child;

  const _BoardCell({
    required this.isValid,
    required this.isSelected,
    required this.isValidMove,
    required this.pulseValue,
    required this.theme,
    this.isDragHover = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isValid) {
      return Container(
        decoration: BoxDecoration(
          color: theme.boardEmpty,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    if (isValidMove) {
      return Container(
        decoration: BoxDecoration(
          color: theme.validMoveColor.withOpacity(
            isDragHover ? 0.2 : 0.06 + pulseValue * 0.08,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.validMoveColor.withOpacity(
              isDragHover ? 1.0 : pulseValue * 0.9,
            ),
            width: isDragHover ? 2.2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.validMoveColor.withOpacity(
                isDragHover ? 0.32 : pulseValue * 0.22,
              ),
              blurRadius: isDragHover ? 14 : 10,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (child != null) child!,
            Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.validMoveColor.withOpacity(
                    isDragHover ? 1.0 : pulseValue * 0.75,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isSelected) {
      return Container(
        decoration: BoxDecoration(
          color: theme.pieceSelected.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.pieceSelected.withOpacity(0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.pieceSelected.withOpacity(0.3),
              blurRadius: 12,
            ),
          ],
        ),
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.boardHole,
        shape: BoxShape.circle,
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
