import 'package:flutter/material.dart';
import 'package:solo_test/repositories/game_history_repository.dart';
import 'package:solo_test/models/game_history.dart';
import 'package:solo_test/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/providers/theme_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final GameHistoryRepository _repo = GameHistoryRepository();
  late List<GameHistory> _inProgress;
  late List<GameHistory> _completed;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final all = _repo.getAllGames();
    _inProgress = all.where((g) => g.gameStatus == 'inProgress').toList();
    _completed = all.where((g) => g.gameStatus != 'inProgress').toList();
    setState(() {});
  }

  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'bugün';
    if (diff.inDays == 1) return 'dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _buildTile(GameHistory g) {
    final theme = context.watch<ThemeProvider>().themeData;
    final status = g.gameStatus;
    final iconData =
        status == 'inProgress'
            ? Icons.play_arrow_rounded
            : (status == 'won'
                ? Icons.emoji_events_rounded
                : Icons.check_circle_outline);
    final iconColor =
        status == 'inProgress'
            ? theme.primaryColor
            : (status == 'won'
                ? theme.primaryLight
                : theme.primaryColor.withOpacity(0.85));
    final title =
        status == 'inProgress'
            ? 'Devam Et'
            : AppConstants.getGradeForRemainingPieces(g.remainingPegs);

    return Card(
      color: theme.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.borderLight),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: Icon(iconData, size: 28, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${g.remainingPegs} piyon • ${g.moveCount} hamle • ${_relativeDate(g.updatedAt)}',
          style: TextStyle(color: theme.textSecondary),
        ),
        trailing:
            status == 'inProgress'
                ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(
                      '/game',
                      arguments: {'resume': true, 'gameId': g.gameId},
                    );
                    _load();
                  },
                  child: const Text('Devam Et'),
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().themeData;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Oyun Geçmişi',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: theme.textPrimary),
        centerTitle: true,
        backgroundColor: theme.surfaceColor,
        elevation: 0,
        actions: [],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: ListView(
          padding: const EdgeInsets.only(top: 12),
          children: [
            if (_inProgress.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text(
                  'Devam Edenler',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._inProgress.map(_buildTile),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                'Tamamlananlar',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._completed.map(_buildTile),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
