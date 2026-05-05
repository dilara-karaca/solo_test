import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/core/constants/app_colors.dart';
import 'package:solo_test/core/constants/app_text_styles.dart';
import 'package:solo_test/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ses', style: AppTextStyles.heading3),
              SwitchListTile(
                value: settings.soundEnabled,
                onChanged: (v) => settings.toggleSound(),
                activeColor: AppColors.primaryColor,
                title: Text('Ses efektleri', style: AppTextStyles.bodyMedium),
              ),
              const SizedBox(height: 8),
              Text('Titreşim', style: AppTextStyles.heading3),
              SwitchListTile(
                value: settings.vibrationEnabled,
                onChanged: (v) => settings.toggleVibration(),
                activeColor: AppColors.primaryColor,
                title: Text('Titreşim', style: AppTextStyles.bodyMedium),
              ),
              const SizedBox(height: 8),
              Text('Zorluk', style: AppTextStyles.heading3),
              const SizedBox(height: 6),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Kolay'),
                    selected: settings.difficulty == 1,
                    onSelected: (_) => settings.setDifficulty(1),
                    selectedColor: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Orta'),
                    selected: settings.difficulty == 2,
                    onSelected: (_) => settings.setDifficulty(2),
                    selectedColor: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Zor'),
                    selected: settings.difficulty == 3,
                    onSelected: (_) => settings.setDifficulty(3),
                    selectedColor: AppColors.primaryDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ayarlar kaydedildi')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: Text(
                  'Kaydet',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
