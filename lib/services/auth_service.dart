// Mao ni sa login ug register logic

class AuthService {
  // Ari i-save ang registered credentials
  static String? savedEmail;
  static String? savedPassword;

  static void register(String email, String password) {
    savedEmail = email;
    savedPassword = password;
  }

  static bool login(String email, String password) {
    return email == savedEmail && password == savedPassword;
  }
}