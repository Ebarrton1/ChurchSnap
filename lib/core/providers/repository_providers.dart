import '../../features/sermons/repositories/sermon_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/announcements/repositories/announcement_repository.dart';
import '../../features/events/repositories/event_repository.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository();
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

final sermonRepositoryProvider = Provider<SermonRepository>((ref) {
  return SermonRepository();
});
