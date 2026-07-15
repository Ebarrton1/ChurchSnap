import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/church_directory_entry.dart';

class ChurchDirectoryRepository {
  ChurchDirectoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _churches =>
      _firestore.collection('churches');

  Stream<List<ChurchDirectoryEntry>> watchPublicChurches() {
    return _churches.snapshots().map((snapshot) {
      final churches = snapshot.docs
          .map(ChurchDirectoryEntry.fromDocument)
          .where(
            (church) =>
                church.isPublic &&
                church.isActive &&
                church.visitorAccessEnabled,
          )
          .toList();

      churches.sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );

      return churches;
    });
  }

  Future<ChurchDirectoryEntry?> resolveConnection(String rawValue) async {
    final candidate = _extractConnectionValue(rawValue);

    if (candidate.isEmpty) {
      return null;
    }

    final snapshot = await _churches.get();
    final normalizedId = candidate.toLowerCase();
    final normalizedCode = candidate.toUpperCase();

    for (final document in snapshot.docs) {
      final church = ChurchDirectoryEntry.fromDocument(document);

      if (!church.canAcceptVisitors) {
        continue;
      }

      if (church.id.toLowerCase() == normalizedId ||
          church.connectionCode == normalizedCode) {
        return church;
      }
    }

    return null;
  }

  static String _extractConnectionValue(String rawValue) {
    final trimmed = rawValue.trim();

    if (trimmed.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(trimmed);

    if (uri != null && uri.scheme.toLowerCase() == 'churchsnap') {
      final host = uri.host.toLowerCase();

      if (host == 'church' && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first.trim();
      }

      final queryChurchId = uri.queryParameters['churchId']?.trim() ?? '';
      final queryCode = uri.queryParameters['code']?.trim() ?? '';

      if (queryChurchId.isNotEmpty) {
        return queryChurchId;
      }

      if (queryCode.isNotEmpty) {
        return queryCode;
      }

      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last.trim();
      }
    }

    return trimmed;
  }
}
