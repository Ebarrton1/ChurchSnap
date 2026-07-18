import 'package:cloud_firestore/cloud_firestore.dart';

class MemberCountPolicy {
  const MemberCountPolicy._();

  static bool isRemoved(Map<String, dynamic> data) {
    return data['directoryVisible'] == false;
  }

  static bool countsInOverview(Map<String, dynamic> data) {
    return !isRemoved(data);
  }
}

class MemberCountSummary {
  const MemberCountSummary({
    required this.totalRecords,
    required this.overviewCount,
    required this.removedCount,
  });

  final int totalRecords;
  final int overviewCount;
  final int removedCount;

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

    for (final data in records) {
      totalRecords += 1;

      if (MemberCountPolicy.isRemoved(data)) {
        removedCount += 1;
      } else {
        overviewCount += 1;
      }
    }

    return MemberCountSummary(
      totalRecords: totalRecords,
      overviewCount: overviewCount,
      removedCount: removedCount,
    );
  }
}
