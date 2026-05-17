import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/providers/theme_provider.dart';
import 'package:solo_test/services/storage_service.dart';

class StatsBar extends StatefulWidget {
  const StatsBar({super.key});

  @override
  State<StatsBar> createState() => _StatsBarState();
}

class _StatsBarState extends State<StatsBar> {
  late StorageService _storage;

  @override
  void initState() {
    super.initState();
    _storage = StorageService();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().themeData;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              color: theme.glassColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.glassBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'EN İYİ',
                    value: _storage.getBestScore().toString(),
                    icon: Icons.star_rounded,
                    color: const Color(0xFFF59E0B),
                    textColor: theme.textPrimary,
                    labelColor: theme.textSecondary,
                  ),
                ),
                Container(width: 1, height: 38, color: theme.glassBorder),
                Expanded(
                  child: _StatItem(
                    label: 'OYUNLAR',
                    value: _storage.getGamesPlayed().toString(),
                    icon: Icons.sports_esports_rounded,
                    color: theme.primaryLight,
                    textColor: theme.textPrimary,
                    labelColor: theme.textSecondary,
                  ),
                ),
                Container(width: 1, height: 38, color: theme.glassBorder),
                Expanded(
                  child: _StatItem(
                    label: 'ORTALAMA',
                    value: _storage.getAverageScore().toStringAsFixed(0),
                    icon: Icons.trending_up_rounded,
                    color: theme.accentColor,
                    textColor: theme.textPrimary,
                    labelColor: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color labelColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(color: labelColor, fontSize: 10, letterSpacing: 0.5),
        ),
      ],
    );
  }
}
