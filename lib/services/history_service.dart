class HistoryService {

  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();
  final List<Map<String, dynamic>> _history = [];

  List<Map<String, dynamic>> get history => List.unmodifiable(_history);

  void addToHistory({
    required String mangaId,
    required String title,
    required String coverUrl,
    required String chapterNumber,
  }) {
    _history.removeWhere((entry) => entry['mangaId'] == mangaId);
    _history.insert(0, {
      'mangaId': mangaId,
      'title': title,
      'coverUrl': coverUrl,
      'chapterNumber': chapterNumber,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void updateChapter({
    required String mangaId,
    required String chapterNumber,
  }) {
    final index =
        _history.indexWhere((entry) => entry['mangaId'] == mangaId);
    if (index != -1) {
      _history[index]['chapterNumber'] = chapterNumber;
    }
  }

  void clearHistory() {
    _history.clear();
  }

  List<Map<String, dynamic>> search(String query) {
    if (query.isEmpty) return history;
    return _history
        .where((entry) =>
            entry['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}