import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/event_repository.dart';
import '../services/event_service.dart';

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => EventRepository(),
);

final eventServiceProvider = Provider<EventService>(
  (ref) => EventService(ref.read(eventRepositoryProvider)),
);
