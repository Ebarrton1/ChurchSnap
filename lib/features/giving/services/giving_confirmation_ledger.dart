import '../models/giving_currency.dart';
import '../models/giving_submission.dart';

class GivingConfirmationLedger {
  const GivingConfirmationLedger._();

  static String donationDocumentId(String submissionId) {
    final cleanId = submissionId.trim();

    if (cleanId.isEmpty) {
      throw ArgumentError.value(
        submissionId,
        'submissionId',
        'A giving submission ID is required.',
      );
    }

    return cleanId;
  }

  static Map<String, dynamic> donationFields({
    required GivingSubmission submission,
    required int confirmedAmountMinorUnits,
    required GivingCurrency confirmedCurrency,
    required String confirmedByUid,
    String adminNote = '',
  }) {
    if (confirmedAmountMinorUnits <= 0) {
      throw ArgumentError.value(
        confirmedAmountMinorUnits,
        'confirmedAmountMinorUnits',
        'Confirmed amount must be greater than zero.',
      );
    }

    final cleanAdminUid = confirmedByUid.trim();

    if (cleanAdminUid.isEmpty) {
      throw ArgumentError.value(
        confirmedByUid,
        'confirmedByUid',
        'The confirming administrator UID is required.',
      );
    }

    final submissionId = donationDocumentId(submission.id);

    return <String, dynamic>{
      'memberId': submission.giverId.trim(),
      'memberName': submission.giverName.trim().isEmpty
          ? 'ChurchSnap Giver'
          : submission.giverName.trim(),
      'fundId': submission.fundId.trim(),
      'fundName': submission.fundName.trim().isEmpty
          ? 'General Giving'
          : submission.fundName.trim(),
      'description': submission.description.trim(),
      'amountCents': confirmedAmountMinorUnits,
      'currency': confirmedCurrency.code,
      'status': 'completed',
      'recurring': submission.recurring,
      'reference': 'giving-submission:$submissionId',
      'sourceSubmissionId': submissionId,
      'confirmedByUid': cleanAdminUid,
      'adminNote': adminNote.trim(),
    };
  }

  static bool matchesConfirmedSubmission({
    required GivingSubmission submission,
    required int confirmedAmountMinorUnits,
    required GivingCurrency confirmedCurrency,
    String adminNote = '',
  }) {
    return submission.status == GivingSubmissionStatus.confirmed &&
        submission.confirmedAmountMinorUnits == confirmedAmountMinorUnits &&
        submission.confirmedCurrencyCode == confirmedCurrency.code &&
        (submission.adminNote ?? '').trim() == adminNote.trim();
  }
}
