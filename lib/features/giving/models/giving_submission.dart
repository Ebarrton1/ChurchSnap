import 'package:cloud_firestore/cloud_firestore.dart';

import 'giving_currency.dart';

enum GivingSubmissionStatus {
  pending,
  confirmed,
  rejected;

  static GivingSubmissionStatus fromValue(Object? value) {
    final text = value is String ? value.trim().toLowerCase() : '';

    return GivingSubmissionStatus.values.firstWhere(
      (status) => status.name == text,
      orElse: () => GivingSubmissionStatus.pending,
    );
  }
}

class GivingSubmission {
  const GivingSubmission({
    required this.id,
    required this.giverId,
    required this.giverName,
    required this.fundId,
    required this.fundName,
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.currencySymbol,
    required this.recurring,
    required this.status,
    this.submittedAt,
    this.confirmedAmountMinorUnits,
    this.confirmedCurrencyCode,
    this.confirmedCurrencySymbol,
    this.confirmedByUid,
    this.confirmedAt,
    this.adminNote,
  });

  final String id;
  final String giverId;
  final String giverName;
  final String fundId;
  final String fundName;
  final int amountMinorUnits;
  final String currencyCode;
  final String currencySymbol;
  final bool recurring;
  final GivingSubmissionStatus status;
  final DateTime? submittedAt;
  final int? confirmedAmountMinorUnits;
  final String? confirmedCurrencyCode;
  final String? confirmedCurrencySymbol;
  final String? confirmedByUid;
  final DateTime? confirmedAt;
  final String? adminNote;

  GivingCurrency get submittedCurrency => GivingCurrency.byCode(currencyCode);

  GivingCurrency get confirmedCurrency =>
      GivingCurrency.byCode(confirmedCurrencyCode ?? currencyCode);

  String get submittedAmountLabel =>
      submittedCurrency.formatMinorUnits(amountMinorUnits);

  String? get confirmedAmountLabel {
    final amount = confirmedAmountMinorUnits;

    if (amount == null) {
      return null;
    }

    return confirmedCurrency.formatMinorUnits(amount);
  }

  static GivingSubmission fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    DateTime? readDate(Object? value) {
      return value is Timestamp ? value.toDate() : null;
    }

    int? readInt(Object? value) {
      return value is int ? value : null;
    }

    return GivingSubmission(
      id: document.id,
      giverId: (data['giverId'] as String?)?.trim() ?? '',
      giverName: (data['giverName'] as String?)?.trim() ?? 'ChurchSnap Giver',
      fundId: (data['fundId'] as String?)?.trim() ?? '',
      fundName: (data['fundName'] as String?)?.trim() ?? 'General Giving',
      amountMinorUnits: readInt(data['amountMinorUnits']) ?? 0,
      currencyCode: (data['currencyCode'] as String?)?.trim() ?? 'USD',
      currencySymbol: (data['currencySymbol'] as String?)?.trim() ?? r'$',
      recurring: data['recurring'] == true,
      status: GivingSubmissionStatus.fromValue(data['status']),
      submittedAt: readDate(data['submittedAt']),
      confirmedAmountMinorUnits: readInt(data['confirmedAmountMinorUnits']),
      confirmedCurrencyCode: (data['confirmedCurrencyCode'] as String?)?.trim(),
      confirmedCurrencySymbol: (data['confirmedCurrencySymbol'] as String?)
          ?.trim(),
      confirmedByUid: (data['confirmedByUid'] as String?)?.trim(),
      confirmedAt: readDate(data['confirmedAt']),
      adminNote: (data['adminNote'] as String?)?.trim(),
    );
  }
}
