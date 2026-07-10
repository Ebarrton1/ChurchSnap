import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_record.dart';

class AttendanceHistoryRepository {
  AttendanceHistoryRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _checkIns => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('eventCheckIns');

  CollectionReference<Map<String, dynamic>> get _events =>
      _firestore.collection('churches').doc(churchId).collection('events');

  Stream<List<AttendanceRecord>> watchMemberAttendance(String memberId) {
    return _checkIns
        .where('memberId', isEqualTo: memberId)
        .snapshots()
        .asyncMap((snapshot) async {
          final records = await Future.wait<AttendanceRecord>(
            snapshot.docs.map((document) async {
              final data = document.data();
              final eventId = data['eventId'] as String? ?? '';

              var eventTitle = 'Church Event';

              if (eventId.isNotEmpty) {
                final eventSnapshot = await _events.doc(eventId).get();
                final eventData = eventSnapshot.data();
                final storedTitle = eventData?['title'] as String?;

                if (storedTitle != null && storedTitle.trim().isNotEmpty) {
                  eventTitle = storedTitle.trim();
                }
              }

              return AttendanceRecord.fromMap(
                document.id,
                data,
                eventTitle: eventTitle,
              );
            }),
          );

          records.sort((first, second) {
            final firstDate =
                first.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final secondDate =
                second.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);

            return secondDate.compareTo(firstDate);
          });

          return records;
        });
  }
}
