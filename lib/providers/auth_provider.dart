import 'package:flutter/material.dart';
import 'package:solo_test/models/user.dart';
import 'package:solo_test/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._authService) {
    _initializeAuth();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void _initializeAuth() {
    _authService.authStateStream.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.register(
        email: email,
        username: username,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
