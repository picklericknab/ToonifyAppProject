import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  CollectionReference? get _historyRef {
    if (_uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('history');
  }

  // Mo kuha sa history but gikan sa firebase
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      if (_historyRef == null) return [];
      final snapshot = await _historyRef!
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => {
                ...Map<String, dynamic>.from(doc.data() as Map),
                'docId': doc.id,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addToHistory({
    required String mangaId,
    required String title,
    required String coverUrl,
    required String chapterNumber,
  }) async {
    try {
      if (_historyRef == null) return;

      // Mo check if naay existing history
      final existing = await _historyRef!
          .where('mangaId', isEqualTo: mangaId)
          .get();

      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.update({
          'chapterNumber': chapterNumber,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await _historyRef!.add({
          'mangaId': mangaId,
          'title': title,
          'coverUrl': coverUrl,
          'chapterNumber': chapterNumber,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> updateChapter({
    required String mangaId,
    required String chapterNumber,
  }) async {
    try {
      if (_historyRef == null) return;
      final existing = await _historyRef!
          .where('mangaId', isEqualTo: mangaId)
          .get();
      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.update({
          'chapterNumber': chapterNumber,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> clearHistory() async {
    try {
      if (_historyRef == null) return;
      final snapshot = await _historyRef!.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final history = await getHistory();
    if (query.isEmpty) return history;
    return history
        .where((entry) => entry['title']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }
}