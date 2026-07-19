import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/web_admin_audit_entry.dart';

enum WebAdminAuditPeriod { all, today, sevenDays, thirtyDays }

class WebAdminAuditLogService {
  WebAdminAuditLogService({
    required FirebaseFirestore firestore,
    required String churchId,
  }) : this._(firestore, churchId);

  WebAdminAuditLogService._(this._firestore, this._churchId);

  final FirebaseFirestore _firestore;
  final String _churchId;

  Stream<List<WebAdminAuditEntry>> watchEntries() {
    return _firestore
        .collection('churches')
        .doc(_churchId)
        .collection('admin_audit_logs')
        .orderBy('createdAt', descending: true)
        .limit(300)
        .snapshots()
        .map((snapshot) {
          return List<WebAdminAuditEntry>.unmodifiable(
            snapshot.docs.map(
              (document) => WebAdminAuditEntry.fromMap(
                id: document.id,
                data: document.data(),
              ),
            ),
          );
        });
  }

  static List<WebAdminAuditEntry> filterEntries({
    required Iterable<WebAdminAuditEntry> entries,
    required String search,
    required String? action,
    required WebAdminAuditPeriod period,
    DateTime? now,
  }) {
    final query = search.trim().toLowerCase();
    final reference = now ?? DateTime.now();
    final earliest = switch (period) {
      WebAdminAuditPeriod.all => null,
      WebAdminAuditPeriod.today => DateTime(
        reference.year,
        reference.month,
        reference.day,
      ),
      WebAdminAuditPeriod.sevenDays => reference.subtract(
        const Duration(days: 7),
      ),
      WebAdminAuditPeriod.thirtyDays => reference.subtract(
        const Duration(days: 30),
      ),
    };

    return entries
        .where((entry) {
          final searchMatches =
              query.isEmpty || entry.searchableText.contains(query);
          final actionMatches = action == null || entry.action == action;
          final dateMatches =
              earliest == null ||
              (entry.createdAt != null && !entry.createdAt!.isBefore(earliest));

          return searchMatches && actionMatches && dateMatches;
        })
        .toList(growable: false);
  }

  static int countAction(Iterable<WebAdminAuditEntry> entries, String action) {
    return entries.where((entry) => entry.action == action).length;
  }

  static int uniqueActorCount(Iterable<WebAdminAuditEntry> entries) {
    return entries.map((entry) => entry.actorId).toSet().length;
  }

  static int uniqueTargetCount(Iterable<WebAdminAuditEntry> entries) {
    return entries.map((entry) => entry.targetMemberId).toSet().length;
  }
}
