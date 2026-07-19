# ChurchSnap Attendance and QR Check-In Stabilization Audit

Generated: 2026-07-19 11:52:07

Branch: `churchsnap-testing-stabilization`

This is a static source-code audit. It does not read or modify live Firebase data.

## QR check-in service

Source: `.\lib\features\attendance\services\qr_check_in_service.dart`

```dart
   1: import 'package:cloud_firestore/cloud_firestore.dart';
   2: 
   3: class QrCheckInResult {
   4:   const QrCheckInResult({
   5:     required this.success,
   6:     required this.message,
   7:     this.memberName = '',
   8:   });
   9: 
  10:   final bool success;
  11:   final String message;
  12:   final String memberName;
  13: }
  14: 
  15: class QrCheckInService {
  16:   QrCheckInService({
  17:     FirebaseFirestore? firestore,
  18:     this.churchId = 'demo-church',
  19:   }) : _firestore = firestore ?? FirebaseFirestore.instance;
  20: 
  21:   final FirebaseFirestore _firestore;
  22:   final String churchId;
  23: 
  24:   DocumentReference<Map<String, dynamic>> get _churchRef =>
  25:       _firestore.collection('churches').doc(churchId);
  26: 
  27:   Future<QrCheckInResult> checkInMember({
  28:     required String memberId,
  29:     required String eventId,
  30:   }) async {
  31:     final cleanMemberId = memberId.trim();
  32:     final cleanEventId = eventId.trim();
  33: 
  34:     if (cleanMemberId.isEmpty) {
  35:       return const QrCheckInResult(
  36:         success: false,
  37:         message: 'The scanned QR code did not contain a member ID.',
  38:       );
  39:     }
  40: 
  41:     if (cleanEventId.isEmpty) {
  42:       return const QrCheckInResult(
  43:         success: false,
  44:         message: 'Select an event before scanning.',
  45:       );
  46:     }
  47: 
  48:     try {
  49:       final memberRef = _churchRef.collection('members').doc(cleanMemberId);
  50:       final memberSnapshot = await memberRef.get();
  51: 
  52:       if (!memberSnapshot.exists) {
  53:         return const QrCheckInResult(
  54:           success: false,
  55:           message: 'Member not found.',
  56:         );
  57:       }
  58: 
  59:       final memberData = memberSnapshot.data() ?? <String, dynamic>{};
  60:       final memberName =
  61:           (memberData['displayName'] as String?)?.trim().isNotEmpty == true
  62:           ? (memberData['displayName'] as String).trim()
  63:           : 'ChurchSnap Member';
  64: 
  65:       final checkInId = '${cleanEventId}_$cleanMemberId';
  66: 
  67:       final checkInRef = _churchRef.collection('eventCheckIns').doc(checkInId);
  68: 
  69:       final existingCheckIn = await checkInRef.get();
  70: 
  71:       if (existingCheckIn.exists) {
  72:         return QrCheckInResult(
  73:           success: false,
  74:           message: '$memberName is already checked in for this event.',
  75:           memberName: memberName,
  76:         );
  77:       }
  78: 
  79:       await _firestore.runTransaction((transaction) async {
  80:         final latestCheckIn = await transaction.get(checkInRef);
  81: 
  82:         if (latestCheckIn.exists) {
  83:           throw StateError('duplicate-check-in');
  84:         }
  85: 
  86:         transaction.set(checkInRef, {
  87:           'churchId': churchId,
  88:           'eventId': cleanEventId,
  89:           'memberId': cleanMemberId,
  90:           'memberName': memberName,
  91:           'checkedInAt': FieldValue.serverTimestamp(),
  92:           'checkInMethod': 'qr',
  93:         });
  94:       });
  95: 
  96:       return QrCheckInResult(
  97:         success: true,
  98:         message: '$memberName checked in successfully.',
  99:         memberName: memberName,
 100:       );
 101:     } on StateError catch (error) {
 102:       if (error.message == 'duplicate-check-in') {
 103:         return const QrCheckInResult(
 104:           success: false,
 105:           message: 'This member is already checked in.',
 106:         );
 107:       }
 108: 
 109:       return const QrCheckInResult(
 110:         success: false,
 111:         message: 'Unable to complete check-in.',
 112:       );
 113:     } on FirebaseException catch (error) {
 114:       return QrCheckInResult(
 115:         success: false,
 116:         message: error.message ?? 'Firestore check-in failed.',
 117:       );
 118:     } catch (_) {
 119:       return const QrCheckInResult(
 120:         success: false,
 121:         message: 'An unexpected check-in error occurred.',
 122:       );
 123:     }
 124:   }
 125: }
```

## Check-in repository

Source: `.\lib\features\check_in\repositories\check_in_repository.dart`

```dart
   1: import 'package:cloud_firestore/cloud_firestore.dart';
   2: 
   3: import '../models/check_in_record.dart';
   4: 
   5: class CheckInRepository {
   6:   CheckInRepository({
   7:     FirebaseFirestore? firestore,
   8:     this.churchId = 'demo-church',
   9:   }) : _firestore = firestore ?? FirebaseFirestore.instance;
  10: 
  11:   static const int _batchSize = 400;
  12: 
  13:   final FirebaseFirestore _firestore;
  14:   final String churchId;
  15: 
  16:   CollectionReference<Map<String, dynamic>> get _checkIns => _firestore
  17:       .collection('churches')
  18:       .doc(churchId)
  19:       .collection('eventCheckIns');
  20: 
  21:   Future<void> checkIn(CheckInRecord record) {
  22:     return _checkIns.add(record.toMap());
  23:   }
  24: 
  25:   Stream<List<CheckInRecord>> watchCheckIns(String eventId) {
  26:     return _checkIns
  27:         .where('eventId', isEqualTo: eventId.trim())
  28:         .snapshots()
  29:         .map(_recordsFromSnapshot);
  30:   }
  31: 
  32:   Stream<List<CheckInRecord>> watchAllRecentCheckIns({int limit = 250}) {
  33:     return _checkIns
  34:         .orderBy('checkedInAt', descending: true)
  35:         .limit(limit)
  36:         .snapshots()
  37:         .map(_recordsFromSnapshot);
  38:   }
  39: 
  40:   Future<int> deleteCheckIn(String checkInId) async {
  41:     final normalizedId = checkInId.trim();
  42: 
  43:     if (normalizedId.isEmpty) {
  44:       throw ArgumentError.value(
  45:         checkInId,
  46:         'checkInId',
  47:         'A check-in ID is required.',
  48:       );
  49:     }
  50: 
  51:     final reference = _checkIns.doc(normalizedId);
  52:     final snapshot = await reference.get();
  53: 
  54:     if (!snapshot.exists) {
  55:       return 0;
  56:     }
  57: 
  58:     await reference.delete();
  59:     return 1;
  60:   }
  61: 
  62:   Future<int> deleteSelectedCheckIns(Iterable<String> checkInIds) async {
  63:     final uniqueIds = checkInIds
  64:         .map((id) => id.trim())
  65:         .where((id) => id.isNotEmpty)
  66:         .toSet()
  67:         .toList();
  68: 
  69:     var deletedCount = 0;
  70: 
  71:     for (var start = 0; start < uniqueIds.length; start += _batchSize) {
  72:       final end = (start + _batchSize) > uniqueIds.length
  73:           ? uniqueIds.length
  74:           : start + _batchSize;
  75:       final batch = _firestore.batch();
  76: 
  77:       for (final id in uniqueIds.sublist(start, end)) {
  78:         batch.delete(_checkIns.doc(id));
  79:       }
  80: 
  81:       await batch.commit();
  82:       deletedCount += end - start;
  83:     }
  84: 
  85:     return deletedCount;
  86:   }
  87: 
  88:   Future<int> clearAllCheckIns() {
  89:     return _deleteQueryInBatches(_checkIns);
  90:   }
  91: 
  92:   Future<int> clearCheckInsForEvent(String eventId) {
  93:     final normalizedEventId = eventId.trim();
  94: 
  95:     if (normalizedEventId.isEmpty) {
  96:       throw ArgumentError.value(eventId, 'eventId', 'An event ID is required.');
  97:     }
  98: 
  99:     return _deleteQueryInBatches(
 100:       _checkIns.where('eventId', isEqualTo: normalizedEventId),
 101:     );
 102:   }
 103: 
 104:   Future<int> clearCheckInsForDate(DateTime localDate) {
 105:     final start = DateTime(localDate.year, localDate.month, localDate.day);
 106:     final end = start.add(const Duration(days: 1));
 107: 
 108:     return _deleteQueryInBatches(
 109:       _checkIns
 110:           .where(
 111:             'checkedInAt',
 112:             isGreaterThanOrEqualTo: Timestamp.fromDate(start),
 113:           )
 114:           .where('checkedInAt', isLessThan: Timestamp.fromDate(end)),
 115:     );
 116:   }
 117: 
 118:   List<CheckInRecord> _recordsFromSnapshot(
 119:     QuerySnapshot<Map<String, dynamic>> snapshot,
 120:   ) {
 121:     final records = snapshot.docs
 122:         .map((document) => CheckInRecord.fromMap(document.id, document.data()))
 123:         .toList();
 124: 
 125:     records.sort((left, right) {
 126:       final leftDate =
 127:           left.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);
 128:       final rightDate =
 129:           right.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);
 130: 
 131:       return rightDate.compareTo(leftDate);
 132:     });
 133: 
 134:     return List<CheckInRecord>.unmodifiable(records);
 135:   }
 136: 
 137:   Future<int> _deleteQueryInBatches(Query<Map<String, dynamic>> query) async {
 138:     var deletedCount = 0;
 139: 
 140:     while (true) {
 141:       final snapshot = await query.limit(_batchSize).get();
 142: 
 143:       if (snapshot.docs.isEmpty) {
 144:         break;
 145:       }
 146: 
 147:       final batch = _firestore.batch();
 148: 
 149:       for (final document in snapshot.docs) {
 150:         batch.delete(document.reference);
 151:       }
 152: 
 153:       await batch.commit();
 154:       deletedCount += snapshot.docs.length;
 155: 
 156:       if (snapshot.docs.length < _batchSize) {
 157:         break;
 158:       }
 159:     }
 160: 
 161:     return deletedCount;
 162:   }
 163: }
```

## Attendance history repository

Source: `.\lib\features\attendance\repositories\attendance_history_repository.dart`

```dart
   1: import 'package:cloud_firestore/cloud_firestore.dart';
   2: 
   3: import '../models/attendance_record.dart';
   4: 
   5: class AttendanceHistoryRepository {
   6:   AttendanceHistoryRepository({
   7:     FirebaseFirestore? firestore,
   8:     this.churchId = 'demo-church',
   9:   }) : _firestore = firestore ?? FirebaseFirestore.instance;
  10: 
  11:   final FirebaseFirestore _firestore;
  12:   final String churchId;
  13: 
  14:   CollectionReference<Map<String, dynamic>> get _checkIns => _firestore
  15:       .collection('churches')
  16:       .doc(churchId)
  17:       .collection('eventCheckIns');
  18: 
  19:   CollectionReference<Map<String, dynamic>> get _events =>
  20:       _firestore.collection('churches').doc(churchId).collection('events');
  21: 
  22:   Stream<List<AttendanceRecord>> watchMemberAttendance(String memberId) {
  23:     final cleanMemberId = memberId.trim();
  24: 
  25:     if (cleanMemberId.isEmpty) {
  26:       return Stream.value(const <AttendanceRecord>[]);
  27:     }
  28: 
  29:     return _checkIns.snapshots().asyncMap((snapshot) async {
  30:       final matchingDocuments = snapshot.docs.where((document) {
  31:         final data = document.data();
  32: 
  33:         final canonicalMemberId = (data['memberId'] as String?)?.trim();
  34: 
  35:         final legacyUserId = (data['userId'] as String?)?.trim();
  36: 
  37:         return canonicalMemberId == cleanMemberId ||
  38:             legacyUserId == cleanMemberId;
  39:       }).toList();
  40: 
  41:       final records = await Future.wait<AttendanceRecord>(
  42:         matchingDocuments.map((document) async {
  43:           final data = document.data();
  44: 
  45:           final eventId = data['eventId'] as String? ?? '';
  46: 
  47:           var eventTitle = 'Church Event';
  48: 
  49:           if (eventId.isNotEmpty) {
  50:             try {
  51:               final eventSnapshot = await _events.doc(eventId).get();
  52: 
  53:               final eventData = eventSnapshot.data();
  54: 
  55:               final storedTitle = eventData?['title'] as String?;
  56: 
  57:               if (storedTitle != null && storedTitle.trim().isNotEmpty) {
  58:                 eventTitle = storedTitle.trim();
  59:               }
  60:             } on FirebaseException {
  61:               // Keep the fallback event title when
  62:               // the event document is unavailable.
  63:             }
  64:           }
  65: 
  66:           return AttendanceRecord.fromMap(
  67:             document.id,
  68:             data,
  69:             eventTitle: eventTitle,
  70:           );
  71:         }),
  72:       );
  73: 
  74:       records.sort((first, second) {
  75:         final firstDate =
  76:             first.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  77: 
  78:         final secondDate =
  79:             second.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  80: 
  81:         return secondDate.compareTo(firstDate);
  82:       });
  83: 
  84:       return records;
  85:     });
  86:   }
  87: }
```

## Attendance record model

Source: `.\lib\features\attendance\models\attendance_record.dart`

```dart
   1: import 'package:cloud_firestore/cloud_firestore.dart';
   2: 
   3: class AttendanceRecord {
   4:   const AttendanceRecord({
   5:     required this.id,
   6:     required this.eventId,
   7:     required this.eventTitle,
   8:     required this.memberId,
   9:     required this.memberName,
  10:     required this.checkInMethod,
  11:     this.checkedInAt,
  12:   });
  13: 
  14:   final String id;
  15:   final String eventId;
  16:   final String eventTitle;
  17:   final String memberId;
  18:   final String memberName;
  19:   final String checkInMethod;
  20:   final DateTime? checkedInAt;
  21: 
  22:   factory AttendanceRecord.fromMap(
  23:     String id,
  24:     Map<String, dynamic> map, {
  25:     String eventTitle = '',
  26:   }) {
  27:     final checkedInAtValue = map['checkedInAt'];
  28: 
  29:     final storedMemberId =
  30:         map['memberId'] as String? ?? map['userId'] as String? ?? '';
  31: 
  32:     final storedMemberName =
  33:         map['memberName'] as String? ??
  34:         map['displayName'] as String? ??
  35:         'ChurchSnap Member';
  36: 
  37:     return AttendanceRecord(
  38:       id: id,
  39:       eventId: map['eventId'] as String? ?? '',
  40:       eventTitle: eventTitle,
  41:       memberId: storedMemberId,
  42:       memberName: storedMemberName,
  43:       checkInMethod: map['checkInMethod'] as String? ?? 'manual',
  44:       checkedInAt: checkedInAtValue is Timestamp
  45:           ? checkedInAtValue.toDate()
  46:           : null,
  47:     );
  48:   }
  49: }
```

## Check-in record model

Source: `.\lib\features\check_in\models\check_in_record.dart`

```dart
   1: import 'package:cloud_firestore/cloud_firestore.dart';
   2: 
   3: class CheckInRecord {
   4:   const CheckInRecord({
   5:     this.id = '',
   6:     required this.eventId,
   7:     required this.userId,
   8:     required this.displayName,
   9:     this.checkedInAt,
  10:     this.checkInMethod = 'manual',
  11:   });
  12: 
  13:   final String id;
  14:   final String eventId;
  15:   final String userId;
  16:   final String displayName;
  17:   final DateTime? checkedInAt;
  18:   final String checkInMethod;
  19: 
  20:   factory CheckInRecord.fromMap(String id, Map<String, dynamic> data) {
  21:     final checkedInAtValue = data['checkedInAt'];
  22: 
  23:     return CheckInRecord(
  24:       id: id,
  25:       eventId: (data['eventId']?.toString() ?? '').trim(),
  26:       userId: (data['userId']?.toString() ?? data['memberId']?.toString() ?? '')
  27:           .trim(),
  28:       displayName:
  29:           (data['displayName']?.toString() ??
  30:                   data['memberName']?.toString() ??
  31:                   '')
  32:               .trim(),
  33:       checkedInAt: checkedInAtValue is Timestamp
  34:           ? checkedInAtValue.toDate()
  35:           : checkedInAtValue is DateTime
  36:           ? checkedInAtValue
  37:           : null,
  38:       checkInMethod: (data['checkInMethod']?.toString() ?? 'manual').trim(),
  39:     );
  40:   }
  41: 
  42:   Map<String, dynamic> toMap() {
  43:     return {
  44:       'eventId': eventId.trim(),
  45:       'userId': userId.trim(),
  46:       'memberId': userId.trim(),
  47:       'displayName': displayName.trim(),
  48:       'memberName': displayName.trim(),
  49:       'checkInMethod': checkInMethod.trim().isEmpty
  50:           ? 'manual'
  51:           : checkInMethod.trim(),
  52:       'checkedInAt': checkedInAt == null
  53:           ? FieldValue.serverTimestamp()
  54:           : Timestamp.fromDate(checkedInAt!),
  55:     };
  56:   }
  57: }
```

## Administrator QR scanner screen

Source: `.\lib\screens\admin\admin_qr_scanner_screen.dart`

```dart
   1: import 'package:flutter/material.dart';
   2: import 'package:mobile_scanner/mobile_scanner.dart';
   3: 
   4: import '../../core/widgets/churchsnap_screen.dart';
   5: import '../../features/attendance/services/qr_check_in_service.dart';
   6: import '../../features/events/repositories/event_repository.dart';
   7: import '../../models/church_event.dart';
   8: 
   9: class AdminQrScannerScreen extends StatefulWidget {
  10:   const AdminQrScannerScreen({super.key, required this.churchId});
  11: 
  12:   final String churchId;
  13: 
  14:   @override
  15:   State<AdminQrScannerScreen> createState() => _AdminQrScannerScreenState();
  16: }
  17: 
  18: class _AdminQrScannerScreenState extends State<AdminQrScannerScreen> {
  19:   late final MobileScannerController _scannerController;
  20:   late final QrCheckInService _checkInService;
  21:   late final EventRepository _eventRepository;
  22: 
  23:   ChurchEvent? _selectedEvent;
  24:   bool _isProcessing = false;
  25:   bool _hasScanned = false;
  26:   String? _lastMessage;
  27:   bool _lastCheckInSucceeded = false;
  28: 
  29:   @override
  30:   void initState() {
  31:     super.initState();
  32: 
  33:     _scannerController = MobileScannerController();
  34: 
  35:     _checkInService = QrCheckInService(churchId: widget.churchId);
  36: 
  37:     _eventRepository = EventRepository(churchId: widget.churchId);
  38:   }
  39: 
  40:   @override
  41:   void dispose() {
  42:     _scannerController.dispose();
  43:     super.dispose();
  44:   }
  45: 
  46:   @override
  47:   Widget build(BuildContext context) {
  48:     return Material(
  49:       child: ChurchSnapScreen(
  50:         title: 'QR Check-In',
  51:         subtitle: 'Select an event, then scan a member QR code.',
  52:         children: [
  53:           StreamBuilder<List<ChurchEvent>>(
  54:             stream: _eventRepository.watchPublishedEvents(),
  55:             builder: (context, snapshot) {
  56:               if (snapshot.connectionState == ConnectionState.waiting) {
  57:                 return const AppCard(
  58:                   child: Center(child: CircularProgressIndicator()),
  59:                 );
  60:               }
  61: 
  62:               if (snapshot.hasError) {
  63:                 return AppCard(
  64:                   child: ListTile(
  65:                     leading: const Icon(Icons.error_outline_rounded),
  66:                     title: const Text('Unable to load events'),
  67:                     subtitle: Text('${snapshot.error}'),
  68:                   ),
  69:                 );
  70:               }
  71: 
  72:               final events = snapshot.data ?? <ChurchEvent>[];
  73: 
  74:               if (events.isEmpty) {
  75:                 return const AppCard(
  76:                   child: Text(
  77:                     'No published events are available. '
  78:                     'Create an event before using QR check-in.',
  79:                   ),
  80:                 );
  81:               }
  82: 
  83:               return AppCard(
  84:                 child: DropdownButtonFormField<ChurchEvent>(
  85:                   initialValue: _selectedEvent,
  86:                   decoration: const InputDecoration(
  87:                     labelText: 'Check-in event',
  88:                     prefixIcon: Icon(Icons.event_rounded),
  89:                   ),
  90:                   items: events.map((event) {
  91:                     return DropdownMenuItem<ChurchEvent>(
  92:                       value: event,
  93:                       child: Text(event.title),
  94:                     );
  95:                   }).toList(),
  96:                   onChanged: _isProcessing
  97:                       ? null
  98:                       : (event) {
  99:                           setState(() {
 100:                             _selectedEvent = event;
 101:                             _lastMessage = null;
 102:                             _lastCheckInSucceeded = false;
 103:                             _hasScanned = false;
 104:                           });
 105:                         },
 106:                 ),
 107:               );
 108:             },
 109:           ),
 110:           const SizedBox(height: 16),
 111:           AppCard(
 112:             child: SizedBox(
 113:               height: 420,
 114:               child: ClipRRect(
 115:                 borderRadius: BorderRadius.circular(20),
 116:                 child: Stack(
 117:                   fit: StackFit.expand,
 118:                   children: [
 119:                     MobileScanner(
 120:                       controller: _scannerController,
 121:                       onDetect: _handleBarcodeCapture,
 122:                     ),
 123:                     if (_selectedEvent == null)
 124:                       Container(
 125:                         alignment: Alignment.center,
 126:                         color: Colors.black54,
 127:                         padding: const EdgeInsets.all(24),
 128:                         child: const Text(
 129:                           'Select an event before scanning.',
 130:                           textAlign: TextAlign.center,
 131:                           style: TextStyle(
 132:                             color: Colors.white,
 133:                             fontSize: 18,
 134:                             fontWeight: FontWeight.w800,
 135:                           ),
 136:                         ),
 137:                       ),
 138:                     if (_isProcessing)
 139:                       const ColoredBox(
 140:                         color: Colors.black54,
 141:                         child: Center(child: CircularProgressIndicator()),
 142:                       ),
 143:                   ],
 144:                 ),
 145:               ),
 146:             ),
 147:           ),
 148:           if (_lastMessage != null) ...[
 149:             const SizedBox(height: 12),
 150:             AppCard(
 151:               child: ListTile(
 152:                 leading: CircleAvatar(
 153:                   child: Icon(
 154:                     _lastCheckInSucceeded
 155:                         ? Icons.check_rounded
 156:                         : Icons.error_outline_rounded,
 157:                   ),
 158:                 ),
 159:                 title: Text(
 160:                   _lastCheckInSucceeded
 161:                       ? 'Check-in successful'
 162:                       : 'Check-in not completed',
 163:                 ),
 164:                 subtitle: Text(_lastMessage!),
 165:               ),
 166:             ),
 167:           ],
 168:           const SizedBox(height: 12),
 169:           SizedBox(
 170:             width: double.infinity,
 171:             child: FilledButton.icon(
 172:               onPressed: _isProcessing ? null : _resetScanner,
 173:               icon: const Icon(Icons.qr_code_scanner_rounded),
 174:               label: const Text('Scan Again'),
 175:             ),
 176:           ),
 177:         ],
 178:       ),
 179:     );
 180:   }
 181: 
 182:   Future<void> _handleBarcodeCapture(BarcodeCapture capture) async {
 183:     if (_selectedEvent == null || _hasScanned || _isProcessing) {
 184:       return;
 185:     }
 186: 
 187:     final barcode = capture.barcodes.firstOrNull;
 188:     final memberId = barcode?.rawValue?.trim();
 189: 
 190:     if (memberId == null || memberId.isEmpty) {
 191:       return;
 192:     }
 193: 
 194:     setState(() {
 195:       _hasScanned = true;
 196:       _isProcessing = true;
 197:       _lastMessage = null;
 198:     });
 199: 
 200:     await _scannerController.stop();
 201: 
 202:     try {
 203:       final result = await _checkInService.checkInMember(
 204:         memberId: memberId,
 205:         eventId: _selectedEvent!.id,
 206:       );
 207: 
 208:       if (!mounted) {
 209:         return;
 210:       }
 211: 
 212:       setState(() {
 213:         _isProcessing = false;
 214:         _lastCheckInSucceeded = result.success;
 215:         _lastMessage = result.message;
 216:       });
 217: 
 218:       ScaffoldMessenger.of(
 219:         context,
 220:       ).showSnackBar(SnackBar(content: Text(result.message)));
 221:     } catch (error, stackTrace) {
 222:       debugPrint('QR check-in failed: $error');
 223:       debugPrintStack(stackTrace: stackTrace);
 224: 
 225:       if (!mounted) {
 226:         return;
 227:       }
 228: 
 229:       setState(() {
 230:         _isProcessing = false;
 231:         _lastCheckInSucceeded = false;
 232:         _lastMessage = 'Unable to check in member: $error';
 233:       });
 234:     }
 235:   }
 236: 
 237:   Future<void> _resetScanner() async {
 238:     setState(() {
 239:       _hasScanned = false;
 240:       _isProcessing = false;
 241:       _lastMessage = null;
 242:       _lastCheckInSucceeded = false;
 243:     });
 244: 
 245:     await _scannerController.start();
 246:   }
 247: }
```

## Administrator attendance screen

Source: `.\lib\screens\admin\admin_attendance_screen.dart`

```dart
   1: import 'package:flutter/material.dart';
   2: import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';
   3: 
   4: import '../../core/widgets/churchsnap_screen.dart';
   5: import '../../features/check_in/models/check_in_record.dart';
   6: import '../../features/check_in/repositories/check_in_repository.dart';
   7: 
   8: enum _ClearCheckInScope { today, event, all }
   9: 
  10: class AdminAttendanceScreen extends StatefulWidget {
  11:   const AdminAttendanceScreen({super.key, this.churchId = 'demo-church'});
  12: 
  13:   final String churchId;
  14: 
  15:   @override
  16:   State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
  17: }
  18: 
  19: class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  20:   late final CheckInRepository _repository;
  21:   final TextEditingController _searchController = TextEditingController();
  22:   final Set<String> _selectedCheckInIds = <String>{};
  23: 
  24:   String _searchQuery = '';
  25:   String? _selectedEventId;
  26:   bool _isDeleting = false;
  27: 
  28:   @override
  29:   void initState() {
  30:     super.initState();
  31:     _repository = CheckInRepository(churchId: widget.churchId);
  32:   }
  33: 
  34:   @override
  35:   void dispose() {
  36:     _searchController.dispose();
  37:     super.dispose();
  38:   }
  39: 
  40:   @override
  41:   Widget build(BuildContext context) {
  42:     return Material(
  43:       child: ChurchSnapScreen(
  44:         title: 'Attendance & Check-ins',
  45:         subtitle: 'Review and safely clear event check-ins.',
  46:         children: [
  47:           const AppCard(
  48:             child: ListTile(
  49:               leading: CircleAvatar(
  50:                 child: Icon(Icons.admin_panel_settings_outlined),
  51:               ),
  52:               title: Text(
  53:                 'Administrator controls',
  54:                 style: TextStyle(fontWeight: FontWeight.w900),
  55:               ),
  56:               subtitle: Text(
  57:                 'Clearing check-ins permanently removes the selected attendance '
  58:                 'records. Member accounts and directory profiles are not deleted.',
  59:               ),
  60:             ),
  61:           ),
  62:           const SizedBox(height: 14),
  63:           StreamBuilder<List<CheckInRecord>>(
  64:             stream: _repository.watchAllRecentCheckIns(),
  65:             builder: (context, snapshot) {
  66:               if (snapshot.connectionState == ConnectionState.waiting) {
  67:                 return const AppCard(
  68:                   child: Center(
  69:                     child: Padding(
  70:                       padding: EdgeInsets.all(24),
  71:                       child: CircularProgressIndicator(),
  72:                     ),
  73:                   ),
  74:                 );
  75:               }
  76: 
  77:               if (snapshot.hasError) {
  78:                 return AppCard(
  79:                   child: ListTile(
  80:                     leading: const Icon(Icons.error_outline_rounded),
  81:                     title: const Text('Unable to load check-ins'),
  82:                     subtitle: Text('${snapshot.error}'),
  83:                   ),
  84:                 );
  85:               }
  86: 
  87:               final checkIns = snapshot.data ?? <CheckInRecord>[];
  88: 
  89:               return _buildAttendanceContent(checkIns);
  90:             },
  91:           ),
  92:         ],
  93:       ),
  94:     );
  95:   }
  96: 
  97:   Widget _buildAttendanceContent(List<CheckInRecord> checkIns) {
  98:     final eventIds =
  99:         checkIns
 100:             .map((checkIn) => checkIn.eventId.trim())
 101:             .where((eventId) => eventId.isNotEmpty)
 102:             .toSet()
 103:             .toList()
 104:           ..sort();
 105: 
 106:     if (_selectedEventId != null && !eventIds.contains(_selectedEventId)) {
 107:       _selectedEventId = null;
 108:     }
 109: 
 110:     final normalizedQuery = _searchQuery.trim().toLowerCase();
 111: 
 112:     final filtered = checkIns.where((checkIn) {
 113:       if (_selectedEventId != null && checkIn.eventId != _selectedEventId) {
 114:         return false;
 115:       }
 116: 
 117:       if (normalizedQuery.isEmpty) {
 118:         return true;
 119:       }
 120: 
 121:       return [
 122:         checkIn.displayName,
 123:         checkIn.userId,
 124:         checkIn.eventId,
 125:         checkIn.checkInMethod,
 126:       ].join(' ').toLowerCase().contains(normalizedQuery);
 127:     }).toList();
 128: 
 129:     _selectedCheckInIds.removeWhere(
 130:       (id) => !checkIns.any((checkIn) => checkIn.id == id),
 131:     );
 132: 
 133:     return Column(
 134:       crossAxisAlignment: CrossAxisAlignment.stretch,
 135:       children: [
 136:         AppCard(
 137:           child: Column(
 138:             children: [
 139:               TextField(
 140:                 controller: _searchController,
 141:                 onChanged: (value) {
 142:                   setState(() {
 143:                     _searchQuery = value;
 144:                   });
 145:                 },
 146:                 decoration: InputDecoration(
 147:                   labelText: 'Search check-ins',
 148:                   hintText: 'Member, event ID, or method',
 149:                   prefixIcon: const Icon(Icons.search_rounded),
 150:                   suffixIcon: _searchQuery.isEmpty
 151:                       ? null
 152:                       : IconButton(
 153:                           tooltip: 'Clear search',
 154:                           onPressed: () {
 155:                             _searchController.clear();
 156:                             FocusScope.of(context).unfocus();
 157: 
 158:                             setState(() {
 159:                               _searchQuery = '';
 160:                             });
 161:                           },
 162:                           icon: const Icon(Icons.close_rounded),
 163:                         ),
 164:                   border: const OutlineInputBorder(),
 165:                 ),
 166:               ),
 167:               const SizedBox(height: 12),
 168:               DropdownButtonFormField<String?>(
 169:                 initialValue: _selectedEventId,
 170:                 decoration: const InputDecoration(
 171:                   labelText: 'Filter by event',
 172:                   prefixIcon: Icon(Icons.event_available_rounded),
 173:                   border: OutlineInputBorder(),
 174:                 ),
 175:                 items: [
 176:                   const DropdownMenuItem<String?>(
 177:                     value: null,
 178:                     child: Text('All recent events'),
 179:                   ),
 180:                   ...eventIds.map(
 181:                     (eventId) => DropdownMenuItem<String?>(
 182:                       value: eventId,
 183:                       child: Text(eventId),
 184:                     ),
 185:                   ),
 186:                 ],
 187:                 onChanged: _isDeleting
 188:                     ? null
 189:                     : (eventId) {
 190:                         setState(() {
 191:                           _selectedEventId = eventId;
 192:                           _selectedCheckInIds.clear();
 193:                         });
 194:                       },
 195:               ),
 196:               const SizedBox(height: 12),
 197:               Wrap(
 198:                 spacing: 10,
 199:                 runSpacing: 10,
 200:                 children: [
 201:                   FilledButton.icon(
 202:                     onPressed: _isDeleting || _selectedCheckInIds.isEmpty
 203:                         ? null
 204:                         : _confirmClearSelected,
 205:                     icon: const Icon(Icons.delete_sweep_rounded),
 206:                     label: Text(
 207:                       'Clear Selected (${_selectedCheckInIds.length})',
 208:                     ),
 209:                   ),
 210:                   OutlinedButton.icon(
 211:                     onPressed: _isDeleting || checkIns.isEmpty
 212:                         ? null
 213:                         : () => _showClearOptions(checkIns.length),
 214:                     icon: const Icon(Icons.cleaning_services_rounded),
 215:                     label: const Text('Clear Check-ins'),
 216:                   ),
 217:                 ],
 218:               ),
 219:             ],
 220:           ),
 221:         ),
 222:         const SizedBox(height: 14),
 223:         if (_isDeleting)
 224:           const Padding(
 225:             padding: EdgeInsets.only(bottom: 14),
 226:             child: LinearProgressIndicator(),
 227:           ),
 228:         if (checkIns.isEmpty)
 229:           const AppCard(
 230:             child: ListTile(
 231:               leading: Icon(Icons.event_available_outlined),
 232:               title: Text('No check-ins yet'),
 233:               subtitle: Text('New QR and manual check-ins will appear here.'),
 234:             ),
 235:           )
 236:         else if (filtered.isEmpty)
 237:           const AppCard(
 238:             child: ListTile(
 239:               leading: Icon(Icons.search_off_rounded),
 240:               title: Text('No matching check-ins'),
 241:               subtitle: Text('Change the search or event filter.'),
 242:             ),
 243:           )
 244:         else ...[
 245:           Row(
 246:             children: [
 247:               Checkbox(
 248:                 value: filtered.every(
 249:                   (checkIn) => _selectedCheckInIds.contains(checkIn.id),
 250:                 ),
 251:                 tristate:
 252:                     filtered.any(
 253:                       (checkIn) => _selectedCheckInIds.contains(checkIn.id),
 254:                     ) &&
 255:                     !filtered.every(
 256:                       (checkIn) => _selectedCheckInIds.contains(checkIn.id),
 257:                     ),
 258:                 onChanged: _isDeleting
 259:                     ? null
 260:                     : (selected) {
 261:                         setState(() {
 262:                           if (selected == true) {
 263:                             _selectedCheckInIds.addAll(
 264:                               filtered.map((checkIn) => checkIn.id),
 265:                             );
 266:                           } else {
 267:                             _selectedCheckInIds.removeAll(
 268:                               filtered.map((checkIn) => checkIn.id),
 269:                             );
 270:                           }
 271:                         });
 272:                       },
 273:               ),
 274:               Expanded(
 275:                 child: Text(
 276:                   '${filtered.length} check-in'
 277:                   '${filtered.length == 1 ? '' : 's'} shown',
 278:                   style: const TextStyle(fontWeight: FontWeight.w800),
 279:                 ),
 280:               ),
 281:             ],
 282:           ),
 283:           const SizedBox(height: 6),
 284:           ...filtered.map(_buildCheckInCard),
 285:         ],
 286:       ],
 287:     );
 288:   }
 289: 
 290:   Widget _buildCheckInCard(CheckInRecord checkIn) {
 291:     final displayName = checkIn.displayName.trim().isEmpty
 292:         ? 'Unnamed Member'
 293:         : checkIn.displayName.trim();
 294:     final isSelected = _selectedCheckInIds.contains(checkIn.id);
 295:     final dateLabel = checkIn.checkedInAt == null
 296:         ? 'Date unavailable'
 297:         : _formatDateTime(checkIn.checkedInAt!);
 298:     final eventLabel = checkIn.eventId.trim().isEmpty
 299:         ? 'Unspecified event'
 300:         : checkIn.eventId.trim();
 301: 
 302:     return AppCard(
 303:       child: CheckboxListTile(
 304:         value: isSelected,
 305:         onChanged: _isDeleting
 306:             ? null
 307:             : (selected) {
 308:                 setState(() {
 309:                   if (selected == true) {
 310:                     _selectedCheckInIds.add(checkIn.id);
 311:                   } else {
 312:                     _selectedCheckInIds.remove(checkIn.id);
 313:                   }
 314:                 });
 315:               },
 316:         controlAffinity: ListTileControlAffinity.leading,
 317:         secondary: IconButton(
 318:           tooltip: 'Remove this check-in',
 319:           onPressed: _isDeleting ? null : () => _confirmDeleteOne(checkIn),
 320:           icon: const Icon(Icons.delete_outline_rounded),
 321:         ),
 322:         title: Text(
 323:           displayName,
 324:           style: const TextStyle(fontWeight: FontWeight.w900),
 325:         ),
 326:         subtitle: Text(
 327:           'Event: $eventLabel\n'
 328:           '$dateLabel Ã¢â‚¬Â¢ ${checkIn.checkInMethod.toUpperCase()}',
 329:         ),
 330:         isThreeLine: true,
 331:       ),
 332:     );
 333:   }
 334: 
 335:   Future<void> _showClearOptions(int totalLoaded) async {
 336:     final selectedScope = await showModalBottomSheet<_ClearCheckInScope>(
 337:       context: context,
 338:       showDragHandle: true,
 339:       builder: (sheetContext) {
 340:         return SafeArea(
 341:           child: Padding(
 342:             padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
 343:             child: Column(
 344:               mainAxisSize: MainAxisSize.min,
 345:               children: [
 346:                 const ListTile(
 347:                   title: Text(
 348:                     'Clear Check-ins',
 349:                     style: TextStyle(fontWeight: FontWeight.w900),
 350:                   ),
 351:                   subtitle: Text(
 352:                     'Choose exactly which attendance records to remove.',
 353:                   ),
 354:                 ),
 355:                 ListTile(
 356:                   leading: const CircleAvatar(child: Icon(Icons.today_rounded)),
 357:                   title: const Text('Clear TodayÃ¢â‚¬â„¢s Check-ins'),
 358:                   subtitle: const Text(
 359:                     'Remove check-ins recorded on the current local date.',
 360:                   ),
 361:                   onTap: () => ChurchSnapNavigation.closeAllWindows(
 362:                     sheetContext,
 363:                     result: _ClearCheckInScope.today,
 364:                   ),
 365:                 ),
 366:                 if (_selectedEventId != null)
 367:                   ListTile(
 368:                     leading: const CircleAvatar(
 369:                       child: Icon(Icons.event_busy_rounded),
 370:                     ),
 371:                     title: const Text('Clear Current Event'),
 372:                     subtitle: Text(
 373:                       'Remove every check-in for $_selectedEventId.',
 374:                     ),
 375:                     onTap: () => Navigator.of(
 376:                       sheetContext,
 377:                     ).pop(_ClearCheckInScope.event),
 378:                   ),
 379:                 ListTile(
 380:                   leading: const CircleAvatar(
 381:                     child: Icon(Icons.delete_forever_rounded),
 382:                   ),
 383:                   title: const Text('Clear All Check-ins'),
 384:                   subtitle: Text(
 385:                     'Permanently remove all check-ins. '
 386:                     '$totalLoaded recent records are currently displayed.',
 387:                   ),
 388:                   onTap: () => ChurchSnapNavigation.closeAllWindows(
 389:                     sheetContext,
 390:                     result: _ClearCheckInScope.all,
 391:                   ),
 392:                 ),
 393:               ],
 394:             ),
 395:           ),
 396:         );
 397:       },
 398:     );
 399: 
 400:     if (selectedScope == null || !mounted) {
 401:       return;
 402:     }
 403: 
 404:     await _confirmAndClearScope(selectedScope);
 405:   }
 406: 
 407:   Future<void> _confirmDeleteOne(CheckInRecord checkIn) async {
 408:     final displayName = checkIn.displayName.trim().isEmpty
 409:         ? 'this member'
 410:         : checkIn.displayName.trim();
 411: 
 412:     final confirmed = await showDialog<bool>(
 413:       context: context,
 414:       builder: (dialogContext) => AlertDialog(
 415:         title: const Text('Remove this check-in?'),
 416:         content: Text(
 417:           'The attendance entry for $displayName will be permanently removed.',
 418:         ),
 419:         actions: [
 420:           TextButton(
 421:             onPressed: () => ChurchSnapNavigation.closeAllWindows(
 422:               dialogContext,
 423:               result: false,
 424:             ),
 425:             child: const Text('Cancel'),
 426:           ),
 427:           FilledButton.icon(
 428:             onPressed: () => ChurchSnapNavigation.closeAllWindows(
 429:               dialogContext,
 430:               result: true,
 431:             ),
 432:             icon: const Icon(Icons.delete_outline_rounded),
 433:             label: const Text('Remove'),
 434:           ),
 435:         ],
 436:       ),
 437:     );
 438: 
 439:     if (confirmed != true || !mounted) {
 440:       return;
 441:     }
 442: 
 443:     await _runDelete(
 444:       operation: () => _repository.deleteCheckIn(checkIn.id),
 445:       successLabel: 'check-in removed',
 446:     );
 447:   }
 448: 
 449:   Future<void> _confirmClearSelected() async {
 450:     final count = _selectedCheckInIds.length;
 451:     final confirmed = await showDialog<bool>(
 452:       context: context,
 453:       builder: (dialogContext) => AlertDialog(
 454:         title: Text('Clear $count selected check-in${count == 1 ? '' : 's'}?'),
 455:         content: const Text(
 456:           'The selected attendance records will be permanently removed.',
 457:         ),
 458:         actions: [
 459:           TextButton(
 460:             onPressed: () => ChurchSnapNavigation.closeAllWindows(
 461:               dialogContext,
 462:               result: false,
 463:             ),
 464:             child: const Text('Cancel'),
 465:           ),
 466:           FilledButton.icon(
 467:             onPressed: () => ChurchSnapNavigation.closeAllWindows(
 468:               dialogContext,
 469:               result: true,
 470:             ),
 471:             icon: const Icon(Icons.delete_sweep_rounded),
 472:             label: const Text('Clear Selected'),
 473:           ),
 474:         ],
 475:       ),
 476:     );
 477: 
 478:     if (confirmed != true || !mounted) {
 479:       return;
 480:     }
 481: 
 482:     final ids = Set<String>.from(_selectedCheckInIds);
 483: 
 484:     await _runDelete(
 485:       operation: () => _repository.deleteSelectedCheckIns(ids),
 486:       successLabel: 'selected check-ins cleared',
 487:       clearSelection: true,
 488:     );
 489:   }
 490: 
 491:   Future<void> _confirmAndClearScope(_ClearCheckInScope scope) async {
 492:     if (scope == _ClearCheckInScope.all) {
 493:       await _confirmClearAll();
 494:       return;
 495:     }
 496: 
 497:     final isToday = scope == _ClearCheckInScope.today;
 498:     final title = isToday
 499:         ? 'Clear todayÃ¢â‚¬â„¢s check-ins?'
 500:         : 'Clear current event check-ins?';
 501:     final message = isToday
 502:         ? 'All check-ins recorded today will be permanently removed.'
 503:         : 'Every check-in for $_selectedEventId will be permanently removed.';
 504: 
 505:     final confirmed = await showDialog<bool>(
 506:       context: context,
 507:       builder: (dialogContext) => AlertDialog(
 508:         title: Text(title),
 509:         content: Text(message),
 510:         actions: [
 511:           TextButton(
 512:             onPressed: () => ChurchSnapNavigation.closeAllWindows(
 513:               dialogContext,
 514:               result: false,
 515:             ),
 516:             child: const Text('Cancel'),
 517:           ),
 518:           FilledButton.icon(
 519:             onPressed: () => ChurchSnapNavigation.closeAllWindows(
 520:               dialogContext,
 521:               result: true,
 522:             ),
 523:             icon: const Icon(Icons.cleaning_services_rounded),
 524:             label: const Text('Clear Check-ins'),
 525:           ),
 526:         ],
 527:       ),
 528:     );
 529: 
 530:     if (confirmed != true || !mounted) {
 531:       return;
 532:     }
 533: 
 534:     if (isToday) {
 535:       await _runDelete(
 536:         operation: () => _repository.clearCheckInsForDate(DateTime.now()),
 537:         successLabel: 'todayÃ¢â‚¬â„¢s check-ins cleared',
 538:         clearSelection: true,
 539:       );
 540:     } else {
 541:       final eventId = _selectedEventId;
 542: 
 543:       if (eventId == null) {
 544:         return;
 545:       }
 546: 
 547:       await _runDelete(
 548:         operation: () => _repository.clearCheckInsForEvent(eventId),
 549:         successLabel: 'event check-ins cleared',
 550:         clearSelection: true,
 551:       );
 552:     }
 553:   }
 554: 
 555:   Future<void> _confirmClearAll() async {
 556:     final confirmationController = TextEditingController();
 557: 
 558:     final confirmed = await showDialog<bool>(
 559:       context: context,
 560:       builder: (dialogContext) {
 561:         var canClear = false;
 562: 
 563:         return StatefulBuilder(
 564:           builder: (context, setDialogState) {
 565:             return AlertDialog(
 566:               title: const Text('Clear every check-in?'),
 567:               content: SingleChildScrollView(
 568:                 child: Column(
 569:                   mainAxisSize: MainAxisSize.min,
 570:                   crossAxisAlignment: CrossAxisAlignment.start,
 571:                   children: [
 572:                     const Text(
 573:                       'This permanently deletes every attendance check-in for '
 574:                       'this church. This action cannot be undone.',
 575:                     ),
 576:                     const SizedBox(height: 16),
 577:                     TextField(
 578:                       controller: confirmationController,
 579:                       autocorrect: false,
 580:                       textCapitalization: TextCapitalization.characters,
 581:                       decoration: const InputDecoration(
 582:                         labelText: 'Type CLEAR to continue',
 583:                         border: OutlineInputBorder(),
 584:                       ),
 585:                       onChanged: (value) {
 586:                         setDialogState(() {
 587:                           canClear = value.trim().toUpperCase() == 'CLEAR';
 588:                         });
 589:                       },
 590:                     ),
 591:                   ],
 592:                 ),
 593:               ),
 594:               actions: [
 595:                 TextButton(
 596:                   onPressed: () => ChurchSnapNavigation.closeAllWindows(
 597:                     dialogContext,
 598:                     result: false,
 599:                   ),
 600:                   child: const Text('Cancel'),
 601:                 ),
 602:                 FilledButton.icon(
 603:                   onPressed: canClear
 604:                       ? () => Navigator.of(dialogContext).pop(true)
 605:                       : null,
 606:                   icon: const Icon(Icons.delete_forever_rounded),
 607:                   label: const Text('Clear Everything'),
 608:                 ),
 609:               ],
 610:             );
 611:           },
 612:         );
 613:       },
 614:     );
 615: 
 616:     confirmationController.dispose();
 617: 
 618:     if (confirmed != true || !mounted) {
 619:       return;
 620:     }
 621: 
 622:     await _runDelete(
 623:       operation: _repository.clearAllCheckIns,
 624:       successLabel: 'all check-ins cleared',
 625:       clearSelection: true,
 626:     );
 627:   }
 628: 
 629:   Future<void> _runDelete({
 630:     required Future<int> Function() operation,
 631:     required String successLabel,
 632:     bool clearSelection = false,
 633:   }) async {
 634:     setState(() {
 635:       _isDeleting = true;
 636:     });
 637: 
 638:     try {
 639:       final deletedCount = await operation();
 640: 
 641:       if (!mounted) {
 642:         return;
 643:       }
 644: 
 645:       if (clearSelection) {
 646:         _selectedCheckInIds.clear();
 647:       }
 648: 
 649:       ScaffoldMessenger.of(context).showSnackBar(
 650:         SnackBar(
 651:           content: Text(
 652:             deletedCount == 0
 653:                 ? 'No matching check-ins were found.'
 654:                 : '$deletedCount $successLabel.',
 655:           ),
 656:         ),
 657:       );
 658:     } catch (error) {
 659:       if (!mounted) {
 660:         return;
 661:       }
 662: 
 663:       ScaffoldMessenger.of(context).showSnackBar(
 664:         SnackBar(content: Text('Unable to clear check-ins: $error')),
 665:       );
 666:     } finally {
 667:       if (mounted) {
 668:         setState(() {
 669:           _isDeleting = false;
 670:         });
 671:       }
 672:     }
 673:   }
 674: 
 675:   static String _formatDateTime(DateTime dateTime) {
 676:     final local = dateTime.toLocal();
 677:     final month = local.month.toString().padLeft(2, '0');
 678:     final day = local.day.toString().padLeft(2, '0');
 679:     final hour = local.hour.toString().padLeft(2, '0');
 680:     final minute = local.minute.toString().padLeft(2, '0');
```

## Member attendance history screen

Source: `.\lib\screens\profile\attendance_history_screen.dart`

```dart
   1: import 'package:flutter/material.dart';
   2: 
   3: import '../../core/widgets/churchsnap_screen.dart';
   4: import '../../features/attendance/models/attendance_record.dart';
   5: import '../../features/attendance/repositories/attendance_history_repository.dart';
   6: 
   7: class AttendanceHistoryScreen extends StatelessWidget {
   8:   const AttendanceHistoryScreen({
   9:     super.key,
  10:     required this.memberId,
  11:     required this.churchId,
  12:   });
  13: 
  14:   final String memberId;
  15:   final String churchId;
  16: 
  17:   @override
  18:   Widget build(BuildContext context) {
  19:     final repository = AttendanceHistoryRepository(churchId: churchId);
  20: 
  21:     return Material(
  22:       child: ChurchSnapScreen(
  23:         title: 'Attendance History',
  24:         subtitle: 'Your recent church check-ins',
  25:         children: [
  26:           StreamBuilder<List<AttendanceRecord>>(
  27:             stream: repository.watchMemberAttendance(memberId),
  28:             builder: (context, snapshot) {
  29:               if (snapshot.connectionState == ConnectionState.waiting) {
  30:                 return const AppCard(
  31:                   child: Center(child: CircularProgressIndicator()),
  32:                 );
  33:               }
  34: 
  35:               if (snapshot.hasError) {
  36:                 return AppCard(
  37:                   child: ListTile(
  38:                     leading: const Icon(Icons.error_outline_rounded),
  39:                     title: const Text('Unable to load attendance history'),
  40:                     subtitle: Text('${snapshot.error}'),
  41:                   ),
  42:                 );
  43:               }
  44: 
  45:               final records = snapshot.data ?? <AttendanceRecord>[];
  46: 
  47:               if (records.isEmpty) {
  48:                 return const AppCard(
  49:                   child: ListTile(
  50:                     leading: Icon(Icons.event_busy_rounded),
  51:                     title: Text('No attendance records found'),
  52:                     subtitle: Text(
  53:                       'Your check-ins will appear here '
  54:                       'after attending events.',
  55:                     ),
  56:                   ),
  57:                 );
  58:               }
  59: 
  60:               return Column(
  61:                 children: records.map((record) {
  62:                   final checkedIn = record.checkedInAt;
  63: 
  64:                   final dateText = checkedIn == null
  65:                       ? 'Date unavailable'
  66:                       : '${checkedIn.month}/'
  67:                             '${checkedIn.day}/'
  68:                             '${checkedIn.year}  '
  69:                             '${checkedIn.hour.toString().padLeft(2, '0')}:'
  70:                             '${checkedIn.minute.toString().padLeft(2, '0')}';
  71: 
  72:                   return AppCard(
  73:                     child: ListTile(
  74:                       contentPadding: EdgeInsets.zero,
  75:                       leading: const CircleAvatar(
  76:                         child: Icon(Icons.check_circle_rounded),
  77:                       ),
  78:                       title: Text(
  79:                         record.eventTitle,
  80:                         style: const TextStyle(fontWeight: FontWeight.bold),
  81:                       ),
  82:                       subtitle: Text(dateText),
  83:                       trailing: Chip(
  84:                         label: Text(record.checkInMethod.toUpperCase()),
  85:                       ),
  86:                     ),
  87:                   );
  88:                 }).toList(),
  89:               );
  90:             },
  91:           ),
  92:         ],
  93:       ),
  94:     );
  95:   }
  96: }
```

## Firestore eventCheckIns rules

### Lines 414-544

```text
 414:                   in resource.data.get('attendeeIds', [])
 415:                 && !(currentUserId()
 416:                   in request.resource.data.get('attendeeIds', []))
 417:                 && request.resource.data.get('attendeeIds', []).size() + 1
 418:                   == resource.data.get('attendeeIds', []).size()
 419:                 && resource.data.get('attendeeIds', [])
 420:                   .hasAll(request.resource.data.get('attendeeIds', []))
 421:               )
 422:             )
 423:           );
 424:       }
 425:       match /resources/{resourceId} {
 426:         allow read: if resource.data.published == true
 427:           || isAdmin(churchId);
 428: 
 429:         allow create, update, delete: if isAdmin(churchId);
 430:       }
 431: 
 432:       match /sermons/{sermonId} {
 433:         allow read: if resource.data.get('published', false) == true
 434:           || isAdmin(churchId);
 435: 
 436:         allow create, update, delete: if isAdmin(churchId);
 437:       }
 438: 
 439:       match /prayer_requests/{prayerId} {
 440:         allow read: if resource.data.get('published', false) == true
 441:           || isLeader(churchId);
 442: 
 443:         allow create: if isApprovedMember(churchId);
 444:         allow update, delete: if isLeader(churchId);
 445:       }
 446: 
 447:       match /media/{mediaId} {
 448:         allow read: if resource.data.get('published', false) == true
 449:           || isApprovedMember(churchId);
 450: 
 451:         allow create, update, delete: if isAdmin(churchId);
 452:       }
 453: 
 454:       match /eventCheckIns/{checkInId} {
 455:         allow read: if isAdmin(churchId)
 456:           || (
 457:             isApprovedMember(churchId)
 458:             && ownsAttendanceRecord(resource.data)
 459:           );
 460: 
 461:         allow create: if isAdmin(churchId)
 462:           || (
 463:             isApprovedMember(churchId)
 464:             && validSelfAttendanceRecord(request.resource.data)
 465:           );
 466: 
 467:         allow update, delete: if isAdmin(churchId);
 468:       }
 469: 
 470:       match /attendance/{attendanceId} {
 471:         allow read: if isAdmin(churchId)
 472:           || (
 473:             isApprovedMember(churchId)
 474:             && ownsAttendanceRecord(resource.data)
 475:           );
 476: 
 477:         allow create: if isAdmin(churchId)
 478:           || (
 479:             isApprovedMember(churchId)
 480:             && validSelfAttendanceRecord(request.resource.data)
 481:           );
 482: 
 483:         allow update, delete: if isAdmin(churchId);
 484:       }
 485: 
 486:       match /settings/{settingId} {
 487:         allow read: if signedIn();
 488:         allow create, update, delete: if isAdmin(churchId);
 489:       }
 490: 
 491:       match /notifications/{notificationId} {
 492:         allow get, list: if isApprovedMember(churchId)
 493:           && canReadNotification(churchId, resource.data);
 494: 
 495:         allow create: if isAdmin(churchId)
 496:           && validNotificationAudience(
 497:             request.resource.data.get('targetRole', 'all')
 498:           )
 499:           && request.resource.data.get('title', '') is string
 500:           && request.resource.data.get('title', '').size() > 0
 501:           && request.resource.data.get('body', '') is string
 502:           && request.resource.data.get('body', '').size() > 0;
 503: 
 504:         allow update: if isAdmin(churchId)
 505:           && validNotificationAudience(
 506:             request.resource.data.get('targetRole', 'all')
 507:           );
 508: 
 509:         allow delete: if isAdmin(churchId);
 510:       }
 511: 
 512:       match /ministries/{ministryId} {
 513:         allow read: if isApprovedMember(churchId);
 514: 
 515:         allow create: if isAdmin(churchId)
 516:           || (
 517:             isMinistryLeader(churchId)
 518:             && request.resource.data.get('leaderId', '') == currentUserId()
 519:           );
 520: 
 521:         allow update: if isAdmin(churchId)
 522:           || (
 523:             isMinistryLeader(churchId)
 524:             && resource.data.get('leaderId', '') == currentUserId()
 525:             && request.resource.data.get('leaderId', '') == currentUserId()
 526:           );
 527: 
 528:         allow delete: if isAdmin(churchId)
 529:           || (
 530:             isMinistryLeader(churchId)
 531:             && resource.data.get('leaderId', '') == currentUserId()
 532:           );
 533:       }
 534: 
 535:       match /small_groups/{groupId} {
 536:         allow read: if isApprovedMember(churchId);
 537: 
 538:         allow create: if isAdmin(churchId)
 539:           || (
 540:             isGroupLeader(churchId)
 541:             && request.resource.data.get('leaderId', '') == currentUserId()
 542:           );
 543: 
 544:         allow update: if isAdmin(churchId)
```

## Firestore legacy attendance rules

### Lines 445-540

```text
 445:       }
 446: 
 447:       match /media/{mediaId} {
 448:         allow read: if resource.data.get('published', false) == true
 449:           || isApprovedMember(churchId);
 450: 
 451:         allow create, update, delete: if isAdmin(churchId);
 452:       }
 453: 
 454:       match /eventCheckIns/{checkInId} {
 455:         allow read: if isAdmin(churchId)
 456:           || (
 457:             isApprovedMember(churchId)
 458:             && ownsAttendanceRecord(resource.data)
 459:           );
 460: 
 461:         allow create: if isAdmin(churchId)
 462:           || (
 463:             isApprovedMember(churchId)
 464:             && validSelfAttendanceRecord(request.resource.data)
 465:           );
 466: 
 467:         allow update, delete: if isAdmin(churchId);
 468:       }
 469: 
 470:       match /attendance/{attendanceId} {
 471:         allow read: if isAdmin(churchId)
 472:           || (
 473:             isApprovedMember(churchId)
 474:             && ownsAttendanceRecord(resource.data)
 475:           );
 476: 
 477:         allow create: if isAdmin(churchId)
 478:           || (
 479:             isApprovedMember(churchId)
 480:             && validSelfAttendanceRecord(request.resource.data)
 481:           );
 482: 
 483:         allow update, delete: if isAdmin(churchId);
 484:       }
 485: 
 486:       match /settings/{settingId} {
 487:         allow read: if signedIn();
 488:         allow create, update, delete: if isAdmin(churchId);
 489:       }
 490: 
 491:       match /notifications/{notificationId} {
 492:         allow get, list: if isApprovedMember(churchId)
 493:           && canReadNotification(churchId, resource.data);
 494: 
 495:         allow create: if isAdmin(churchId)
 496:           && validNotificationAudience(
 497:             request.resource.data.get('targetRole', 'all')
 498:           )
 499:           && request.resource.data.get('title', '') is string
 500:           && request.resource.data.get('title', '').size() > 0
 501:           && request.resource.data.get('body', '') is string
 502:           && request.resource.data.get('body', '').size() > 0;
 503: 
 504:         allow update: if isAdmin(churchId)
 505:           && validNotificationAudience(
 506:             request.resource.data.get('targetRole', 'all')
 507:           );
 508: 
 509:         allow delete: if isAdmin(churchId);
 510:       }
 511: 
 512:       match /ministries/{ministryId} {
 513:         allow read: if isApprovedMember(churchId);
 514: 
 515:         allow create: if isAdmin(churchId)
 516:           || (
 517:             isMinistryLeader(churchId)
 518:             && request.resource.data.get('leaderId', '') == currentUserId()
 519:           );
 520: 
 521:         allow update: if isAdmin(churchId)
 522:           || (
 523:             isMinistryLeader(churchId)
 524:             && resource.data.get('leaderId', '') == currentUserId()
 525:             && request.resource.data.get('leaderId', '') == currentUserId()
 526:           );
 527: 
 528:         allow delete: if isAdmin(churchId)
 529:           || (
 530:             isMinistryLeader(churchId)
 531:             && resource.data.get('leaderId', '') == currentUserId()
 532:           );
 533:       }
 534: 
 535:       match /small_groups/{groupId} {
 536:         allow read: if isApprovedMember(churchId);
 537: 
 538:         allow create: if isAdmin(churchId)
 539:           || (
 540:             isGroupLeader(churchId)
```

## Attendance collection references

| File | Line | Source |
| --- | ---: | --- |
| `lib/features/attendance/models/attendance_record.dart` | 3 | `class AttendanceRecord {` |
| `lib/features/attendance/models/attendance_record.dart` | 4 | `const AttendanceRecord({` |
| `lib/features/attendance/models/attendance_record.dart` | 11 | `this.checkedInAt,` |
| `lib/features/attendance/models/attendance_record.dart` | 20 | `final DateTime? checkedInAt;` |
| `lib/features/attendance/models/attendance_record.dart` | 22 | `factory AttendanceRecord.fromMap(` |
| `lib/features/attendance/models/attendance_record.dart` | 27 | `final checkedInAtValue = map['checkedInAt'];` |
| `lib/features/attendance/models/attendance_record.dart` | 37 | `return AttendanceRecord(` |
| `lib/features/attendance/models/attendance_record.dart` | 44 | `checkedInAt: checkedInAtValue is Timestamp` |
| `lib/features/attendance/models/attendance_record.dart` | 45 | `? checkedInAtValue.toDate()` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 3 | `import '../models/attendance_record.dart';` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 5 | `class AttendanceHistoryRepository {` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 6 | `AttendanceHistoryRepository({` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 17 | `.collection('eventCheckIns');` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 22 | `Stream<List<AttendanceRecord>> watchMemberAttendance(String memberId) {` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 26 | `return Stream.value(const <AttendanceRecord>[]);` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 41 | `final records = await Future.wait<AttendanceRecord>(` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 66 | `return AttendanceRecord.fromMap(` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 76 | `first.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);` |
| `lib/features/attendance/repositories/attendance_history_repository.dart` | 79 | `second.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 65 | `final checkInId = '${cleanEventId}_$cleanMemberId';` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 67 | `final checkInRef = _churchRef.collection('eventCheckIns').doc(checkInId);` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 83 | `throw StateError('duplicate-check-in');` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 91 | `'checkedInAt': FieldValue.serverTimestamp(),` |
| `lib/features/attendance/services/qr_check_in_service.dart` | 102 | `if (error.message == 'duplicate-check-in') {` |
| `lib/features/check_in/models/check_in_record.dart` | 9 | `this.checkedInAt,` |
| `lib/features/check_in/models/check_in_record.dart` | 17 | `final DateTime? checkedInAt;` |
| `lib/features/check_in/models/check_in_record.dart` | 21 | `final checkedInAtValue = data['checkedInAt'];` |
| `lib/features/check_in/models/check_in_record.dart` | 33 | `checkedInAt: checkedInAtValue is Timestamp` |
| `lib/features/check_in/models/check_in_record.dart` | 34 | `? checkedInAtValue.toDate()` |
| `lib/features/check_in/models/check_in_record.dart` | 35 | `: checkedInAtValue is DateTime` |
| `lib/features/check_in/models/check_in_record.dart` | 36 | `? checkedInAtValue` |
| `lib/features/check_in/models/check_in_record.dart` | 52 | `'checkedInAt': checkedInAt == null` |
| `lib/features/check_in/models/check_in_record.dart` | 54 | `: Timestamp.fromDate(checkedInAt!),` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 19 | `.collection('eventCheckIns');` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 34 | `.orderBy('checkedInAt', descending: true)` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 40 | `Future<int> deleteCheckIn(String checkInId) async {` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 41 | `final normalizedId = checkInId.trim();` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 45 | `checkInId,` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 46 | `'checkInId',` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 62 | `Future<int> deleteSelectedCheckIns(Iterable<String> checkInIds) async {` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 63 | `final uniqueIds = checkInIds` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 111 | `'checkedInAt',` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 114 | `.where('checkedInAt', isLessThan: Timestamp.fromDate(end)),` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 127 | `left.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);` |
| `lib/features/check_in/repositories/check_in_repository.dart` | 129 | `right.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);` |
| `lib/features/dashboard/repositories/dashboard_repository.dart` | 63 | `.collection('eventCheckIns')` |
| `lib/screens/admin/admin_attendance_screen.dart` | 10 | `class AdminAttendanceScreen extends StatefulWidget {` |
| `lib/screens/admin/admin_attendance_screen.dart` | 11 | `const AdminAttendanceScreen({super.key, this.churchId = 'demo-church'});` |
| `lib/screens/admin/admin_attendance_screen.dart` | 16 | `State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();` |
| `lib/screens/admin/admin_attendance_screen.dart` | 19 | `class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {` |
| `lib/screens/admin/admin_attendance_screen.dart` | 22 | `final Set<String> _selectedCheckInIds = <String>{};` |
| `lib/screens/admin/admin_attendance_screen.dart` | 44 | `title: 'Attendance & Check-ins',` |
| `lib/screens/admin/admin_attendance_screen.dart` | 57 | `'Clearing check-ins permanently removes the selected attendance '` |
| `lib/screens/admin/admin_attendance_screen.dart` | 89 | `return _buildAttendanceContent(checkIns);` |
| `lib/screens/admin/admin_attendance_screen.dart` | 97 | `Widget _buildAttendanceContent(List<CheckInRecord> checkIns) {` |
| `lib/screens/admin/admin_attendance_screen.dart` | 129 | `_selectedCheckInIds.removeWhere(` |
| `lib/screens/admin/admin_attendance_screen.dart` | 192 | `_selectedCheckInIds.clear();` |
| `lib/screens/admin/admin_attendance_screen.dart` | 202 | `onPressed: _isDeleting \|\| _selectedCheckInIds.isEmpty` |
| `lib/screens/admin/admin_attendance_screen.dart` | 207 | `'Clear Selected (${_selectedCheckInIds.length})',` |
| `lib/screens/admin/admin_attendance_screen.dart` | 249 | `(checkIn) => _selectedCheckInIds.contains(checkIn.id),` |
| `lib/screens/admin/admin_attendance_screen.dart` | 253 | `(checkIn) => _selectedCheckInIds.contains(checkIn.id),` |
| `lib/screens/admin/admin_attendance_screen.dart` | 256 | `(checkIn) => _selectedCheckInIds.contains(checkIn.id),` |
| `lib/screens/admin/admin_attendance_screen.dart` | 263 | `_selectedCheckInIds.addAll(` |
| `lib/screens/admin/admin_attendance_screen.dart` | 267 | `_selectedCheckInIds.removeAll(` |
| `lib/screens/admin/admin_attendance_screen.dart` | 294 | `final isSelected = _selectedCheckInIds.contains(checkIn.id);` |
| `lib/screens/admin/admin_attendance_screen.dart` | 295 | `final dateLabel = checkIn.checkedInAt == null` |
| `lib/screens/admin/admin_attendance_screen.dart` | 297 | `: _formatDateTime(checkIn.checkedInAt!);` |
| `lib/screens/admin/admin_attendance_screen.dart` | 310 | `_selectedCheckInIds.add(checkIn.id);` |
| `lib/screens/admin/admin_attendance_screen.dart` | 312 | `_selectedCheckInIds.remove(checkIn.id);` |
| `lib/screens/admin/admin_attendance_screen.dart` | 352 | `'Choose exactly which attendance records to remove.',` |
| `lib/screens/admin/admin_attendance_screen.dart` | 417 | `'The attendance entry for $displayName will be permanently removed.',` |
| `lib/screens/admin/admin_attendance_screen.dart` | 450 | `final count = _selectedCheckInIds.length;` |
| `lib/screens/admin/admin_attendance_screen.dart` | 456 | `'The selected attendance records will be permanently removed.',` |
| `lib/screens/admin/admin_attendance_screen.dart` | 482 | `final ids = Set<String>.from(_selectedCheckInIds);` |
| `lib/screens/admin/admin_attendance_screen.dart` | 573 | `'This permanently deletes every attendance check-in for '` |
| `lib/screens/admin/admin_attendance_screen.dart` | 646 | `_selectedCheckInIds.clear();` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 6 | `import 'admin_attendance_screen.dart';` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 192 | `title: 'Attendance',` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 194 | `screen: AdminAttendanceScreen(churchId: churchId),` |
| `lib/screens/admin/admin_dashboard_screen.dart` | 252 | `subtitle: 'Scan member QR codes and record attendance',` |
| `lib/screens/admin/admin_member_directory_screen.dart` | 58 | `'It does not delete the account, giving history, attendance, '` |
| `lib/screens/admin/admin_member_profile_screen.dart` | 128 | `title: Text('Attendance History'),` |
| `lib/screens/admin/admin_qr_scanner_screen.dart` | 5 | `import '../../features/attendance/services/qr_check_in_service.dart';` |
| `lib/screens/profile/attendance_history_screen.dart` | 4 | `import '../../features/attendance/models/attendance_record.dart';` |
| `lib/screens/profile/attendance_history_screen.dart` | 5 | `import '../../features/attendance/repositories/attendance_history_repository.dart';` |
| `lib/screens/profile/attendance_history_screen.dart` | 7 | `class AttendanceHistoryScreen extends StatelessWidget {` |
| `lib/screens/profile/attendance_history_screen.dart` | 8 | `const AttendanceHistoryScreen({` |
| `lib/screens/profile/attendance_history_screen.dart` | 19 | `final repository = AttendanceHistoryRepository(churchId: churchId);` |
| `lib/screens/profile/attendance_history_screen.dart` | 23 | `title: 'Attendance History',` |
| `lib/screens/profile/attendance_history_screen.dart` | 26 | `StreamBuilder<List<AttendanceRecord>>(` |
| `lib/screens/profile/attendance_history_screen.dart` | 27 | `stream: repository.watchMemberAttendance(memberId),` |
| `lib/screens/profile/attendance_history_screen.dart` | 39 | `title: const Text('Unable to load attendance history'),` |
| `lib/screens/profile/attendance_history_screen.dart` | 45 | `final records = snapshot.data ?? <AttendanceRecord>[];` |
| `lib/screens/profile/attendance_history_screen.dart` | 51 | `title: Text('No attendance records found'),` |
| `lib/screens/profile/attendance_history_screen.dart` | 62 | `final checkedIn = record.checkedInAt;` |
| `lib/screens/profile/profile_screen.dart` | 6 | `import 'attendance_history_screen.dart';` |
| `lib/screens/profile/profile_screen.dart` | 179 | `'Attendance History',` |
| `lib/screens/profile/profile_screen.dart` | 188 | `builder: (_) => AttendanceHistoryScreen(` |

## Existing attendance and QR tests

| File | Line | Source |
| --- | ---: | --- |
| `test/features/check_in/check_in_record_test.dart` | 6 | `group('CheckInRecord', () {` |
| `test/features/check_in/check_in_record_test.dart` | 7 | `test('parses the legacy manual check-in field names', () {` |
| `test/features/check_in/check_in_record_test.dart` | 8 | `final record = CheckInRecord.fromMap('legacy-1', <String, dynamic>{` |
| `test/features/check_in/check_in_record_test.dart` | 12 | `'checkInMethod': 'manual',` |
| `test/features/check_in/check_in_record_test.dart` | 19 | `expect(record.checkInMethod, 'manual');` |
| `test/features/check_in/check_in_record_test.dart` | 22 | `test('parses the QR attendance field names', () {` |
| `test/features/check_in/check_in_record_test.dart` | 23 | `final record = CheckInRecord.fromMap('qr-1', <String, dynamic>{` |
| `test/features/check_in/check_in_record_test.dart` | 26 | `'memberName': 'QR Member',` |
| `test/features/check_in/check_in_record_test.dart` | 27 | `'checkInMethod': 'qr',` |
| `test/features/check_in/check_in_record_test.dart` | 32 | `expect(record.displayName, 'QR Member');` |
| `test/features/check_in/check_in_record_test.dart` | 33 | `expect(record.checkInMethod, 'qr');` |
| `test/features/check_in/check_in_record_test.dart` | 36 | `test('writes compatible legacy and QR member fields', () {` |
| `test/features/check_in/check_in_record_test.dart` | 37 | `const record = CheckInRecord(` |
| `test/features/check_in/check_in_record_test.dart` | 42 | `checkInMethod: 'manual',` |
| `test/features/giving/giving_currency_test.dart` | 55 | `test('removes duplicate and unsupported enabled currencies', () {` |
| `test/features/giving/standard_giving_funds_test.dart` | 43 | `test('does not duplicate existing standard funds', () {` |
| `test/features/members/member_demographics_summary_test.dart` | 107 | `test('calculates age after checking whether birthday occurred', () {` |

## Stabilization questions

- Is eventCheckIns the only active attendance write target?
- Is the check-in document ID deterministic enough to prevent duplicate scans?
- Does duplicate protection survive simultaneous scans from different devices?
- Are member, event, service, scanner, and timestamp fields canonical?
- Does member Attendance History read the same records written by the scanner?
- Are administrator deletion controls scoped and irreversible as intended?
- Are self-check-in rules still reachable by current application code?
- Can legacy ttendance documents be safely classified after a live-data review?
- Are focused repository and service tests missing?


## Stabilization outcome

The QR path was already transactionally duplicate-safe. Stabilization extends the same deterministic `{eventId}_{memberId}` identity to manual check-ins, writes canonical and compatibility member fields, and scopes member Attendance History to ownership-filtered Firestore queries. No Firestore rules change is required.