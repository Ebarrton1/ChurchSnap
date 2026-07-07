import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../announcements/repositories/announcement_repository.dart';
import '../services/admin_announcement_service.dart';
import '../../events/repositories/event_repository.dart';
import '../services/admin_event_service.dart';

final adminAnnouncementServiceProvider = Provider<AdminAnnouncementService>((
  ref,
) {
  return AdminAnnouncementService(AnnouncementRepository());
});

final adminEventServiceProvider = Provider<AdminEventService>((ref) {
  return AdminEventService(EventRepository());
});
