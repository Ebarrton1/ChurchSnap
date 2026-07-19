enum WebAdminReportPeriod { thirtyDays, ninetyDays, oneYear, allTime }

class WebAdminReportSource {
  const WebAdminReportSource({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}

class WebAdminReportEvent {
  const WebAdminReportEvent({
    required this.id,
    required this.title,
    required this.location,
    required this.startsAt,
  });

  final String id;
  final String title;
  final String location;
  final DateTime startsAt;
}

class WebAdminReportSnapshot {
  const WebAdminReportSnapshot({
    required this.totalMembers,
    required this.activeMembers,
    required this.memberFollowUp,
    required this.openPrayerRequests,
    required this.resolvedPrayerRequests,
    required this.recordedDonationCount,
    required this.givingByCurrency,
    required this.givingByFund,
    required this.membersByRole,
    required this.prayerByStatus,
    required this.upcomingEvents,
  });

  final int totalMembers;
  final int activeMembers;
  final int memberFollowUp;
  final int openPrayerRequests;
  final int resolvedPrayerRequests;
  final int recordedDonationCount;
  final Map<String, double> givingByCurrency;
  final Map<String, double> givingByFund;
  final Map<String, int> membersByRole;
  final Map<String, int> prayerByStatus;
  final List<WebAdminReportEvent> upcomingEvents;
}
