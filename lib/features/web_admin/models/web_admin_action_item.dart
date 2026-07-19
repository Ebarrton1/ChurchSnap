enum WebAdminActionKind { prayer, event, member, giving }

enum WebAdminActionPriority { urgent, normal, low }

class WebAdminActionSource {
  const WebAdminActionSource({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}

class WebAdminActionItem {
  const WebAdminActionItem({
    required this.kind,
    required this.priority,
    required this.sourceId,
    required this.title,
    required this.detail,
    this.dueAt,
  });

  final WebAdminActionKind kind;
  final WebAdminActionPriority priority;
  final String sourceId;
  final String title;
  final String detail;
  final DateTime? dueAt;
}
