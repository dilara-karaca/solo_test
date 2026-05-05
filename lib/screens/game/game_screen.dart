import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:solo_test/core/constants/app_colors.dart';
import 'package:solo_test/core/constants/app_text_styles.dart';
import 'package:solo_test/logic/game_engine.dart';
import 'chess_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine gameEngine;
  int? selectedRow;
  int? selectedCol;
  List<List<bool>> validMoves = [];

  @override
  void initState() {
    super.initState();
    gameEngine = GameEngine();
    gameEngine.initializeGame();
    _updateValidMoves();
  }

  void _updateValidMoves() {
    setState(() {
      validMoves = gameEngine.getValidMovesForBoard();
    });
  }

  void _selectPiece(int row, int col) {
    final piece = gameEngine.boardState.getPiece(row, col);
    if (piece.isPeg) {
      setState(() {
        if (selectedRow == row && selectedCol == col) {
          selectedRow = null;
          selectedCol = null;
        } else {
          selectedRow = row;
          selectedCol = col;
        }
      });
    }
  }

  void _movePiece(int toRow, int toCol) {
    if (selectedRow == null || selectedCol == null) return;

    if (gameEngine.makeMove(selectedRow!, selectedCol!, toRow, toCol)) {
      setState(() {
        selectedRow = null;
        selectedCol = null;
        _updateValidMoves();
        if (gameEngine.isGameOver()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showGameOverDialog();
          });
        }
      });
    }
  }

  void _showGameOverDialog() {
    final result = gameEngine.endGame();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withOpacity(0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderGlow, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.12),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        result.remainingPieces == 1 ? '🏆' : '🎮',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'OYUN BİTTİ',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 20,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.grade,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DialogStat(
                    label: 'Puan',
                    value: result.score.toString(),
                    color: AppColors.warningColor,
                  ),
                  const SizedBox(height: 8),
                  _DialogStat(
                    label: 'Kalan Piyon',
                    value: result.remainingPieces.toString(),
                    color: AppColors.accentColor,
                  ),
                  const SizedBox(height: 8),
                  _DialogStat(
                    label: 'Toplam Hamle',
                    value: result.totalMoves.toString(),
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryColor, AppColors.primaryDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            gameEngine.initializeGame();
                            selectedRow = null;
                            selectedCol = null;
                            _updateValidMoves();
                          });
                        },
                        icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'TEKRAR OYNA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.home_outlined,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      label: Text(
                        'ANA MENÜ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Subtle background glow
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      _BarButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'OYUN',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 5,
                            ),
                          ),
                        ),
                      ),
                      _BarButton(
                        icon: Icons.undo_rounded,
                        onPressed: gameEngine.moveHistory.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  gameEngine.undoLastMove();
                                  selectedRow = null;
                                  selectedCol = null;
                                  _updateValidMoves();
                                });
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Info cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'KALAN PİYON',
                          value: gameEngine.boardState.remainingPieces.toString(),
                          icon: Icons.circle,
                          color: AppColors.piecePrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          label: 'HAMLE',
                          value: gameEngine.moveHistory.length.toString(),
                          icon: Icons.swap_horiz_rounded,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Board
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ChessBoard(
                      boardState: gameEngine.boardState,
                      selectedRow: selectedRow,
                      selectedCol: selectedCol,
                      validMoves: validMoves,
                      onPieceSelected: _selectPiece,
                      onMoveMade: _movePiece,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _BarButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.glassColor,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: onPressed == null ? AppColors.textTertiary : AppColors.textPrimary,
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 24,
                  letterSpacing: 0,
                ),
              ),
              Text(label, style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DialogStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
