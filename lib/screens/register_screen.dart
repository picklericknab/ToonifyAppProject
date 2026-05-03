import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'success_registered_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmError;

  bool isLoading = false;

  @override
  void dispose() {
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateUsername(String value) {
    if (value.isEmpty) return 'Username is required.';
    if (value.length < 3) return 'Username must be at least 3 characters.';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Only letters, numbers, and underscores allowed.';
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  // Validattion sa password
  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least 1 number.';
    }
    return null;
  }

  String? _validateConfirm(String value) {
    if (value.isEmpty) return 'Please confirm your password.';
    if (value != passwordCtrl.text) return 'Passwords do not match.';
    return null;
  }

  Future<void> _handleRegister() async {
    setState(() {
      usernameError = _validateUsername(usernameCtrl.text.trim());
      emailError = _validateEmail(emailCtrl.text.trim());
      passwordError = _validatePassword(passwordCtrl.text);
      confirmError = _validateConfirm(confirmCtrl.text);
    });

    if (usernameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmError != null) return;

    setState(() => isLoading = true);

    final error = await AuthService.register(
      usernameCtrl.text.trim(),
      emailCtrl.text.trim(),
      passwordCtrl.text,
    );

    if (mounted) {
      setState(() => isLoading = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const SuccessRegisteredScreen()),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF454545),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            // Red border kung nay error
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.red, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.red, width: 1.5)
                  : const BorderSide(color: Colors.white54, width: 1.5),
            ),
          ),
        ),
        // Error message sa ubos sa field
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: Stack(
        children: [
          Positioned(
            top: -30,
            left: 40,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 231, 230, 230),
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
                color: const Color(0xFF3D3D3D),
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
                color: const Color(0xFF3D3D3D),
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
                color: const Color(0xFF3D3D3D),
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
                color: const Color(0xFF3D3D3D),
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
                const Text(
                  'Toonify',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 37,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                CustomPaint(
                  size: const Size(38, 38),
                  painter: MoonPainter(),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 180),
                        const Center(
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ),
                        const SizedBox(height: 40), // Space sa ubos sa Sign up
                        _buildTextField(
                          controller: usernameCtrl,
                          hint: 'Username',
                          errorText: usernameError,
                          onChanged: (_) {
                            if (usernameError != null) {
                              setState(() => usernameError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 20), // Space sa fields
                        _buildTextField(
                          controller: emailCtrl,
                          hint: 'Email',
                          errorText: emailError,
                          onChanged: (_) {
                            if (emailError != null) {
                              setState(() => emailError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 20), // Kani pud
                        _buildTextField(
                          controller: passwordCtrl,
                          hint: 'Password',
                          obscure: true,
                          errorText: passwordError,
                          onChanged: (_) {
                            if (passwordError != null) {
                              setState(() => passwordError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 20), // Kani pud
                        _buildTextField(
                          controller: confirmCtrl,
                          hint: 'Confirm Password',
                          obscure: true,
                          errorText: confirmError,
                          onChanged: (_) {
                            if (confirmError != null) {
                              setState(() => confirmError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 35), // Space sa Register button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20), // Space sa ubos sa button
                        Row( // Mao ni ang already have an account
                          children: [
                            const Text(
                              'already have an account?  ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Balik sa Login screen
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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