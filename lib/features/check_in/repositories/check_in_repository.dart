import 'package:cloud_firestore/cloud_firestore.dart';

import '../../attendance/models/attendance_check_in_document.dart';
import '../models/check_in_record.dart';

class CheckInRepository {
  CheckInRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  static const int _batchSize = 400;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _checkIns => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('eventCheckIns');

  Future<void> checkIn(CheckInRecord record) async {
    final checkInId = AttendanceCheckInDocument.documentId(
      eventId: record.eventId,
      memberId: record.userId,
    );
    final reference = _checkIns.doc(checkInId);

    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(reference);

      if (existing.exists) {
        throw StateError('duplicate-check-in');
      }

      transaction.set(
        reference,
        AttendanceCheckInDocument.fields(
          eventId: record.eventId,
          memberId: record.userId,
          memberName: record.displayName,
          checkInMethod: record.checkInMethod,
          checkedInAt: record.checkedInAt,
        ),
      );
    });
  }

  Stream<List<CheckInRecord>> watchCheckIns(String eventId) {
    return _checkIns
        .where('eventId', isEqualTo: eventId.trim())
        .snapshots()
        .map(_recordsFromSnapshot);
  }

  Stream<List<CheckInRecord>> watchAllRecentCheckIns({int limit = 250}) {
    return _checkIns
        .orderBy('checkedInAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_recordsFromSnapshot);
  }

  Future<int> deleteCheckIn(String checkInId) async {
    final normalizedId = checkInId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        checkInId,
        'checkInId',
        'A check-in ID is required.',
      );
    }

    final reference = _checkIns.doc(normalizedId);
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.delete();
    return 1;
  }

  Future<int> deleteSelectedCheckIns(Iterable<String> checkInIds) async {
    final uniqueIds = checkInIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    var deletedCount = 0;

    for (var start = 0; start < uniqueIds.length; start += _batchSize) {
      final end = (start + _batchSize) > uniqueIds.length
          ? uniqueIds.length
          : start + _batchSize;
      final batch = _firestore.batch();

      for (final id in uniqueIds.sublist(start, end)) {
        batch.delete(_checkIns.doc(id));
      }

      await batch.commit();
      deletedCount += end - start;
    }

    return deletedCount;
  }

  Future<int> clearAllCheckIns() {
    return _deleteQueryInBatches(_checkIns);
  }

  Future<int> clearCheckInsForEvent(String eventId) {
    final normalizedEventId = eventId.trim();

    if (normalizedEventId.isEmpty) {
      throw ArgumentError.value(eventId, 'eventId', 'An event ID is required.');
    }

    return _deleteQueryInBatches(
      _checkIns.where('eventId', isEqualTo: normalizedEventId),
    );
  }

  Future<int> clearCheckInsForDate(DateTime localDate) {
    final start = DateTime(localDate.year, localDate.month, localDate.day);
    final end = start.add(const Duration(days: 1));

    return _deleteQueryInBatches(
      _checkIns
          .where(
            'checkedInAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where('checkedInAt', isLessThan: Timestamp.fromDate(end)),
    );
  }

  List<CheckInRecord> _recordsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final records = snapshot.docs
        .map((document) => CheckInRecord.fromMap(document.id, document.data()))
        .toList();

    records.sort((left, right) {
      final leftDate =
          left.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final rightDate =
          right.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return rightDate.compareTo(leftDate);
    });

    return List<CheckInRecord>.unmodifiable(records);
  }

  Future<int> _deleteQueryInBatches(Query<Map<String, dynamic>> query) async {
    var deletedCount = 0;

    while (true) {
      final snapshot = await query.limit(_batchSize).get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      final batch = _firestore.batch();

      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();
      deletedCount += snapshot.docs.length;

      if (snapshot.docs.length < _batchSize) {
        break;
      }
    }

    return deletedCount;
  }
}
