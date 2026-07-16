class MemberBaptismRecord {
  const MemberBaptismRecord({
    required this.memberId,
    required this.memberName,
    required this.photoUrl,
    required this.role,
    required this.isActive,
    required this.baptismDate,
  });

  final String memberId;
  final String memberName;
  final String photoUrl;
  final String role;
  final bool isActive;
  final DateTime? baptismDate;

  bool get isVisitor {
    final normalizedRole = _key(role);
    return normalizedRole == 'visitor' || normalizedRole == 'guest';
  }

  bool get isEligibleMember => isActive && !isVisitor;

  factory MemberBaptismRecord.fromRecords({
    required String memberId,
    required Map<String, dynamic> member,
    required Map<String, dynamic> privateProfile,
  }) {
    return MemberBaptismRecord(
      memberId: memberId,
      memberName: (member['displayName']?.toString() ?? '').trim(),
      photoUrl: (member['photoUrl']?.toString() ?? '').trim(),
      role: (member['role']?.toString() ?? 'member').trim(),
      isActive: member['isActive'] as bool? ?? true,
      baptismDate: dateFromValue(privateProfile['baptismDate']),
    );
  }

  static DateTime? dateFromValue(dynamic value) {
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

class MemberBaptismCalculator {
  const MemberBaptismCalculator._();

  static const int recentWindowDays = 30;

  static List<MemberBaptismRecord> recent({
    required Iterable<MemberBaptismRecord> records,
    DateTime? now,
    int windowDays = recentWindowDays,
  }) {
    if (windowDays < 1) {
      return const <MemberBaptismRecord>[];
    }

    final today = _dateOnly(now ?? DateTime.now());
    final firstIncludedDate = today.subtract(Duration(days: windowDays - 1));

    final results = records.where((record) {
      final baptismDate = record.baptismDate;

      if (!record.isEligibleMember || baptismDate == null) {
        return false;
      }

      final date = _dateOnly(baptismDate);

      return !date.isBefore(firstIncludedDate) && !date.isAfter(today);
    }).toList();

    results.sort((left, right) {
      final leftDate = _dateOnly(left.baptismDate!);
      final rightDate = _dateOnly(right.baptismDate!);
      final dateComparison = rightDate.compareTo(leftDate);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return left.memberName.toLowerCase().compareTo(
        right.memberName.toLowerCase(),
      );
    });

    return List<MemberBaptismRecord>.unmodifiable(results);
  }

  static int daysSinceBaptism({required DateTime baptismDate, DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final date = _dateOnly(baptismDate);

    return today.difference(date).inDays;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
