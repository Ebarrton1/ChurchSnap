import 'dart:math' as math;

class MemberCelebrationProfile {
  const MemberCelebrationProfile({
    required this.memberId,
    required this.memberName,
    required this.role,
    required this.isActive,
    required this.maritalStatus,
    required this.dateOfBirth,
    required this.weddingAnniversaryDate,
    required this.birthdayReminderEnabled,
    required this.anniversaryReminderEnabled,
  });

  final String memberId;
  final String memberName;
  final String role;
  final bool isActive;
  final String maritalStatus;
  final DateTime? dateOfBirth;
  final DateTime? weddingAnniversaryDate;
  final bool birthdayReminderEnabled;
  final bool anniversaryReminderEnabled;

  bool get isVisitor {
    final normalizedRole = _key(role);
    return normalizedRole == 'visitor' || normalizedRole == 'guest';
  }

  bool get isEligibleMember => isActive && !isVisitor;
  bool get isMarried => _key(maritalStatus) == 'married';

  factory MemberCelebrationProfile.fromRecords({
    required String memberId,
    required Map<String, dynamic> member,
    required Map<String, dynamic> privateProfile,
  }) {
    return MemberCelebrationProfile(
      memberId: memberId,
      memberName: (member['displayName']?.toString() ?? '').trim(),
      role: (member['role']?.toString() ?? 'member').trim(),
      isActive: member['isActive'] as bool? ?? true,
      maritalStatus: (privateProfile['maritalStatus']?.toString() ?? '').trim(),
      dateOfBirth: _dateFromValue(privateProfile['dateOfBirth']),
      weddingAnniversaryDate: _dateFromValue(
        privateProfile['weddingAnniversaryDate'],
      ),
      birthdayReminderEnabled:
          privateProfile['birthdayReminderEnabled'] as bool? ?? true,
      anniversaryReminderEnabled:
          privateProfile['anniversaryReminderEnabled'] as bool? ?? true,
    );
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value.trim());
    }

    if (value != null) {
      try {
        final dynamic converted = value.toDate();

        if (converted is DateTime) {
          return converted;
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  static String _key(dynamic value) {
    return (value?.toString() ?? '').trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '',
    );
  }
}

class MemberCelebrationSettings {
  const MemberCelebrationSettings({
    required this.memberId,
    required this.weddingAnniversaryDate,
    required this.birthdayReminderEnabled,
    required this.anniversaryReminderEnabled,
  });

  final String memberId;
  final DateTime? weddingAnniversaryDate;
  final bool birthdayReminderEnabled;
  final bool anniversaryReminderEnabled;
}

enum CelebrationType { birthday, weddingAnniversary }

class UpcomingCelebration {
  const UpcomingCelebration({
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.originalDate,
    required this.nextOccurrence,
    required this.daysUntil,
  });

  final String memberId;
  final String memberName;
  final CelebrationType type;
  final DateTime originalDate;
  final DateTime nextOccurrence;
  final int daysUntil;

  bool get isToday => daysUntil == 0;

  String get typeLabel {
    return switch (type) {
      CelebrationType.birthday => 'Birthday',
      CelebrationType.weddingAnniversary => 'Wedding Anniversary',
    };
  }
}

class UpcomingCelebrationCalculator {
  const UpcomingCelebrationCalculator._();

  static List<UpcomingCelebration> calculate({
    required Iterable<MemberCelebrationProfile> profiles,
    DateTime? now,
    int windowDays = 7,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final results = <UpcomingCelebration>[];

    for (final profile in profiles) {
      if (!profile.isEligibleMember) {
        continue;
      }

      final birthday = profile.dateOfBirth;

      if (birthday != null && profile.birthdayReminderEnabled) {
        _addIfUpcoming(
          results: results,
          memberId: profile.memberId,
          memberName: profile.memberName,
          type: CelebrationType.birthday,
          originalDate: birthday,
          today: today,
          windowDays: windowDays,
        );
      }

      final anniversary = profile.weddingAnniversaryDate;

      if (anniversary != null &&
          profile.anniversaryReminderEnabled &&
          profile.isMarried) {
        _addIfUpcoming(
          results: results,
          memberId: profile.memberId,
          memberName: profile.memberName,
          type: CelebrationType.weddingAnniversary,
          originalDate: anniversary,
          today: today,
          windowDays: windowDays,
        );
      }
    }

    results.sort((left, right) {
      final dayComparison = left.daysUntil.compareTo(right.daysUntil);

      if (dayComparison != 0) {
        return dayComparison;
      }

      final typeComparison = left.type.index.compareTo(right.type.index);

      if (typeComparison != 0) {
        return typeComparison;
      }

      return left.memberName.toLowerCase().compareTo(
        right.memberName.toLowerCase(),
      );
    });

    return List<UpcomingCelebration>.unmodifiable(results);
  }

  static void _addIfUpcoming({
    required List<UpcomingCelebration> results,
    required String memberId,
    required String memberName,
    required CelebrationType type,
    required DateTime originalDate,
    required DateTime today,
    required int windowDays,
  }) {
    var occurrence = _occurrenceForYear(originalDate, today.year);

    if (occurrence.isBefore(today)) {
      occurrence = _occurrenceForYear(originalDate, today.year + 1);
    }

    final daysUntil = occurrence.difference(today).inDays;

    if (daysUntil < 0 || daysUntil > windowDays) {
      return;
    }

    results.add(
      UpcomingCelebration(
        memberId: memberId,
        memberName: memberName.isEmpty ? 'Unnamed Member' : memberName,
        type: type,
        originalDate: originalDate,
        nextOccurrence: occurrence,
        daysUntil: daysUntil,
      ),
    );
  }

  static DateTime _occurrenceForYear(DateTime source, int year) {
    final lastDayOfMonth = DateTime(year, source.month + 1, 0).day;
    final day = math.min(source.day, lastDayOfMonth);

    return DateTime(year, source.month, day);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
