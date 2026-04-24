import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ari makuha ang input sa user
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: Color(0xFF2A2A2A),
      body: Stack(
        children: [
          Positioned(
            top: -30,
            left: 40,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 231, 230, 230),
                borderRadius: BorderRadius.circular(180),
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: 70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(140),
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(120),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -75,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(160),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -75,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(160),
              ),
            ),
          ),
          // Toonify header, usba ang position ari.
          Positioned(
            top: 37,
            left: 5,
            child: Row(
              children: [
                Text(
                  'Toonify',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 37,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                CustomPaint(
                  size: Size(38, 38),
                  painter: MoonPainter(),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 180),
                  Center( // Ari usba ang position sa Log in text
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                  SizedBox(height: 40), // SPACE nila duha
                  TextField( // Mao ni sa EMAIL
                    controller: emailCtrl,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF454545),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25), // Ari usba ang border radius
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 30), // Kani pud
                  TextField( // Mao ni sa PASSWORD
                    controller: passwordCtrl,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF454545),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25), // Ari usba ang border radius
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 45), // Mao ni sa SIGN IN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Ari e check kung sakto ba ang credentials
                        if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fill in the fields first.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (AuthService.login(emailCtrl.text, passwordCtrl.text)) {
                          Navigator.pushAndRemoveUntil( // If sakto lahus sa Homescreen
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        } else {
                          // Kung sayop ang credentials
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Wrong email or password'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Sa Forgot Password
                  GestureDetector(
                    onTap: () {
                      // Navigate sa Forgot Password screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(height: 6), // Sa Create Account
                  GestureDetector(
                    onTap: () {
                      // Navigate sa Register screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoonPainter extends CustomPainter { // Mao ni ang Moon, nawng ni burlas ibutang.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.85);
    final path = Path();
    path.addOval(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.5),
        radius: size.width * 0.45));
    final cutPath = Path();
    cutPath.addOval(Rect.fromCircle(
        center: Offset(size.width * 0.72, size.height * 0.38),
        radius: size.width * 0.38));
    canvas.drawPath(
        Path.combine(PathOperation.difference, path, cutPath), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}