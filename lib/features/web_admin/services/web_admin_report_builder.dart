import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/web_admin_donation_amount.dart';
import '../models/web_admin_report_snapshot.dart';

class WebAdminReportBuilder {
  const WebAdminReportBuilder._();

  static WebAdminReportSnapshot build({
    required Iterable<WebAdminReportSource> members,
    required Iterable<WebAdminReportSource> prayerRequests,
    required Iterable<WebAdminReportSource> events,
    required Iterable<WebAdminReportSource> donations,
    required WebAdminReportPeriod period,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final givingStart = _periodStart(period, reference);
    final givingByCurrency = <String, double>{};
    final givingByFund = <String, double>{};
    final membersByRole = <String, int>{};
    final prayerByStatus = <String, int>{};
    final upcomingEvents = <WebAdminReportEvent>[];

    var totalMembers = 0;
    var activeMembers = 0;
    var memberFollowUp = 0;
    var openPrayerRequests = 0;
    var resolvedPrayerRequests = 0;
    var recordedDonationCount = 0;

    for (final source in members) {
      final data = source.data;
      totalMembers++;

      final active = data['isActive'] is bool
          ? data['isActive'] as bool
          : data['active'] is bool
          ? data['active'] as bool
          : true;

      if (active) {
        activeMembers++;
      }

      if (_memberNeedsFollowUp(data)) {
        memberFollowUp++;
      }

      final role = _text(data, const ['role'], fallback: 'member');
      membersByRole.update(role, (total) => total + 1, ifAbsent: () => 1);
    }

    const resolvedStatuses = {
      'answered',
      'closed',
      'complete',
      'completed',
      'resolved',
    };

    for (final source in prayerRequests) {
      final status = _text(source.data, const [
        'status',
      ], fallback: 'open').toLowerCase();
      final normalizedStatus = status.isEmpty ? 'open' : status;

      prayerByStatus.update(
        normalizedStatus,
        (total) => total + 1,
        ifAbsent: () => 1,
      );

      if (resolvedStatuses.contains(normalizedStatus)) {
        resolvedPrayerRequests++;
      } else {
        openPrayerRequests++;
      }
    }

    const excludedDonationStatuses = {
      'cancelled',
      'canceled',
      'failed',
      'refunded',
      'void',
      'voided',
    };

    for (final source in donations) {
      final data = source.data;
      final status = _text(data, const [
        'status',
      ], fallback: 'recorded').toLowerCase();

      if (excludedDonationStatuses.contains(status)) {
        continue;
      }

      final createdAt = _firstDate(data, const [
        'createdAt',
        'updatedAt',
        'date',
      ]);

      if (givingStart != null &&
          (createdAt == null || createdAt.isBefore(givingStart))) {
        continue;
      }

      final amount = _amount(WebAdminDonationAmount.read(data));

      if (amount == null) {
        continue;
      }

      final currency = _text(data, const [
        'currency',
      ], fallback: 'USD').toUpperCase();
      final fund = _text(data, const [
        'fundName',
        'fund',
        'category',
      ], fallback: 'Unspecified fund');
      final fundKey = '$currency â€¢ $fund';

      recordedDonationCount++;
      givingByCurrency.update(
        currency,
        (total) => total + amount,
        ifAbsent: () => amount,
      );
      givingByFund.update(
        fundKey,
        (total) => total + amount,
        ifAbsent: () => amount,
      );
    }

    final eventLatest = reference.add(const Duration(days: 30));

    for (final source in events) {
      final data = source.data;
      final status = _text(data, const ['status'], fallback: '').toLowerCase();

      if (const {
        'cancelled',
        'canceled',
        'complete',
        'completed',
      }.contains(status)) {
        continue;
      }

      final startsAt = _firstDate(data, const [
        'startDate',
        'eventDate',
        'date',
        'startsAt',
      ]);

      if (startsAt == null ||
          startsAt.isBefore(reference) ||
          startsAt.isAfter(eventLatest)) {
        continue;
      }

      upcomingEvents.add(
        WebAdminReportEvent(
          id: source.id,
          title: _text(data, const [
            'title',
            'name',
          ], fallback: 'Untitled event'),
          location: _text(data, const [
            'location',
            'venue',
          ], fallback: 'Location not set'),
          startsAt: startsAt,
        ),
      );
    }

    upcomingEvents.sort(
      (left, right) => left.startsAt.compareTo(right.startsAt),
    );

    return WebAdminReportSnapshot(
      totalMembers: totalMembers,
      activeMembers: activeMembers,
      memberFollowUp: memberFollowUp,
      openPrayerRequests: openPrayerRequests,
      resolvedPrayerRequests: resolvedPrayerRequests,
      recordedDonationCount: recordedDonationCount,
      givingByCurrency: _sortedDoubleMap(givingByCurrency),
      givingByFund: _sortedDoubleMap(givingByFund),
      membersByRole: _sortedIntMap(membersByRole),
      prayerByStatus: _sortedIntMap(prayerByStatus),
      upcomingEvents: List<WebAdminReportEvent>.unmodifiable(upcomingEvents),
    );
  }

  static DateTime? _periodStart(
    WebAdminReportPeriod period,
    DateTime reference,
  ) {
    return switch (period) {
      WebAdminReportPeriod.thirtyDays => reference.subtract(
        const Duration(days: 30),
      ),
      WebAdminReportPeriod.ninetyDays => reference.subtract(
        const Duration(days: 90),
      ),
      WebAdminReportPeriod.oneYear => reference.subtract(
        const Duration(days: 365),
      ),
      WebAdminReportPeriod.allTime => null,
    };
  }

  static bool _memberNeedsFollowUp(Map<String, dynamic> data) {
    final status = _text(data, const [
      'status',
      'directoryStatus',
    ], fallback: '').toLowerCase();

    return data['needsFollowUp'] == true ||
        data['needsReview'] == true ||
        data['profileComplete'] == false ||
        data['profileNameComplete'] == false ||
        const {
          'incomplete',
          'needs review',
          'needs_review',
          'pending',
          'pending review',
          'pending_review',
        }.contains(status);
  }

  static String _text(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    return fallback;
  }

  static DateTime? _firstDate(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final parsed = _dateTime(data[key]);

      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  static DateTime? _dateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value.trim());
    }

    return null;
  }

  static double? _amount(dynamic value) {
    return switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text.trim()),
      _ => null,
    };
  }

  static Map<String, double> _sortedDoubleMap(Map<String, double> values) {
    final entries = values.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));

    return Map<String, double>.unmodifiable(
      Map<String, double>.fromEntries(entries),
    );
  }

  static Map<String, int> _sortedIntMap(Map<String, int> values) {
    final entries = values.entries.toList()
      ..sort((left, right) {
        final countComparison = right.value.compareTo(left.value);

        if (countComparison != 0) {
          return countComparison;
        }

        return left.key.compareTo(right.key);
      });

    return Map<String, int>.unmodifiable(Map<String, int>.fromEntries(entries));
  }
}
