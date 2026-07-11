import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SermonBookmarkRepository {
  SermonBookmarkRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String churchId;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _bookmarks {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      return null;
    }

    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('members')
        .doc(userId)
        .collection('sermonBookmarks');
  }

  Stream<Set<String>> watchBookmarkedSermonIds() {
    final bookmarks = _bookmarks;

    if (bookmarks == null) {
      return Stream.value(<String>{});
    }

    return bookmarks.snapshots().map(
      (snapshot) => snapshot.docs.map((document) => document.id).toSet(),
    );
  }

  Future<void> saveBookmark({
    required String sermonId,
    required String sermonTitle,
  }) async {
    final bookmarks = _bookmarks;

    if (bookmarks == null) {
      throw StateError('Sign in to save sermons.');
    }

    final cleanSermonId = sermonId.trim();

    if (cleanSermonId.isEmpty) {
      throw ArgumentError('A sermon ID is required.');
    }

    await bookmarks.doc(cleanSermonId).set({
      'sermonId': cleanSermonId,
      'sermonTitle': sermonTitle.trim(),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(String sermonId) async {
    final bookmarks = _bookmarks;

    if (bookmarks == null) {
      throw StateError('Sign in to manage saved sermons.');
    }

    final cleanSermonId = sermonId.trim();

    if (cleanSermonId.isEmpty) {
      throw ArgumentError('A sermon ID is required.');
    }

    await bookmarks.doc(cleanSermonId).delete();
  }

  Future<void> setBookmarked({
    required String sermonId,
    required String sermonTitle,
    required bool bookmarked,
  }) {
    if (bookmarked) {
      return saveBookmark(sermonId: sermonId, sermonTitle: sermonTitle);
    }

    return removeBookmark(sermonId);
  }
}
