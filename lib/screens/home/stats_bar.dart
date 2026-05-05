import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/core/constants/app_colors.dart';
import 'package:solo_test/core/constants/app_text_styles.dart';
import 'package:solo_test/services/storage_service.dart';
import 'package:solo_test/providers/auth_provider.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: 'EN İYİ',
                          value: _storage.getBestScore().toString(),
                          icon: Icons.star_rounded,
                          color: AppColors.warningColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 38,
                        color: AppColors.glassBorder,
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'OYUNLAR',
                          value: _storage.getGamesPlayed().toString(),
                          icon: Icons.sports_esports_rounded,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 38,
                        color: AppColors.glassBorder,
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'ORTALAMA',
                          value: _storage.getAverageScore().toStringAsFixed(0),
                          icon: Icons.trending_up_rounded,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.glassColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.logout,
                                color: AppColors.errorColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Çıkış Yap',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.errorColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                  offset: const Offset(0, 50),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
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
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
            fontSize: 20,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
