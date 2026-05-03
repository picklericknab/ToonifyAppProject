import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _accountsKey = 'registered_accounts';

  //SharedPreferences 
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<List<Map<String, dynamic>>> _getAccounts() async {
    final prefs = await _getPrefs();
    final String? accountsJson = prefs.getString(_accountsKey);
    if (accountsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(accountsJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  //Ma save ang accounts
  static Future<void> _saveAccounts(
      List<Map<String, dynamic>> accounts) async {
    final prefs = await _getPrefs();
    await prefs.setString(_accountsKey, jsonEncode(accounts));
  }

  static Future<String?> register(
      String username, String email, String password) async {
    final accounts = await _getAccounts();

    final emailExists = accounts.any((a) =>
        a['email'].toString().toLowerCase() == email.toLowerCase());
    if (emailExists) return 'Email is already registered.';

    final usernameExists = accounts.any((a) =>
        a['username'].toString().toLowerCase() == username.toLowerCase());
    if (usernameExists) return 'Username is already taken.';

    accounts.add({
      'username': username,
      'email': email,
      'password': password,
    });

    await _saveAccounts(accounts);
    return null; // Null means success
  }

  static Future<bool> login(String email, String password) async {
    final accounts = await _getAccounts();
    return accounts.any((a) =>
        a['email'].toString().toLowerCase() == email.toLowerCase() &&
        a['password'] == password);
  }
}