import 'package:flutter/material.dart';
import 'package:solo_test/core/constants/app_constants.dart';
import 'package:solo_test/core/constants/app_colors.dart';
import 'package:solo_test/core/constants/app_text_styles.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Kurallar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Oyun Kuralları', style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              Text(
                '• Tahta boyutu: ${AppConstants.BOARD_SIZE}x${AppConstants.BOARD_SIZE}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Başlangıçta piyon sayısı: ${AppConstants.INITIAL_PIECES}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Amaç: Tahtadaki tüm piyonları kaldırıp son piyonun ortada kalmasını sağlamak (hedef: ${AppConstants.TARGET_PIECES} piyona düşürmek).',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text('Puanlama', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    AppConstants.SCORE_GRADES.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${entry.key} → ${entry.value} (${AppConstants.SCORE_POINTS[entry.key] ?? 0} pts)',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              Text('İpuçları', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                '''• Kenarlardaki hamleleri dikkatli planlayın.
• Bir bölgeyi izole etmeden önce alternatif hamleleri gözden geçirin.
• Son hamleleri saklamak için orta alanı boş bırakmaya çalışın.''',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
