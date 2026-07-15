import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../firebase/firebase_paths.dart';
import '../models/donation_record.dart';
import '../models/giving_fund.dart';
import '../models/standard_giving_funds.dart';

class GivingRepository {
  GivingRepository({FirebaseFirestore? firestore, required this.churchId})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _funds =>
      _firestore.collection(FirebasePaths.givingFunds(churchId));

  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection(FirebasePaths.donations(churchId));

  Stream<List<GivingFund>> watchActiveFunds() async* {
    await _ensureSeparateTitheAndOfferingFunds();

    yield* _funds.snapshots().map((snapshot) {
      final funds = snapshot.docs
          .map((document) => GivingFund.fromMap(document.id, document.data()))
          .where((fund) => fund.active)
          .toList();

      return StandardGivingFunds.separateLegacyFund(funds);
    });
  }

  Future<void> _ensureSeparateTitheAndOfferingFunds() async {
    try {
      final snapshot = await _funds.get();
      var hasTithe = false;
      var hasOffering = false;
      var hasDonation = false;
      final legacyDocuments = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

      for (final document in snapshot.docs) {
        final data = document.data();
        final name = data['name'] is String ? (data['name'] as String) : '';

        if (StandardGivingFunds.isTithe(id: document.id, name: name)) {
          hasTithe = true;
        }

        if (StandardGivingFunds.isOffering(id: document.id, name: name)) {
          hasOffering = true;
        }
        if (StandardGivingFunds.isDonation(id: document.id, name: name)) {
          hasDonation = true;
        }

        if (StandardGivingFunds.isLegacyCombinedFund(
          id: document.id,
          name: name,
        )) {
          legacyDocuments.add(document);
        }
      }

      if (hasTithe && hasOffering && hasDonation && legacyDocuments.isEmpty) {
        return;
      }

      final batch = _firestore.batch();
      var hasWrites = false;

      if (!hasTithe) {
        batch.set(_funds.doc(StandardGivingFunds.tithe.id), {
          ...StandardGivingFunds.tithe.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        hasWrites = true;
      }

      if (!hasOffering) {
        batch.set(_funds.doc(StandardGivingFunds.offering.id), {
          ...StandardGivingFunds.offering.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        hasWrites = true;
      }
      if (!hasDonation) {
        batch.set(_funds.doc(StandardGivingFunds.donation.id), {
          ...StandardGivingFunds.donation.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        hasWrites = true;
      }

      for (final document in legacyDocuments) {
        batch.set(document.reference, {
          'name': 'Legacy Tithe & Offering',
          'description':
              'Inactive legacy fund retained for historical records.',
          'active': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        hasWrites = true;
      }

      if (hasWrites) {
        await batch.commit();
      }
    } on FirebaseException catch (error) {
      // Members and visitors may read funds but cannot migrate them.
      // The giver UI still separates the legacy fund locally. The first
      // administrator who opens Giving completes the Firestore migration.
      if (error.code != 'permission-denied') {
        rethrow;
      }
    }
  }

  Stream<List<GivingFund>> watchAllFunds() {
    return _funds.snapshots().map((snapshot) {
      final funds = snapshot.docs
          .map((document) => GivingFund.fromMap(document.id, document.data()))
          .toList();

      funds.sort((left, right) {
        final orderComparison = left.sortOrder.compareTo(right.sortOrder);
        if (orderComparison != 0) return orderComparison;
        return left.name.toLowerCase().compareTo(right.name.toLowerCase());
      });

      return funds;
    });
  }

  Future<void> addFund(GivingFund fund) {
    return _funds.add({
      ...fund.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFund(GivingFund fund) {
    final fundId = fund.id.trim();
    if (fundId.isEmpty) {
      throw ArgumentError('A fund ID is required.');
    }

    return _funds.doc(fundId).update({
      ...fund.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFund(String fundId) {
    final cleanFundId = fundId.trim();
    if (cleanFundId.isEmpty) {
      throw ArgumentError('A fund ID is required.');
    }

    return _funds.doc(cleanFundId).delete();
  }

  Future<void> createStarterFunds() async {
    const starterFunds = <String, GivingFund>{
      'tithe-offering': GivingFund(
        name: 'Tithe & Offering',
        description: 'Support the general ministry and mission of the church.',
        sortOrder: 10,
      ),
      'missions': GivingFund(
        name: 'Missions',
        description: 'Support local and global mission work.',
        sortOrder: 20,
      ),
      'building-fund': GivingFund(
        name: 'Building Fund',
        description: 'Help maintain and improve church facilities.',
        sortOrder: 30,
      ),
      'youth-ministry': GivingFund(
        name: 'Youth Ministry',
        description: 'Invest in children, teens, and young adults.',
        sortOrder: 40,
      ),
    };

    final batch = _firestore.batch();

    for (final entry in starterFunds.entries) {
      batch.set(_funds.doc(entry.key), {
        ...entry.value.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Stream<List<DonationRecord>> watchMemberDonations(String memberId) {
    final cleanMemberId = memberId.trim();
    if (cleanMemberId.isEmpty) {
      return Stream.value(const <DonationRecord>[]);
    }

    return _donations
        .where('memberId', isEqualTo: cleanMemberId)
        .snapshots()
        .map((snapshot) {
          final donations = snapshot.docs
              .map(
                (document) =>
                    DonationRecord.fromMap(document.id, document.data()),
              )
              .toList();

          donations.sort(_newestDonationFirst);
          return donations;
        });
  }

  Stream<List<DonationRecord>> watchAllDonations() {
    return _donations.snapshots().map((snapshot) {
      final donations = snapshot.docs
          .map(
            (document) => DonationRecord.fromMap(document.id, document.data()),
          )
          .toList();

      donations.sort(_newestDonationFirst);
      return donations;
    });
  }

  Future<void> addDonation(DonationRecord donation) {
    if (donation.amountCents <= 0) {
      throw ArgumentError('Donation amount must be greater than zero.');
    }

    return _donations.add({
      ...donation.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDonation(DonationRecord donation) {
    final donationId = donation.id.trim();
    if (donationId.isEmpty) {
      throw ArgumentError('A donation ID is required.');
    }

    if (donation.amountCents <= 0) {
      throw ArgumentError('Donation amount must be greater than zero.');
    }

    return _donations.doc(donationId).update({
      ...donation.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static int _newestDonationFirst(DonationRecord left, DonationRecord right) {
    final leftDate =
        left.receivedAt ??
        left.createdAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final rightDate =
        right.receivedAt ??
        right.createdAt ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return rightDate.compareTo(leftDate);
  }
}
