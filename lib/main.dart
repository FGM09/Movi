import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/event_list_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init info: $e');
  }
  runApp(const MoviApp());
}

class MoviApp extends StatelessWidget {
  const MoviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7), // Deep Purple / Violet accent
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.isAuthenticated) {
      return const EventListScreen();
    } else {
      return const LoginScreen();
    }
  }
}
