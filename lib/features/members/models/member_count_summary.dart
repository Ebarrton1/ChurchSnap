import 'package:cloud_firestore/cloud_firestore.dart';

class MemberCountPolicy {
  const MemberCountPolicy._();

  static const Set<String> protectedRoles = <String>{'admin', 'pastor'};

  static bool isProtectedRole(String role) {
    return protectedRoles.contains(role.trim());
  }

  static bool isVisitorRole(String role) {
    return role.trim() == 'visitor';
  }

  static bool isDirectoryVisible(Map<String, dynamic> data) {
    return data['directoryVisible'] as bool? ?? true;
  }

  static bool isActive(Map<String, dynamic> data) {
    return data['isActive'] as bool? ?? true;
  }

  static bool countsInOverview(Map<String, dynamic> data) {
    final role = (data['role']?.toString() ?? 'member').trim();

    return isDirectoryVisible(data) &&
        isActive(data) &&
        !isProtectedRole(role) &&
        !isVisitorRole(role);
  }

  static bool isExplicitDemoRecord(Map<String, dynamic> data) {
    final source =
        (data['dataOrigin']?.toString() ??
                data['recordSource']?.toString() ??
                '')
            .trim()
            .toLowerCase();

    return data['isDemo'] == true ||
        data['isSampleData'] == true ||
        source == 'demo' ||
        source == 'sample';
  }
}

class MemberCountSummary {
  const MemberCountSummary({
    required this.totalRecords,
    required this.overviewCount,
    required this.removedCount,
    required this.inactiveCount,
    required this.protectedCount,
    required this.visitorCount,
    required this.explicitDemoCount,
  });

  final int totalRecords;
  final int overviewCount;
  final int removedCount;
  final int inactiveCount;
  final int protectedCount;
  final int visitorCount;
  final int explicitDemoCount;

  factory MemberCountSummary.fromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return MemberCountSummary.fromRecords(
      snapshot.docs.map((document) => document.data()),
    );
  }

  factory MemberCountSummary.fromRecords(
    Iterable<Map<String, dynamic>> records,
  ) {
    var totalRecords = 0;
    var overviewCount = 0;
    var removedCount = 0;
    var inactiveCount = 0;
    var protectedCount = 0;
    var visitorCount = 0;
    var explicitDemoCount = 0;

    for (final data in records) {
      totalRecords += 1;

      final role = (data['role']?.toString() ?? 'member').trim();

      if (MemberCountPolicy.countsInOverview(data)) {
        overviewCount += 1;
      }

      if (!MemberCountPolicy.isDirectoryVisible(data)) {
        removedCount += 1;
      }

      if (!MemberCountPolicy.isActive(data)) {
        inactiveCount += 1;
      }

      if (MemberCountPolicy.isProtectedRole(role)) {
        protectedCount += 1;
      }

      if (MemberCountPolicy.isVisitorRole(role)) {
        visitorCount += 1;
      }

      if (MemberCountPolicy.isExplicitDemoRecord(data)) {
        explicitDemoCount += 1;
      }
    }

    return MemberCountSummary(
      totalRecords: totalRecords,
      overviewCount: overviewCount,
      removedCount: removedCount,
      inactiveCount: inactiveCount,
      protectedCount: protectedCount,
      visitorCount: visitorCount,
      explicitDemoCount: explicitDemoCount,
    );
  }
}
