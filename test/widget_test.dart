import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solo_test/main.dart';
import 'package:solo_test/services/auth_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final authService = AuthService();
    await authService.initialize();

    await tester.pumpWidget(MyApp(authService: authService));

    // Note: The actual test would depend on the app's current UI
    // For now, just verify the app builds without crashing
    expect(find.byType(Scaffold), findsWidgets);
  });
}
