import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_test/models/user.dart';
import 'dart:convert';
import 'dart:async';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  late SharedPreferences _prefs;

  User? _currentUser;
  final _authStateController = StreamController<User?>.broadcast();

  Stream<User?> get authStateStream => _authStateController.stream;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
        _authStateController.add(_currentUser);
      } catch (e) {
        _currentUser = null;
        _authStateController.add(null);
      }
    }
  }

  Future<User> register({
    required String email,
    required String username,
    required String password,
  }) async {
    // Validate inputs
    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      throw Exception('Tüm alanlar gereklidir');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Geçersiz email adresi');
    }

    if (password.length < 6) {
      throw Exception('Şifre en az 6 karakter olmalıdır');
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Create new user
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      username: username,
      createdAt: DateTime.now(),
    );

    // Save user and token
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    await _prefs.setString(_tokenKey, _generateToken());

    _currentUser = user;
    _authStateController.add(_currentUser);

    return user;
  }

  Future<User> login({required String email, required String password}) async {
    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email ve şifre gereklidir');
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if user exists (for demo, we'll check stored user)
    final storedUserJson = _prefs.getString(_userKey);
    if (storedUserJson == null) {
      throw Exception('Kullanıcı bulunamadı');
    }

    try {
      final userMap = jsonDecode(storedUserJson) as Map<String, dynamic>;
      final user = User.fromJson(userMap);

      if (user.email != email) {
        throw Exception('Email veya şifre yanlış');
      }

      // In a real app, you would verify the password here
      await _prefs.setString(_tokenKey, _generateToken());

      _currentUser = user;
      _authStateController.add(_currentUser);

      return user;
    } catch (e) {
      throw Exception('Giriş başarısız: $e');
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_tokenKey);
    _currentUser = null;
    _authStateController.add(null);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  String _generateToken() {
    return 'token_${DateTime.now().millisecondsSinceEpoch}';
  }

  void dispose() {
    _authStateController.close();
  }
}
