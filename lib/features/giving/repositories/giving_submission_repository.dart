import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../firebase/firebase_paths.dart';
import '../models/giving_currency.dart';
import '../models/giving_submission.dart';
import '../services/giving_confirmation_ledger.dart';

class GivingSubmissionRepository {
  GivingSubmissionRepository({
    required String churchId,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _churchId = churchId.trim().isEmpty ? 'demo-church' : churchId.trim(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final String _churchId;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebasePaths.givingSubmissions(_churchId));

  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection(FirebasePaths.donations(_churchId));

  Stream<List<GivingSubmission>> watchAll() {
    return _collection.snapshots().map((snapshot) {
      final submissions = snapshot.docs
          .map(GivingSubmission.fromDocument)
          .toList();

      submissions.sort((left, right) {
        final leftDate =
            left.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightDate =
            right.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return rightDate.compareTo(leftDate);
      });

      return submissions;
    });
  }

  Stream<List<GivingSubmission>> watchForGiver(String giverId) {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return Stream.value(const <GivingSubmission>[]);
    }

    return _collection
        .where('createdByUid', isEqualTo: firebaseUser.uid)
        .snapshots()
        .map((snapshot) {
          final submissions = snapshot.docs
              .map(GivingSubmission.fromDocument)
              .where((submission) => submission.giverId == giverId)
              .toList();

          submissions.sort((left, right) {
            final leftDate =
                left.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final rightDate =
                right.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return rightDate.compareTo(leftDate);
          });

          return submissions;
        });
  }

  Future<String> submit({
    required String giverId,
    required String giverName,
    required String fundId,
    required String fundName,
    required int amountMinorUnits,
    required GivingCurrency currency,
    required bool recurring,
  }) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw StateError(
        'A Firebase-authenticated giver is required before a gift can be submitted.',
      );
    }

    if (amountMinorUnits <= 0) {
      throw ArgumentError.value(
        amountMinorUnits,
        'amountMinorUnits',
        'Gift amount must be greater than zero.',
      );
    }

    final document = await _collection.add({
      'giverId': giverId,
      'createdByUid': firebaseUser.uid,
      'giverName': giverName.trim().isEmpty
          ? 'ChurchSnap Giver'
          : giverName.trim(),
      'fundId': fundId,
      'fundName': fundName,
      'amountMinorUnits': amountMinorUnits,
      'currencyCode': currency.code,
      'currencySymbol': currency.symbol,
      'recurring': recurring,
      'status': GivingSubmissionStatus.pending.name,
      'submittedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<void> confirm({
    required GivingSubmission submission,
    required int confirmedAmountMinorUnits,
    required GivingCurrency confirmedCurrency,
    String adminNote = '',
  }) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw StateError('An authenticated administrator is required.');
    }

    if (confirmedAmountMinorUnits <= 0) {
      throw ArgumentError.value(
        confirmedAmountMinorUnits,
        'confirmedAmountMinorUnits',
        'Confirmed amount must be greater than zero.',
      );
    }

    final submissionId = GivingConfirmationLedger.donationDocumentId(
      submission.id,
    );
    final submissionReference = _collection.doc(submissionId);
    final donationReference = _donations.doc(submissionId);
    final cleanAdminNote = adminNote.trim();

    await _firestore.runTransaction((transaction) async {
      final submissionSnapshot = await transaction.get(submissionReference);

      if (!submissionSnapshot.exists) {
        throw StateError('The giving submission no longer exists.');
      }

      final currentSubmission = GivingSubmission.fromDocument(
        submissionSnapshot,
      );

      if (currentSubmission.status == GivingSubmissionStatus.rejected) {
        throw StateError('A rejected gift submission cannot be confirmed.');
      }

      final donationSnapshot = await transaction.get(donationReference);
      final alreadyConfirmed =
          currentSubmission.status == GivingSubmissionStatus.confirmed;

      if (alreadyConfirmed &&
          !GivingConfirmationLedger.matchesConfirmedSubmission(
            submission: currentSubmission,
            confirmedAmountMinorUnits: confirmedAmountMinorUnits,
            confirmedCurrency: confirmedCurrency,
            adminNote: cleanAdminNote,
          )) {
        throw StateError(
          'This gift was already confirmed with different details.',
        );
      }

      if (alreadyConfirmed && donationSnapshot.exists) {
        return;
      }

      final timestamp = FieldValue.serverTimestamp();
      final donationData = GivingConfirmationLedger.donationFields(
        submission: currentSubmission,
        confirmedAmountMinorUnits: confirmedAmountMinorUnits,
        confirmedCurrency: confirmedCurrency,
        confirmedByUid: firebaseUser.uid,
        adminNote: cleanAdminNote,
      );

      transaction.set(donationReference, <String, dynamic>{
        ...donationData,
        if (!donationSnapshot.exists) 'createdAt': timestamp,
        if (!donationSnapshot.exists) 'receivedAt': timestamp,
        'updatedAt': timestamp,
      }, SetOptions(merge: true));

      if (!alreadyConfirmed) {
        transaction.update(submissionReference, <String, dynamic>{
          'status': GivingSubmissionStatus.confirmed.name,
          'confirmedAmountMinorUnits': confirmedAmountMinorUnits,
          'confirmedCurrencyCode': confirmedCurrency.code,
          'confirmedCurrencySymbol': confirmedCurrency.symbol,
          'confirmedByUid': firebaseUser.uid,
          'confirmedAt': timestamp,
          'adminNote': cleanAdminNote,
        });
      }
    });
  }

  Future<void> reject({
    required GivingSubmission submission,
    String adminNote = '',
  }) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw StateError('An authenticated administrator is required.');
    }

    await _collection.doc(submission.id).update({
      'status': GivingSubmissionStatus.rejected.name,
      'confirmedByUid': firebaseUser.uid,
      'confirmedAt': FieldValue.serverTimestamp(),
      'adminNote': adminNote.trim(),
    });
  }
}
