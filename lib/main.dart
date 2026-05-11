import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AuthService.init();
  runApp(const ToonifyApp());
}

class ToonifyApp extends StatelessWidget {
  const ToonifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Toonify',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF2A2A2A),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              surface: Color(0xFF2A2A2A),
            ),
            fontFamily: 'serif',
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

// Mo check if naka login naba ta before
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {

    await Future.delayed(const Duration(seconds: 1));

    _user = FirebaseAuth.instance.currentUser;

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF2A2A2A),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_user != null) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}