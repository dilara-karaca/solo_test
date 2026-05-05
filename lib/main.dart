import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_test/core/theme/app_theme.dart';
import 'package:solo_test/providers/settings_provider.dart';
import 'package:solo_test/providers/auth_provider.dart';
import 'package:solo_test/screens/home/home_screen.dart';
import 'package:solo_test/screens/game/game_screen.dart';
import 'package:solo_test/screens/auth/login_screen.dart';
import 'package:solo_test/screens/auth/register_screen.dart';
import 'package:solo_test/screens/rules/rules_screen.dart';
import 'package:solo_test/screens/settings/settings_screen.dart';
import 'package:solo_test/services/storage_service.dart';
import 'package:solo_test/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.initialize();

  final authService = AuthService();
  await authService.initialize();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Solo Test',
        theme: AppTheme.darkTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        home: const _AuthWrapper(),
        routes: {
          '/game': (context) => const GameScreen(),
          '/login':
              (context) => LoginScreen(
                authProvider: context.read<AuthProvider>(),
                onLoginSuccess: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              ),
          '/register':
              (context) => RegisterScreen(
                authProvider: context.read<AuthProvider>(),
                onRegisterSuccess: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              ),
          '/home': (context) => const HomeScreen(),
          '/rules': (context) => const RulesScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFF070712),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Yükleniyor...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        return LoginScreen(
          authProvider: authProvider,
          onLoginSuccess: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        );
      },
    );
  }
}
