import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/web_admin_action_item.dart';
import '../models/web_admin_donation_amount.dart';

class WebAdminActionCenterBuilder {
  const WebAdminActionCenterBuilder._();

  static List<WebAdminActionItem> build({
    required Iterable<WebAdminActionSource> prayerRequests,
    required Iterable<WebAdminActionSource> events,
    required Iterable<WebAdminActionSource> members,
    required Iterable<WebAdminActionSource> donations,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final items = <WebAdminActionItem>[
      ..._prayerItems(prayerRequests),
      ..._eventItems(events, reference),
      ..._memberItems(members),
      ..._givingItems(donations),
    ];

    items.sort((left, right) {
      final priorityComparison = left.priority.index.compareTo(
        right.priority.index,
      );

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      final leftDate = left.dueAt ?? DateTime(9999);
      final rightDate = right.dueAt ?? DateTime(9999);
      return leftDate.compareTo(rightDate);
    });

    return List<WebAdminActionItem>.unmodifiable(items);
  }

  static Iterable<WebAdminActionItem> _prayerItems(
    Iterable<WebAdminActionSource> sources,
  ) sync* {
    const completedStatuses = {
      'answered',
      'closed',
      'complete',
      'completed',
      'resolved',
    };

    for (final source in sources) {
      final data = source.data;
      final status = _status(data);

      if (completedStatuses.contains(status)) {
        continue;
      }

      final member = _text(data, const [
        'memberName',
        'displayName',
        'name',
      ], fallback: 'Anonymous or private member');
      final request = _text(data, const [
        'request',
        'prayer',
        'body',
        'message',
      ], fallback: 'Prayer request text not provided');
      final priorityText = _text(data, const [
        'priority',
        'urgency',
      ], fallback: '').toLowerCase();
      final urgent =
          data['isUrgent'] == true ||
          data['urgent'] == true ||
          const {'emergency', 'high', 'urgent'}.contains(priorityText);

      yield WebAdminActionItem(
        kind: WebAdminActionKind.prayer,
        priority: urgent
            ? WebAdminActionPriority.urgent
            : WebAdminActionPriority.normal,
        sourceId: source.id,
        title: 'Prayer care: $member',
        detail: _excerpt(request),
        dueAt: _firstDate(data, const [
          'createdAt',
          'submittedAt',
          'updatedAt',
        ]),
      );
    }
  }

  static Iterable<WebAdminActionItem> _eventItems(
    Iterable<WebAdminActionSource> sources,
    DateTime reference,
  ) sync* {
    final earliest = reference.subtract(const Duration(days: 1));
    final latest = reference.add(const Duration(days: 30));
    const excludedStatuses = {'cancelled', 'canceled', 'complete', 'completed'};

    for (final source in sources) {
      final data = source.data;
      final status = _status(data);

      if (excludedStatuses.contains(status)) {
        continue;
      }

      final start = _firstDate(data, const [
        'startDate',
        'eventDate',
        'date',
        'startsAt',
      ]);

      if (start == null || start.isBefore(earliest) || start.isAfter(latest)) {
        continue;
      }

      final title = _text(data, const [
        'title',
        'name',
      ], fallback: 'Untitled event');
      final location = _text(data, const [
        'location',
        'venue',
      ], fallback: 'Location not set');

      yield WebAdminActionItem(
        kind: WebAdminActionKind.event,
        priority: start.difference(reference).inDays <= 7
            ? WebAdminActionPriority.normal
            : WebAdminActionPriority.low,
        sourceId: source.id,
        title: title,
        detail: 'Upcoming event â€¢ $location',
        dueAt: start,
      );
    }
  }

  static Iterable<WebAdminActionItem> _memberItems(
    Iterable<WebAdminActionSource> sources,
  ) sync* {
    const reviewStatuses = {
      'incomplete',
      'needs review',
      'needs_review',
      'pending',
      'pending review',
      'pending_review',
    };

    for (final source in sources) {
      final data = source.data;
      final status = _status(data);
      final needsFollowUp =
          data['needsFollowUp'] == true ||
          data['needsReview'] == true ||
          data['profileComplete'] == false ||
          reviewStatuses.contains(status);

      if (!needsFollowUp) {
        continue;
      }

      final name = _text(data, const [
        'displayName',
        'fullName',
        'name',
      ], fallback: 'Member profile');

      yield WebAdminActionItem(
        kind: WebAdminActionKind.member,
        priority: WebAdminActionPriority.normal,
        sourceId: source.id,
        title: name,
        detail: 'Member profile needs administrative follow-up.',
        dueAt: _firstDate(data, const ['updatedAt', 'createdAt', 'joinedAt']),
      );
    }
  }

  static Iterable<WebAdminActionItem> _givingItems(
    Iterable<WebAdminActionSource> sources,
  ) sync* {
    const exceptionStatuses = {
      'failed',
      'pending',
      'processing',
      'requires action',
      'requires_action',
    };

    for (final source in sources) {
      final data = source.data;
      final status = _status(data);

      if (!exceptionStatuses.contains(status)) {
        continue;
      }

      final donor = _text(data, const [
        'memberName',
        'donorName',
        'displayName',
      ], fallback: 'Member name not stored');
      final fund = _text(data, const [
        'fundName',
        'fund',
        'category',
      ], fallback: 'Fund not set');
      final amount = _money(
        WebAdminDonationAmount.read(data),
        currency: _text(data, const ['currency'], fallback: 'USD'),
      );
      final urgent =
          status == 'failed' ||
          status == 'requires action' ||
          status == 'requires_action';

      yield WebAdminActionItem(
        kind: WebAdminActionKind.giving,
        priority: urgent
            ? WebAdminActionPriority.urgent
            : WebAdminActionPriority.normal,
        sourceId: source.id,
        title: '$amount - $donor',
        detail: '$fund â€¢ ${status.isEmpty ? 'Status not set' : status}',
        dueAt: _firstDate(data, const ['createdAt', 'updatedAt', 'date']),
      );
    }
  }

  static String _status(Map<String, dynamic> data) {
    return _text(data, const ['status'], fallback: '').toLowerCase();
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

  static String _excerpt(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalized.length <= 140) {
      return normalized;
    }

    return '${normalized.substring(0, 137)}...';
  }

  static String _money(dynamic value, {required String currency}) {
    final amount = switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text.trim()),
      _ => null,
    };

    final normalizedCurrency = currency.trim().isEmpty
        ? 'USD'
        : currency.trim().toUpperCase();

    if (amount == null) {
      return '$normalizedCurrency amount not set';
    }

    return '$normalizedCurrency ${amount.toStringAsFixed(2)}';
  }
}
