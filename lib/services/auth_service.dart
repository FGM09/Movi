import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initFirebaseAndLocalSession();
  }

  static const String _usersKey = 'movi_saved_users';
  static const String _currentSessionKey = 'movi_current_user';

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
  List<Map<String, String>> get registeredUsers => List.unmodifiable(_registeredUsers);

  void _initFirebaseAndLocalSession() {
    try {
      fb.FirebaseAuth.instance.authStateChanges().listen((fb.User? user) {
        if (user != null) {
          _currentUser = AppUser(
            id: user.uid,
            name: user.displayName ?? user.email?.split('@').first ?? 'Usuário',
            email: user.email ?? '',
          );
          _persistLocalData();
          notifyListeners();
        }
      });
    } catch (_) {}

    _loadLocalSavedUsersAndSession();
  }

  Future<void> _loadLocalSavedUsersAndSession() async {
    final prefs = await SharedPreferences.getInstance();

    final String? usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(usersJson);
        for (var item in decoded) {
          final map = Map<String, String>.from(item);
          if (!_registeredUsers.any((u) => u['email'] == map['email'])) {
            _registeredUsers.add(map);
          }
        }
      } catch (_) {}
    }

    final String? sessionJson = prefs.getString(_currentSessionKey);
    if (_currentUser == null && sessionJson != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(sessionJson);
        _currentUser = AppUser(
          id: map['id'] ?? '',
          name: map['name'] ?? '',
          email: map['email'] ?? '',
        );
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> _persistLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(_registeredUsers));

    if (_currentUser != null) {
      await prefs.setString(
        _currentSessionKey,
        jsonEncode({
          'id': _currentUser!.id,
          'name': _currentUser!.name,
          'email': _currentUser!.email,
        }),
      );
    } else {
      await prefs.remove(_currentSessionKey);
    }
  }

  /// Salva informações do usuário no Cloud Firestore do Firebase
  Future<void> _saveUserToFirestore(String uid, String name, String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'authProvider': 'email',
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save info: $e');
    }
  }

  /// Login com o Google + Autenticação no Firebase Auth + Gravação no Cloud Firestore
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null; // Usuário cancelou
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb.UserCredential userCredential =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        _currentUser = AppUser(
          id: user.uid,
          name: user.displayName ?? googleUser.displayName ?? 'Usuário Google',
          email: user.email ?? googleUser.email,
        );

        // Salva os dados completos do login do Google no Cloud Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _currentUser!.name,
          'email': _currentUser!.email,
          'photoUrl': user.photoURL ?? googleUser.photoUrl,
          'authProvider': 'google.com',
          'created_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _persistLocalData();
        notifyListeners();
        return null; // Sucesso
      }
    } catch (e) {
      debugPrint('Erro detalhado Google Sign-In: $e');
      if (e.toString().contains('10') || e.toString().contains('ApiException')) {
        return 'Chave SHA-1 não cadastrada no Firebase. Adicione a SHA-1 do app no Firebase Console.';
      }
      return 'Erro no Google Sign-In ($e). Verifique se o Google está ativado no Firebase Console.';
    }
    return 'Falha ao conectar com o Google.';
  }

  /// Login com suporte a Firebase Auth + fallback local
  Future<String?> loginAsync(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    try {
      final credential = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        _currentUser = AppUser(
          id: user.uid,
          name: user.displayName ?? user.email?.split('@').first ?? 'Usuário',
          email: user.email ?? cleanEmail,
        );
        await _saveUserToFirestore(user.uid, _currentUser!.name, cleanEmail);
        await _persistLocalData();
        notifyListeners();
        return null;
      }
    } catch (_) {}

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
      await _persistLocalData();
      notifyListeners();
      return null;
    } else {
      return 'E-mail ou senha incorretos.';
    }
  }

  String? login(String email, String password) {
    loginAsync(email, password);
    return null;
  }

  /// Cadastro com suporte a Firebase Auth + Firestore
  Future<String?> registerAsync(String name, String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    try {
      final credential = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());

        _currentUser = AppUser(
          id: user.uid,
          name: name.trim(),
          email: cleanEmail,
        );

        await _saveUserToFirestore(user.uid, name.trim(), cleanEmail);

        _registeredUsers.add({
          'name': name.trim(),
          'email': cleanEmail,
          'password': password,
        });

        await _persistLocalData();
        notifyListeners();
        return null;
      }
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'E-mail já cadastrado no Firebase.';
      } else if (e.code == 'weak-password') {
        return 'A senha é muito fraca. Escolha no mínimo 6 caracteres.';
      }
    } catch (_) {}

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

    await _persistLocalData();
    notifyListeners();
    return null;
  }

  String? register(String name, String email, String password) {
    registerAsync(name, email, password);
    return null;
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await fb.FirebaseAuth.instance.signOut();
    } catch (_) {}
    _currentUser = null;
    await _persistLocalData();
    notifyListeners();
  }
}
