import 'package:cloud_firestore/cloud_firestore.dart';

class QrCheckInResult {
  const QrCheckInResult({
    required this.success,
    required this.message,
    this.memberName = '',
  });

  final bool success;
  final String message;
  final String memberName;
}

class QrCheckInService {
  QrCheckInService({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  DocumentReference<Map<String, dynamic>> get _churchRef =>
      _firestore.collection('churches').doc(churchId);

  Future<QrCheckInResult> checkInMember({
    required String memberId,
    required String eventId,
  }) async {
    final cleanMemberId = memberId.trim();
    final cleanEventId = eventId.trim();

    if (cleanMemberId.isEmpty) {
      return const QrCheckInResult(
        success: false,
        message: 'The scanned QR code did not contain a member ID.',
      );
    }

    if (cleanEventId.isEmpty) {
      return const QrCheckInResult(
        success: false,
        message: 'Select an event before scanning.',
      );
    }

    try {
      final memberRef = _churchRef.collection('members').doc(cleanMemberId);
      final memberSnapshot = await memberRef.get();

      if (!memberSnapshot.exists) {
        return const QrCheckInResult(
          success: false,
          message: 'Member not found.',
        );
      }

      final memberData = memberSnapshot.data() ?? <String, dynamic>{};
      final memberName =
          (memberData['displayName'] as String?)?.trim().isNotEmpty == true
          ? (memberData['displayName'] as String).trim()
          : 'ChurchSnap Member';

      final checkInId = '${cleanEventId}_$cleanMemberId';

      final checkInRef = _churchRef.collection('eventCheckIns').doc(checkInId);

      final existingCheckIn = await checkInRef.get();

      if (existingCheckIn.exists) {
        return QrCheckInResult(
          success: false,
          message: '$memberName is already checked in for this event.',
          memberName: memberName,
        );
      }

      await _firestore.runTransaction((transaction) async {
        final latestCheckIn = await transaction.get(checkInRef);

        if (latestCheckIn.exists) {
          throw StateError('duplicate-check-in');
        }

        transaction.set(checkInRef, {
          'churchId': churchId,
          'eventId': cleanEventId,
          'memberId': cleanMemberId,
          'memberName': memberName,
          'checkedInAt': FieldValue.serverTimestamp(),
          'checkInMethod': 'qr',
        });
      });

      return QrCheckInResult(
        success: true,
        message: '$memberName checked in successfully.',
        memberName: memberName,
      );
    } on StateError catch (error) {
      if (error.message == 'duplicate-check-in') {
        return const QrCheckInResult(
          success: false,
          message: 'This member is already checked in.',
        );
      }

      return const QrCheckInResult(
        success: false,
        message: 'Unable to complete check-in.',
      );
    } on FirebaseException catch (error) {
      return QrCheckInResult(
        success: false,
        message: error.message ?? 'Firestore check-in failed.',
      );
    } catch (_) {
      return const QrCheckInResult(
        success: false,
        message: 'An unexpected check-in error occurred.',
      );
    }
  }
}
