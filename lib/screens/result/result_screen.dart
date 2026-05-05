import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:solo_test/core/constants/app_colors.dart';
import 'package:solo_test/core/constants/app_text_styles.dart';
import 'package:solo_test/models/game_result.dart';

class ResultScreen extends StatelessWidget {
  final GameResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isWin = result.remainingPieces == 1;
    final heroColor = isWin ? AppColors.warningColor : AppColors.primaryColor;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    heroColor.withOpacity(0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentColor.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: heroColor.withOpacity(0.1),
                            border: Border.all(
                              color: heroColor.withOpacity(0.45),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: heroColor.withOpacity(0.3),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isWin ? '🏆' : '🎮',
                              style: const TextStyle(fontSize: 52),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: isWin
                                ? [AppColors.warningColor, const Color(0xFFFBBF24)]
                                : [AppColors.primaryLight, AppColors.accentColor],
                          ).createShader(bounds),
                          child: Text(
                            result.grade,
                            style: AppTextStyles.heading1.copyWith(
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${result.score} PUAN',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _ResultCard(
                          label: 'Kalan Piyon',
                          value: result.remainingPieces.toString(),
                          icon: Icons.circle,
                          color: AppColors.piecePrimary,
                        ),
                        const SizedBox(height: 10),
                        _ResultCard(
                          label: 'Toplam Hamle',
                          value: result.totalMoves.toString(),
                          icon: Icons.swap_horiz_rounded,
                          color: AppColors.accentColor,
                        ),
                        const SizedBox(height: 10),
                        _ResultCard(
                          label: 'Süre',
                          value: _formatDuration(result.gameDuration),
                          icon: Icons.timer_outlined,
                          color: AppColors.successColor,
                        ),
                        const SizedBox(height: 10),
                        _ResultCard(
                          label: 'Tarih',
                          value: _formatDateTime(result.playedAt),
                          icon: Icons.calendar_today_outlined,
                          color: AppColors.warningColor,
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryColor, AppColors.primaryDark],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.38),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: TextButton.icon(
                              onPressed: () =>
                                  Navigator.of(context).pushReplacementNamed('/game'),
                              icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 22),
                              label: const Text(
                                'TEKRAR OYNA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.glassColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: AppColors.glassBorder),
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pushReplacementNamed('/'),
                                icon: Icon(
                                  Icons.home_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResultCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: AppTextStyles.labelSmall),
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
