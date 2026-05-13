import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/core/constants/app_constants.dart';
import 'package:solo_test/providers/theme_provider.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.themeData;

        return Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            title: Text(
              'Kurallar',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: theme.surfaceColor,
            elevation: 0,
            iconTheme: IconThemeData(color: theme.textPrimary),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Title
                  Text(
                    'Oyun Kuralları',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rules Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.borderLight, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• Tahta boyutu: ${AppConstants.BOARD_SIZE}x${AppConstants.BOARD_SIZE}',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textPrimary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Başlangıçta piyon sayısı: ${AppConstants.INITIAL_PIECES}',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textPrimary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Amaç: Tahtadaki tüm piyonları kaldırıp son piyonun ortada kalmasını sağlamak (hedef: ${AppConstants.TARGET_PIECES} piyona düşürmek).',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Scoring Section
                  Text(
                    'Puanlama',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scoring Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.borderLight, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _RuleScoreLine(
                          range: '1',
                          grade: 'BILGIN',
                          points: 200,
                        ),
                        _RuleScoreLine(range: '2', grade: 'ZEKI', points: 175),
                        _RuleScoreLine(
                          range: '3',
                          grade: 'KURNAZ',
                          points: 150,
                        ),
                        _RuleScoreLine(
                          range: '4',
                          grade: 'BASARILI',
                          points: 125,
                        ),
                        _RuleScoreLine(
                          range: '5',
                          grade: 'NORMAL',
                          points: 100,
                        ),
                        _RuleScoreLine(
                          range: '6',
                          grade: 'TECRUBESIZ',
                          points: 75,
                        ),
                        _RuleScoreLine(range: '7', grade: 'APTAL', points: 50),
                        _RuleScoreLine(
                          range: '8',
                          grade: 'GERIZEKALI',
                          points: 25,
                        ),
                        _RuleScoreLine(
                          range: '9+',
                          grade: 'BEYINSIZ',
                          points: 0,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tips Section
                  Text(
                    'İpuçları',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tips Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '• Kenarlardaki hamleleri dikkatli planlayın.\n'
                      '• Bir bölgeyi izole etmeden önce alternatif hamleleri gözden geçirin.\n'
                      '• Son hamleleri saklamak için orta alanı boş bırakmaya çalışın.',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textPrimary,
                        height: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RuleScoreLine extends StatelessWidget {
  final String range;
  final String grade;
  final int points;

  const _RuleScoreLine({
    required this.range,
    required this.grade,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.themeData;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$range kalan taş → $grade',
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$points puan',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
