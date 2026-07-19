# ChurchSnap Giving Confirmation Stabilization Diagnostic

Generated: 2026-07-19 10:24:33

Branch: `churchsnap-testing-stabilization`

Purpose: capture the exact submission, donation-ledger, Firebase path, and Firestore rule structures needed for a safe idempotent confirmation patch.

## Giving submission repository

```dart
   1: import 'package:cloud_firestore/cloud_firestore.dart';
   2: import 'package:firebase_auth/firebase_auth.dart';
   3: 
   4: import '../models/giving_currency.dart';
   5: import '../models/giving_submission.dart';
   6: 
   7: class GivingSubmissionRepository {
   8:   GivingSubmissionRepository({
   9:     required String churchId,
  10:     FirebaseFirestore? firestore,
  11:     FirebaseAuth? auth,
  12:   }) : _churchId = churchId.trim().isEmpty ? 'demo-church' : churchId.trim(),
  13:        _firestore = firestore ?? FirebaseFirestore.instance,
  14:        _auth = auth ?? FirebaseAuth.instance;
  15: 
  16:   final String _churchId;
  17:   final FirebaseFirestore _firestore;
  18:   final FirebaseAuth _auth;
  19: 
  20:   CollectionReference<Map<String, dynamic>> get _collection => _firestore
  21:       .collection('churches')
  22:       .doc(_churchId)
  23:       .collection('giving_submissions');
  24: 
  25:   Stream<List<GivingSubmission>> watchAll() {
  26:     return _collection.snapshots().map((snapshot) {
  27:       final submissions = snapshot.docs
  28:           .map(GivingSubmission.fromDocument)
  29:           .toList();
  30: 
  31:       submissions.sort((left, right) {
  32:         final leftDate =
  33:             left.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  34:         final rightDate =
  35:             right.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  36:         return rightDate.compareTo(leftDate);
  37:       });
  38: 
  39:       return submissions;
  40:     });
  41:   }
  42: 
  43:   Stream<List<GivingSubmission>> watchForGiver(String giverId) {
  44:     final firebaseUser = _auth.currentUser;
  45: 
  46:     if (firebaseUser == null) {
  47:       return Stream.value(const <GivingSubmission>[]);
  48:     }
  49: 
  50:     return _collection
  51:         .where('createdByUid', isEqualTo: firebaseUser.uid)
  52:         .snapshots()
  53:         .map((snapshot) {
  54:           final submissions = snapshot.docs
  55:               .map(GivingSubmission.fromDocument)
  56:               .where((submission) => submission.giverId == giverId)
  57:               .toList();
  58: 
  59:           submissions.sort((left, right) {
  60:             final leftDate =
  61:                 left.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  62:             final rightDate =
  63:                 right.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  64:             return rightDate.compareTo(leftDate);
  65:           });
  66: 
  67:           return submissions;
  68:         });
  69:   }
  70: 
  71:   Future<String> submit({
  72:     required String giverId,
  73:     required String giverName,
  74:     required String fundId,
  75:     required String fundName,
  76:     required int amountMinorUnits,
  77:     required GivingCurrency currency,
  78:     required bool recurring,
  79:   }) async {
  80:     final firebaseUser = _auth.currentUser;
  81: 
  82:     if (firebaseUser == null) {
  83:       throw StateError(
  84:         'A Firebase-authenticated giver is required before a gift can be submitted.',
  85:       );
  86:     }
  87: 
  88:     if (amountMinorUnits <= 0) {
  89:       throw ArgumentError.value(
  90:         amountMinorUnits,
  91:         'amountMinorUnits',
  92:         'Gift amount must be greater than zero.',
  93:       );
  94:     }
  95: 
  96:     final document = await _collection.add({
  97:       'giverId': giverId,
  98:       'createdByUid': firebaseUser.uid,
  99:       'giverName': giverName.trim().isEmpty
 100:           ? 'ChurchSnap Giver'
 101:           : giverName.trim(),
 102:       'fundId': fundId,
 103:       'fundName': fundName,
 104:       'amountMinorUnits': amountMinorUnits,
 105:       'currencyCode': currency.code,
 106:       'currencySymbol': currency.symbol,
 107:       'recurring': recurring,
 108:       'status': GivingSubmissionStatus.pending.name,
 109:       'submittedAt': FieldValue.serverTimestamp(),
 110:     });
 111: 
 112:     return document.id;
 113:   }
 114: 
 115:   Future<void> confirm({
 116:     required GivingSubmission submission,
 117:     required int confirmedAmountMinorUnits,
 118:     required GivingCurrency confirmedCurrency,
 119:     String adminNote = '',
 120:   }) async {
 121:     final firebaseUser = _auth.currentUser;
 122: 
 123:     if (firebaseUser == null) {
 124:       throw StateError('An authenticated administrator is required.');
 125:     }
 126: 
 127:     if (confirmedAmountMinorUnits <= 0) {
 128:       throw ArgumentError.value(
 129:         confirmedAmountMinorUnits,
 130:         'confirmedAmountMinorUnits',
 131:         'Confirmed amount must be greater than zero.',
 132:       );
 133:     }
 134: 
 135:     await _collection.doc(submission.id).update({
 136:       'status': GivingSubmissionStatus.confirmed.name,
 137:       'confirmedAmountMinorUnits': confirmedAmountMinorUnits,
 138:       'confirmedCurrencyCode': confirmedCurrency.code,
 139:       'confirmedCurrencySymbol': confirmedCurrency.symbol,
 140:       'confirmedByUid': firebaseUser.uid,
 141:       'confirmedAt': FieldValue.serverTimestamp(),
 142:       'adminNote': adminNote.trim(),
 143:     });
 144:   }
 145: 
 146:   Future<void> reject({
 147:     required GivingSubmission submission,
 148:     String adminNote = '',
 149:   }) async {
 150:     final firebaseUser = _auth.currentUser;
 151: 
 152:     if (firebaseUser == null) {
 153:       throw StateError('An authenticated administrator is required.');
 154:     }
 155: 
 156:     await _collection.doc(submission.id).update({
 157:       'status': GivingSubmissionStatus.rejected.name,
 158:       'confirmedByUid': firebaseUser.uid,
 159:       'confirmedAt': FieldValue.serverTimestamp(),
 160:       'adminNote': adminNote.trim(),
 161:     });
 162:   }
 163: }
```

## Giving submission model

```dart
   1: import 'package:cloud_firestore/cloud_firestore.dart';
   2: 
   3: import 'giving_currency.dart';
   4: 
   5: enum GivingSubmissionStatus {
   6:   pending,
   7:   confirmed,
   8:   rejected;
   9: 
  10:   static GivingSubmissionStatus fromValue(Object? value) {
  11:     final text = value is String ? value.trim().toLowerCase() : '';
  12: 
  13:     return GivingSubmissionStatus.values.firstWhere(
  14:       (status) => status.name == text,
  15:       orElse: () => GivingSubmissionStatus.pending,
  16:     );
  17:   }
  18: }
  19: 
  20: class GivingSubmission {
  21:   const GivingSubmission({
  22:     required this.id,
  23:     required this.giverId,
  24:     required this.giverName,
  25:     required this.fundId,
  26:     required this.fundName,
  27:     required this.amountMinorUnits,
  28:     required this.currencyCode,
  29:     required this.currencySymbol,
  30:     required this.recurring,
  31:     required this.status,
  32:     this.submittedAt,
  33:     this.confirmedAmountMinorUnits,
  34:     this.confirmedCurrencyCode,
  35:     this.confirmedCurrencySymbol,
  36:     this.confirmedByUid,
  37:     this.confirmedAt,
  38:     this.adminNote,
  39:   });
  40: 
  41:   final String id;
  42:   final String giverId;
  43:   final String giverName;
  44:   final String fundId;
  45:   final String fundName;
  46:   final int amountMinorUnits;
  47:   final String currencyCode;
  48:   final String currencySymbol;
  49:   final bool recurring;
  50:   final GivingSubmissionStatus status;
  51:   final DateTime? submittedAt;
  52:   final int? confirmedAmountMinorUnits;
  53:   final String? confirmedCurrencyCode;
  54:   final String? confirmedCurrencySymbol;
  55:   final String? confirmedByUid;
  56:   final DateTime? confirmedAt;
  57:   final String? adminNote;
  58: 
  59:   GivingCurrency get submittedCurrency => GivingCurrency.byCode(currencyCode);
  60: 
  61:   GivingCurrency get confirmedCurrency =>
  62:       GivingCurrency.byCode(confirmedCurrencyCode ?? currencyCode);
  63: 
  64:   String get submittedAmountLabel =>
  65:       submittedCurrency.formatMinorUnits(amountMinorUnits);
  66: 
  67:   String? get confirmedAmountLabel {
  68:     final amount = confirmedAmountMinorUnits;
  69: 
  70:     if (amount == null) {
  71:       return null;
  72:     }
  73: 
  74:     return confirmedCurrency.formatMinorUnits(amount);
  75:   }
  76: 
  77:   static GivingSubmission fromDocument(
  78:     DocumentSnapshot<Map<String, dynamic>> document,
  79:   ) {
  80:     final data = document.data() ?? const <String, dynamic>{};
  81: 
  82:     DateTime? readDate(Object? value) {
  83:       return value is Timestamp ? value.toDate() : null;
  84:     }
  85: 
  86:     int? readInt(Object? value) {
  87:       return value is int ? value : null;
  88:     }
  89: 
  90:     return GivingSubmission(
  91:       id: document.id,
  92:       giverId: (data['giverId'] as String?)?.trim() ?? '',
  93:       giverName: (data['giverName'] as String?)?.trim() ?? 'ChurchSnap Giver',
  94:       fundId: (data['fundId'] as String?)?.trim() ?? '',
  95:       fundName: (data['fundName'] as String?)?.trim() ?? 'General Giving',
  96:       amountMinorUnits: readInt(data['amountMinorUnits']) ?? 0,
  97:       currencyCode: (data['currencyCode'] as String?)?.trim() ?? 'USD',
  98:       currencySymbol: (data['currencySymbol'] as String?)?.trim() ?? r'$',
  99:       recurring: data['recurring'] == true,
 100:       status: GivingSubmissionStatus.fromValue(data['status']),
 101:       submittedAt: readDate(data['submittedAt']),
 102:       confirmedAmountMinorUnits: readInt(data['confirmedAmountMinorUnits']),
 103:       confirmedCurrencyCode: (data['confirmedCurrencyCode'] as String?)?.trim(),
 104:       confirmedCurrencySymbol: (data['confirmedCurrencySymbol'] as String?)
 105:           ?.trim(),
 106:       confirmedByUid: (data['confirmedByUid'] as String?)?.trim(),
 107:       confirmedAt: readDate(data['confirmedAt']),
 108:       adminNote: (data['adminNote'] as String?)?.trim(),
 109:     );
 110:   }
 111: }
```

## Donation record model

```dart
   1: import 'package:cloud_firestore/cloud_firestore.dart';
   2: 
   3: class DonationRecord {
   4:   const DonationRecord({
   5:     this.id = '',
   6:     required this.memberId,
   7:     required this.memberName,
   8:     required this.fundId,
   9:     required this.fundName,
  10:     required this.amountCents,
  11:     this.currency = 'USD',
  12:     this.status = 'completed',
  13:     this.recurring = false,
  14:     this.reference = '',
  15:     this.receivedAt,
  16:     this.createdAt,
  17:   });
  18: 
  19:   final String id;
  20:   final String memberId;
  21:   final String memberName;
  22:   final String fundId;
  23:   final String fundName;
  24:   final int amountCents;
  25:   final String currency;
  26:   final String status;
  27:   final bool recurring;
  28:   final String reference;
  29:   final DateTime? receivedAt;
  30:   final DateTime? createdAt;
  31: 
  32:   double get amount => amountCents / 100;
  33: 
  34:   factory DonationRecord.fromMap(String id, Map<String, dynamic> map) {
  35:     return DonationRecord(
  36:       id: id,
  37:       memberId: map['memberId'] as String? ?? '',
  38:       memberName: map['memberName'] as String? ?? 'ChurchSnap Member',
  39:       fundId: map['fundId'] as String? ?? '',
  40:       fundName: map['fundName'] as String? ?? 'General Giving',
  41:       amountCents: (map['amountCents'] as num?)?.toInt() ?? 0,
  42:       currency: map['currency'] as String? ?? 'USD',
  43:       status: map['status'] as String? ?? 'completed',
  44:       recurring: map['recurring'] as bool? ?? false,
  45:       reference: map['reference'] as String? ?? '',
  46:       receivedAt: _dateFromValue(map['receivedAt']),
  47:       createdAt: _dateFromValue(map['createdAt']),
  48:     );
  49:   }
  50: 
  51:   Map<String, dynamic> toMap() {
  52:     return {
  53:       'memberId': memberId.trim(),
  54:       'memberName': memberName.trim(),
  55:       'fundId': fundId.trim(),
  56:       'fundName': fundName.trim(),
  57:       'amountCents': amountCents,
  58:       'currency': currency.trim().isEmpty ? 'USD' : currency.trim(),
  59:       'status': status.trim().isEmpty ? 'completed' : status.trim(),
  60:       'recurring': recurring,
  61:       'reference': reference.trim(),
  62:       'receivedAt': receivedAt,
  63:     };
  64:   }
  65: 
  66:   static DateTime? _dateFromValue(Object? value) {
  67:     if (value is Timestamp) return value.toDate();
  68:     if (value is DateTime) return value;
  69:     return null;
  70:   }
  71: }
```

## Giving repository paths and constructor

```dart
   1: import 'package:cloud_firestore/cloud_firestore.dart';
   2: 
   3: import '../../../firebase/firebase_paths.dart';
   4: import '../models/donation_record.dart';
   5: import '../models/giving_fund.dart';
   6: import '../models/standard_giving_funds.dart';
   7: 
   8: class GivingRepository {
   9:   GivingRepository({FirebaseFirestore? firestore, required this.churchId})
  10:     : _firestore = firestore ?? FirebaseFirestore.instance;
  11: 
  12:   final FirebaseFirestore _firestore;
  13:   final String churchId;
  14: 
  15:   CollectionReference<Map<String, dynamic>> get _funds =>
  16:       _firestore.collection(FirebasePaths.givingFunds(churchId));
  17: 
  18:   CollectionReference<Map<String, dynamic>> get _donations =>
  19:       _firestore.collection(FirebasePaths.donations(churchId));
  20: 
  21:   Stream<List<GivingFund>> watchActiveFunds() async* {
  22:     await _ensureSeparateTitheAndOfferingFunds();
  23: 
  24:     yield* _funds.snapshots().map((snapshot) {
  25:       final funds = snapshot.docs
  26:           .map((document) => GivingFund.fromMap(document.id, document.data()))
  27:           .where((fund) => fund.active)
  28:           .toList();
  29: 
  30:       return StandardGivingFunds.separateLegacyFund(funds);
  31:     });
  32:   }
  33: 
  34:   Future<void> _ensureSeparateTitheAndOfferingFunds() async {
  35:     try {
  36:       final snapshot = await _funds.get();
  37:       var hasTithe = false;
  38:       var hasOffering = false;
  39:       var hasDonation = false;
  40:       final legacyDocuments = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  41: 
  42:       for (final document in snapshot.docs) {
  43:         final data = document.data();
  44:         final name = data['name'] is String ? (data['name'] as String) : '';
  45: 
  46:         if (StandardGivingFunds.isTithe(id: document.id, name: name)) {
  47:           hasTithe = true;
  48:         }
  49: 
  50:         if (StandardGivingFunds.isOffering(id: document.id, name: name)) {
  51:           hasOffering = true;
  52:         }
  53:         if (StandardGivingFunds.isDonation(id: document.id, name: name)) {
  54:           hasDonation = true;
  55:         }
  56: 
  57:         if (StandardGivingFunds.isLegacyCombinedFund(
  58:           id: document.id,
  59:           name: name,
  60:         )) {
  61:           legacyDocuments.add(document);
  62:         }
  63:       }
  64: 
  65:       if (hasTithe && hasOffering && hasDonation && legacyDocuments.isEmpty) {
  66:         return;
  67:       }
  68: 
  69:       final batch = _firestore.batch();
  70:       var hasWrites = false;
  71: 
  72:       if (!hasTithe) {
  73:         batch.set(_funds.doc(StandardGivingFunds.tithe.id), {
  74:           ...StandardGivingFunds.tithe.toMap(),
  75:           'createdAt': FieldValue.serverTimestamp(),
```

## Giving repository donation ledger methods

```dart
 200: 
 201:     await batch.commit();
 202:   }
 203: 
 204:   Stream<List<DonationRecord>> watchMemberDonations(String memberId) {
 205:     final cleanMemberId = memberId.trim();
 206:     if (cleanMemberId.isEmpty) {
 207:       return Stream.value(const <DonationRecord>[]);
 208:     }
 209: 
 210:     return _donations
 211:         .where('memberId', isEqualTo: cleanMemberId)
 212:         .snapshots()
 213:         .map((snapshot) {
 214:           final donations = snapshot.docs
 215:               .map(
 216:                 (document) =>
 217:                     DonationRecord.fromMap(document.id, document.data()),
 218:               )
 219:               .toList();
 220: 
 221:           donations.sort(_newestDonationFirst);
 222:           return donations;
 223:         });
 224:   }
 225: 
 226:   Stream<List<DonationRecord>> watchAllDonations() {
 227:     return _donations.snapshots().map((snapshot) {
 228:       final donations = snapshot.docs
 229:           .map(
 230:             (document) => DonationRecord.fromMap(document.id, document.data()),
 231:           )
 232:           .toList();
 233: 
 234:       donations.sort(_newestDonationFirst);
 235:       return donations;
 236:     });
 237:   }
 238: 
 239:   Future<void> addDonation(DonationRecord donation) {
 240:     if (donation.amountCents <= 0) {
 241:       throw ArgumentError('Donation amount must be greater than zero.');
 242:     }
 243: 
 244:     return _donations.add({
 245:       ...donation.toMap(),
 246:       'createdAt': FieldValue.serverTimestamp(),
 247:       'updatedAt': FieldValue.serverTimestamp(),
 248:     });
 249:   }
 250: 
 251:   Future<void> updateDonation(DonationRecord donation) {
 252:     final donationId = donation.id.trim();
 253:     if (donationId.isEmpty) {
 254:       throw ArgumentError('A donation ID is required.');
 255:     }
 256: 
 257:     if (donation.amountCents <= 0) {
 258:       throw ArgumentError('Donation amount must be greater than zero.');
 259:     }
 260: 
 261:     return _donations.doc(donationId).update({
 262:       ...donation.toMap(),
 263:       'updatedAt': FieldValue.serverTimestamp(),
 264:     });
 265:   }
 266: 
 267:   static int _newestDonationFirst(DonationRecord left, DonationRecord right) {
 268:     final leftDate =
 269:         left.receivedAt ??
 270:         left.createdAt ??
```

## Firebase collection names

```dart
   1: class FirebaseCollectionNames {
   2:   static const churches = 'churches';
   3:   static const members = 'members';
   4:   static const sermons = 'sermons';
   5:   static const events = 'events';
   6:   static const prayerRequests = 'prayer_requests';
   7:   static const announcements = 'announcements';
   8:   static const ministries = 'ministries';
   9:   static const testimonies = 'testimonies';
  10:   static const volunteers = 'volunteers';
  11:   static const givingFunds = 'giving_funds';
  12:   static const donations = 'donations';
  13:   static const notifications = 'notifications';
  14:   static const readingPlans = 'reading_plans';
  15:   static const checkIns = 'check_ins';
  16:   static const settings = 'settings';
  17: }
```

## Firebase paths

```dart
   1: import 'firebase_collection_names.dart';
   2: 
   3: class FirebasePaths {
   4:   static String church(String churchId) =>
   5:       '${FirebaseCollectionNames.churches}/$churchId';
   6:   static String members(String churchId) =>
   7:       '${church(churchId)}/${FirebaseCollectionNames.members}';
   8:   static String sermons(String churchId) =>
   9:       '${church(churchId)}/${FirebaseCollectionNames.sermons}';
  10:   static String events(String churchId) =>
  11:       '${church(churchId)}/${FirebaseCollectionNames.events}';
  12:   static String prayerRequests(String churchId) =>
  13:       '${church(churchId)}/${FirebaseCollectionNames.prayerRequests}';
  14:   static String announcements(String churchId) =>
  15:       '${church(churchId)}/${FirebaseCollectionNames.announcements}';
  16:   static String ministries(String churchId) =>
  17:       '${church(churchId)}/${FirebaseCollectionNames.ministries}';
  18:   static String givingFunds(String churchId) =>
  19:       '${church(churchId)}/${FirebaseCollectionNames.givingFunds}';
  20:   static String donations(String churchId) =>
  21:       '${church(churchId)}/${FirebaseCollectionNames.donations}';
  22:   static String settings(String churchId) =>
  23:       '${church(churchId)}/${FirebaseCollectionNames.settings}/app';
  24: }
```

## Firestore giving submissions rules

### Lines 641-761

```text
 641:             'BBD',
 642:             'XCD',
 643:             'GYD',
 644:             'NGN',
 645:             'GHS',
 646:             'ZAR'
 647:           ])
 648:           && request.resource.data.currencyCode
 649:             == request.resource.data.defaultCurrencyCode
 650:           && request.resource.data.currencyName is string
 651:           && request.resource.data.currencyName.size() > 0
 652:           && request.resource.data.currencyName.size() <= 64
 653:           && request.resource.data.currencySymbol is string
 654:           && request.resource.data.currencySymbol.size() > 0
 655:           && request.resource.data.currencySymbol.size() <= 8
 656:           && request.resource.data.symbolBeforeAmount is bool
 657:           && request.resource.data.get('updatedAt', request.time) is timestamp;
 658: 
 659:         allow delete: if isAdmin(churchId);
 660:       }
 661:       match /giving_submissions/{submissionId} {
 662:         allow create: if signedIn()
 663:           && request.resource.data.keys().hasOnly([
 664:             'giverId',
 665:             'createdByUid',
 666:             'giverName',
 667:             'fundId',
 668:             'fundName',
 669:             'amountMinorUnits',
 670:             'currencyCode',
 671:             'currencySymbol',
 672:             'recurring',
 673:             'status',
 674:             'submittedAt'
 675:           ])
 676:           && request.resource.data.keys().hasAll([
 677:             'giverId',
 678:             'createdByUid',
 679:             'giverName',
 680:             'fundId',
 681:             'fundName',
 682:             'amountMinorUnits',
 683:             'currencyCode',
 684:             'currencySymbol',
 685:             'recurring',
 686:             'status',
 687:             'submittedAt'
 688:           ])
 689:           && request.resource.data.createdByUid == request.auth.uid
 690:           && request.resource.data.giverId is string
 691:           && request.resource.data.giverId.size() > 0
 692:           && request.resource.data.giverId.size() <= 128
 693:           && request.resource.data.giverName is string
 694:           && request.resource.data.giverName.size() > 0
 695:           && request.resource.data.giverName.size() <= 120
 696:           && request.resource.data.fundId is string
 697:           && request.resource.data.fundId.size() > 0
 698:           && request.resource.data.fundId.size() <= 128
 699:           && request.resource.data.fundName is string
 700:           && request.resource.data.fundName.size() > 0
 701:           && request.resource.data.fundName.size() <= 120
 702:           && request.resource.data.amountMinorUnits is int
 703:           && request.resource.data.amountMinorUnits > 0
 704:           && request.resource.data.amountMinorUnits <= 100000000000
 705:           && request.resource.data.currencyCode in [
 706:             'USD',
 707:             'JMD',
 708:             'CAD',
 709:             'GBP',
 710:             'EUR',
 711:             'TTD',
 712:             'BSD',
 713:             'BBD',
 714:             'XCD',
 715:             'GYD',
 716:             'NGN',
 717:             'GHS',
 718:             'ZAR'
 719:           ]
 720:           && request.resource.data.currencySymbol is string
 721:           && request.resource.data.currencySymbol.size() > 0
 722:           && request.resource.data.currencySymbol.size() <= 8
 723:           && request.resource.data.recurring is bool
 724:           && request.resource.data.status == 'pending'
 725:           && request.resource.data.submittedAt is timestamp;
 726: 
 727:         allow read: if isAdmin(churchId)
 728:           || (
 729:             signedIn()
 730:             && resource.data.createdByUid == request.auth.uid
 731:           );
 732: 
 733:         allow update: if isAdmin(churchId)
 734:           && request.resource.data.giverId == resource.data.giverId
 735:           && request.resource.data.createdByUid == resource.data.createdByUid
 736:           && request.resource.data.giverName == resource.data.giverName
 737:           && request.resource.data.fundId == resource.data.fundId
 738:           && request.resource.data.fundName == resource.data.fundName
 739:           && request.resource.data.amountMinorUnits
 740:             == resource.data.amountMinorUnits
 741:           && request.resource.data.currencyCode == resource.data.currencyCode
 742:           && request.resource.data.currencySymbol
 743:             == resource.data.currencySymbol
 744:           && request.resource.data.recurring == resource.data.recurring
 745:           && request.resource.data.submittedAt == resource.data.submittedAt
 746:           && request.resource.data.status in [
 747:             'pending',
 748:             'confirmed',
 749:             'rejected'
 750:           ];
 751: 
 752:         allow delete: if isAdmin(churchId);
 753:       }
 754:       match /giving_funds/{fundId} {
 755:         allow read: if true;
 756:         allow create, update, delete: if isAdmin(churchId);
 757:       }
 758: 
 759:       match /donations/{donationId} {
 760:         allow read: if isAdmin(churchId)
 761:           || (
```

## Firestore donations rules

### Lines 739-781

```text
 739:           && request.resource.data.amountMinorUnits
 740:             == resource.data.amountMinorUnits
 741:           && request.resource.data.currencyCode == resource.data.currencyCode
 742:           && request.resource.data.currencySymbol
 743:             == resource.data.currencySymbol
 744:           && request.resource.data.recurring == resource.data.recurring
 745:           && request.resource.data.submittedAt == resource.data.submittedAt
 746:           && request.resource.data.status in [
 747:             'pending',
 748:             'confirmed',
 749:             'rejected'
 750:           ];
 751: 
 752:         allow delete: if isAdmin(churchId);
 753:       }
 754:       match /giving_funds/{fundId} {
 755:         allow read: if true;
 756:         allow create, update, delete: if isAdmin(churchId);
 757:       }
 758: 
 759:       match /donations/{donationId} {
 760:         allow read: if isAdmin(churchId)
 761:           || (
 762:             isApprovedMember(churchId)
 763:             && resource.data.get('memberId', '') == currentUserId()
 764:           );
 765: 
 766:         allow create, update: if isAdmin(churchId);
 767:         allow delete: if false;
 768:       }
 769: 
 770:       match /giving/{givingId} {
 771:         allow read, write: if false;
 772:       }
 773: 
 774:       match /admin_audit_logs/{auditId} {
 775:         allow read, create: if isRoleAdmin(churchId);
 776:         allow update, delete: if false;
 777:       }
 778:     }
 779:   }
 780: }
 781: 
```

## Existing giving test references

| File | Line | Source |
| --- | ---: | --- |
| `test/features/web_admin/web_admin_action_center_builder_test.dart` | 39 | `donations: [` |
| `test/features/web_admin/web_admin_action_center_builder_test.dart` | 88 | `donations: const [` |
| `test/features/web_admin/web_admin_report_builder_test.dart` | 29 | `donations: const [],` |
| `test/features/web_admin/web_admin_report_builder_test.dart` | 46 | `donations: [` |
| `test/features/web_admin/web_admin_report_builder_test.dart` | 118 | `donations: const [],` |
| `test/features/web_admin/web_admin_report_builder_test.dart` | 136 | `donations: const [` |

