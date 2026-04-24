import 'package:flutter/material.dart';
import 'login_screen.dart';

class SuccessEmailScreen extends StatelessWidget {
  const SuccessEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Toonify header usba ang position ari
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
            child: Center( 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mao ni ang success circle 
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 20), // Space sa Success text
                  Text(
                    'Success',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12), // Space sa description
                  Text( // Mao ni ang description
                    'successfully sent a reset email link,\ncheck your mail to reset',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30), // Space sa Back to Login
                  GestureDetector(
                    onTap: () {
                      // Balik sa Login
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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

class MoonPainter extends CustomPainter { // Mao ni ang Moon
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