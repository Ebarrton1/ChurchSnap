import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/event_repository.dart';
import '../services/event_service.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService(ref.read(eventRepositoryProvider));
});

final eventRepositoryByChurchProvider =
    Provider.family<EventRepository, String>((ref, churchId) {
      return EventRepository(churchId: churchId);
    });

final eventServiceByChurchProvider = Provider.family<EventService, String>((
  ref,
  churchId,
) {
  return EventService(ref.watch(eventRepositoryByChurchProvider(churchId)));
});
