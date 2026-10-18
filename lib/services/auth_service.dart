import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AppUser? _currentUser;
  final List<Map<String, String>> _registeredUsers = [
    {
      'name': 'Carlos Silva',
      'email': 'carlos@movi.com',
      'password': '123456'
    },
    {
      'name': 'Ana Oliveira',
      'email': 'ana@movi.com',
      'password': '123456'
    },
  ];

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  String? login(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final userMap = _registeredUsers.firstWhere(
      (u) => u['email'] == cleanEmail && u['password'] == password,
      orElse: () => {},
    );

    if (userMap.isNotEmpty) {
      _currentUser = AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: userMap['name']!,
        email: userMap['email']!,
      );
      notifyListeners();
      return null;
    } else {
      return 'E-mail ou senha incorretos.';
    }
  }

  String? register(String name, String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    if (_registeredUsers.any((u) => u['email'] == cleanEmail)) {
      return 'E-mail já cadastrado.';
    }

    _registeredUsers.add({
      'name': name.trim(),
      'email': cleanEmail,
      'password': password,
    });

    _currentUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: cleanEmail,
    );
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
