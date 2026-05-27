import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/core/constants/app_constants.dart';
import 'package:solo_test/core/constants/app_text_styles.dart';
import 'package:solo_test/logic/game_engine.dart';
import 'package:solo_test/repositories/game_history_repository.dart';
import 'package:solo_test/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/providers/stats_provider.dart';
import 'package:solo_test/models/game_theme_model.dart';
import 'package:solo_test/providers/theme_provider.dart';
import 'package:solo_test/widgets/particle_overlay.dart';

import 'chess_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameEngine gameEngine;
  int? selectedRow;
  int? selectedCol;
  List<List<bool>> validMoves = [];
  bool _isResumed = false;

  // Celebration animation when piece is removed
  late AnimationController _celebCtrl;

  List<List<bool>> _emptyMoves() {
    final boardSize = gameEngine.boardState.board.length;
    return List.generate(
      boardSize,
      (i) => List.generate(boardSize, (j) => false),
    );
  }

  @override
  void initState() {
    super.initState();
    final theme = context.read<ThemeProvider>().currentTheme;
    gameEngine = GameEngine(currentTheme: theme);
    // Don't call initializeGame immediately — wait until we know whether we're
    // resuming an existing game. initializeGame creates a new GameHistory
    // entry; calling it before checking resume args produced orphan in-progress
    // entries. We'll initialize below when we know the navigation args.
    validMoves = _emptyMoves();

    // If this screen was opened with resume args, load the saved board
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['resume'] == true && args['gameId'] != null) {
        final gh = GameHistoryRepository().getGame(args['gameId']);
        if (gh != null) {
          final board = GameHistoryRepository().boardStateFromJson(
            gh.boardJson,
          );
          setState(() {
            gameEngine.boardState = board;
            gameEngine.moveHistory = board.moveHistory;
            gameEngine.currentGameId = gh.gameId;
            validMoves = _emptyMoves();
            _isResumed = true;
          });
        }
      } else {
        // No resume: start a new game and create its history record.
        gameEngine.initializeGame(theme: theme);
        setState(() {
          validMoves = _emptyMoves();
        });
      }
    });

    _celebCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _celebCtrl.dispose();
    super.dispose();
  }

  void _clearSelection() {
    selectedRow = null;
    selectedCol = null;
    validMoves = _emptyMoves();
  }

  void _selectPiece(int row, int col) {
    final piece = gameEngine.boardState.getPiece(row, col);
    if (!piece.isPeg) return;
    setState(() {
      if (selectedRow == row && selectedCol == col) {
        _clearSelection();
      } else {
        selectedRow = row;
        selectedCol = col;
        validMoves = gameEngine.getValidMovesForPiece(row, col);
      }
    });
  }

  void _movePiece(int fromRow, int fromCol, int toRow, int toCol) {
    if (!gameEngine.makeMove(fromRow, fromCol, toRow, toCol)) return;
    _celebCtrl.forward(from: 0); // little celebration burst
    setState(() {
      _clearSelection();
      if (gameEngine.isGameOver()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showGameOverDialog();
        });
      }
    });
  }

  Future<void> _showGameOverDialog() async {
    final result = gameEngine.endGame();
    // persist result for stats
    try {
      await StorageService().saveGameResult(result);
      // Ensure any completed Hive history entries are imported so
      // SharedPreferences and stats reflect the latest completed games.
      try {
        await StorageService().importCompletedFromHive();
      } catch (_) {}
      // refresh provider so top-bar updates
      try {
        await context.read<StatsProvider>().load();
      } catch (_) {}
    } catch (_) {}
    final theme = context.read<ThemeProvider>().themeData;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: theme.surfaceLight.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.borderGlow, width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'OYUN BİTTİ',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceLight.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: theme.primaryLight.withOpacity(0.22),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          result.grade,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: theme.primaryColor.withOpacity(0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _DialogStat(
                        label: 'Puan',
                        value: result.score.toString(),
                        color: theme.accentColor,
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _DialogStat(
                        label: 'Kalan Piyon',
                        value: result.remainingPieces.toString(),
                        color: theme.primaryLight,
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _DialogStat(
                        label: 'Toplam Hamle',
                        value: result.totalMoves.toString(),
                        color: theme.accentColor,
                        theme: theme,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: [theme.primaryColor, theme.primaryDark],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                final theme =
                                    context.read<ThemeProvider>().currentTheme;
                                gameEngine.initializeGame(theme: theme);
                                _clearSelection();
                              });
                            },
                            icon: const Icon(
                              Icons.replay_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
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
                            // Close dialog
                            Navigator.pop(context);
                            if (_isResumed) {
                              // If this screen was opened to resume a game,
                              // go to the main menu instead of returning to
                              // the previous (History) screen.
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/home',
                                (route) => false,
                              );
                            } else {
                              // Default: pop the game screen and return to
                              // previous route.
                              Navigator.pop(context);
                            }
                          },
                          icon: Icon(
                            Icons.home_outlined,
                            color: theme.textSecondary,
                            size: 18,
                          ),
                          label: Text(
                            'ANA MENÜ',
                            style: TextStyle(
                              color: theme.textSecondary,
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
    final theme = context.watch<ThemeProvider>().themeData;
    final isLight = theme.backgroundColor.computeLuminance() > 0.5;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          // --- Background glow ---
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.backgroundGlow1.withOpacity(isLight ? 0.15 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.backgroundGlow2.withOpacity(isLight ? 0.12 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // --- Floating particles (behind board) ---
          Positioned.fill(
            child: IgnorePointer(
              child: ParticleOverlay(themeData: theme, count: 10),
            ),
          ),

          // --- Main UI ---
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      _BarButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () => Navigator.pop(context),
                        theme: theme,
                      ),
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                theme.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                theme.name,
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _BarButton(
                        icon: Icons.undo_rounded,
                        onPressed:
                            gameEngine.moveHistory.isEmpty
                                ? null
                                : () {
                                  setState(() {
                                    gameEngine.undoLastMove();
                                    _clearSelection();
                                  });
                                },
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'KALAN PİYON',
                          value:
                              gameEngine.boardState.remainingPieces.toString(),
                          icon: theme.useAssetPiece ? null : Icons.circle,
                          emojiIcon:
                              theme.useAssetPiece ? theme.pieceEmoji : null,
                          color: theme.piecePrimary,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          label: 'HAMLE',
                          value: gameEngine.moveHistory.length.toString(),
                          icon: Icons.swap_horiz_rounded,
                          color: theme.accentColor,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

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
  final GameThemeData theme;

  const _BarButton({required this.icon, required this.theme, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.glassColor,
        border: Border.all(color: theme.glassBorder),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: onPressed == null ? theme.textSecondary : theme.textPrimary,
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
  final IconData? icon;
  final String? emojiIcon;
  final Color color;
  final GameThemeData theme;

  const _InfoCard({
    required this.label,
    required this.value,
    this.icon,
    this.emojiIcon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderLight),
        boxShadow: [BoxShadow(color: color.withOpacity(0.07), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Center(
              child:
                  emojiIcon != null
                      ? Text(emojiIcon!, style: const TextStyle(fontSize: 18))
                      : Icon(icon, color: color, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
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
  final GameThemeData theme;

  const _DialogStat({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surfaceColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: theme.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
