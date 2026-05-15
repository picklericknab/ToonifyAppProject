import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mao ni sa login ug register logic 
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static SharedPreferences? _prefs;

  static String? currentAgeRange;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<String?> register(
      String username, String email, String password, String ageRange) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString('username_${email.toLowerCase()}', username);
      await prefs.setString('ageRange_${email.toLowerCase()}', ageRange);

      currentAgeRange = ageRange;

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _auth.currentUser?.updateDisplayName(username);

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email is already registered.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        default:
          return 'Registration failed. Please try again.';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await _getPrefs();
      final age = prefs.getString('ageRange_${email.toLowerCase()}');
      currentAgeRange = age;

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Wrong email or password.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'Login failed. Please try again.';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        default:
          return 'Failed to send reset email. Please try again.';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String> getUsername(String email) async {
    final prefs = await _getPrefs();
    return prefs.getString('username_${email.toLowerCase()}') ??
        email.split('@')[0];
  }

  static Future<String?> getAgeRange(String email) async {
    final prefs = await _getPrefs();
    return prefs.getString('ageRange_${email.toLowerCase()}');
  }

  static User? get currentUser => _auth.currentUser;

  static Future<void> signOut() async {
    await _auth.signOut();
    currentAgeRange = null;
  }
}