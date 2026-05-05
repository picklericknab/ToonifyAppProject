import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _historyKey = 'reading_history';
  static SharedPreferences? _prefs;
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<Map<String, dynamic>>> _loadHistory() async {
    final prefs = await _getPrefs();
    final String? json = prefs.getString(_historyKey);
    if (json == null) return [];
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> _saveHistory(List<Map<String, dynamic>> history) async {
    final prefs = await _getPrefs();
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    return await _loadHistory();
  }

  Future<void> addToHistory({
    required String mangaId,
    required String title,
    required String coverUrl,
    required String chapterNumber,
  }) async {
    final history = await _loadHistory();
    history.removeWhere((entry) => entry['mangaId'] == mangaId);
    history.insert(0, {
      'mangaId': mangaId,
      'title': title,
      'coverUrl': coverUrl,
      'chapterNumber': chapterNumber,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _saveHistory(history);
  }

  // Mo update sa chapter number
  Future<void> updateChapter({
    required String mangaId,
    required String chapterNumber,
  }) async {
    final history = await _loadHistory();
    final index = history.indexWhere((entry) => entry['mangaId'] == mangaId);
    if (index != -1) {
      history[index]['chapterNumber'] = chapterNumber;
      await _saveHistory(history);
    }
  }

  Future<void> clearHistory() async {
    final prefs = await _getPrefs();
    await prefs.remove(_historyKey);
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final history = await _loadHistory();
    if (query.isEmpty) return history;
    return history
        .where((entry) => entry['title']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }
}