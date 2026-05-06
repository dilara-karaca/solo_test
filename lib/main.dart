import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/core/theme/app_theme.dart';
import 'package:solo_test/providers/settings_provider.dart';
import 'package:solo_test/screens/home/home_screen.dart';
import 'package:solo_test/screens/game/game_screen.dart';
import 'package:solo_test/screens/rules/rules_screen.dart';
import 'package:solo_test/screens/settings/settings_screen.dart';
import 'package:solo_test/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Solo Test',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        home: const HomeScreen(),
        routes: {
          '/game': (context) => const GameScreen(),
          '/home': (context) => const HomeScreen(),
          '/rules': (context) => const RulesScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
