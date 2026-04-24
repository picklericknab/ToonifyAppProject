import 'package:flutter/material.dart';
import 'success_email_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller para sa email input
    final emailCtrl = TextEditingController();

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
          // Toonify header usba ang position ari.
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
                  Center( // Ari usba ang position sa Forgot Password text
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                  SizedBox(height: 40), // Space sa ubos sa title
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
                  SizedBox(height: 45), // Space sa Send Reset Link button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Nabay sulod ang email
                        if (emailCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Isulod ang imong email'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          // Kung nay email navigate sa success screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SuccessEmailScreen()),
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
                        'Send Reset Link',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Space sa Back to Login
                  GestureDetector(
                    onTap: () {
                      // Balik sa Login screen
                      Navigator.pop(context);
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