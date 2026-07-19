import 'package:cloud_firestore/cloud_firestore.dart';

class DonationRecord {
  const DonationRecord({
    this.id = '',
    required this.memberId,
    required this.memberName,
    required this.fundId,
    required this.fundName,
    required this.amountCents,
    this.currency = 'USD',
    this.status = 'completed',
    this.recurring = false,
    this.reference = '',
    this.description = '',
    this.receivedAt,
    this.createdAt,
  });

  final String id;
  final String memberId;
  final String memberName;
  final String fundId;
  final String fundName;
  final int amountCents;
  final String currency;
  final String status;
  final bool recurring;
  final String reference;
  final String description;
  final DateTime? receivedAt;
  final DateTime? createdAt;

  double get amount => amountCents / 100;

  factory DonationRecord.fromMap(String id, Map<String, dynamic> map) {
    return DonationRecord(
      id: id,
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? 'ChurchSnap Member',
      fundId: map['fundId'] as String? ?? '',
      fundName: map['fundName'] as String? ?? 'General Giving',
      amountCents: (map['amountCents'] as num?)?.toInt() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      status: map['status'] as String? ?? 'completed',
      recurring: map['recurring'] as bool? ?? false,
      reference: map['reference'] as String? ?? '',
      description:
          (map['description'] as String?)?.trim() ??
          (map['donationDescription'] as String?)?.trim() ??
          (map['memo'] as String?)?.trim() ??
          '',
      receivedAt: _dateFromValue(map['receivedAt']),
      createdAt: _dateFromValue(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId.trim(),
      'memberName': memberName.trim(),
      'fundId': fundId.trim(),
      'fundName': fundName.trim(),
      'amountCents': amountCents,
      'currency': currency.trim().isEmpty ? 'USD' : currency.trim(),
      'status': status.trim().isEmpty ? 'completed' : status.trim(),
      'recurring': recurring,
      'reference': reference.trim(),
      'description': description.trim(),
      'receivedAt': receivedAt,
    };
  }

  static DateTime? _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
