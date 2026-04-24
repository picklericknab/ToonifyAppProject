import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ToonifyApp());
}

class ToonifyApp extends StatelessWidget {
  const ToonifyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const LoginScreen(),
    );
  }
}