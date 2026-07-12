import '../../../models/church_event.dart';
import '../repositories/event_repository.dart';

class EventService {
  EventService(this._repository);

  final EventRepository _repository;

  Stream<List<ChurchEvent>> watchPublishedEvents() {
    return _repository.watchPublishedEvents();
  }

  Stream<List<ChurchEvent>> watchAllEvents() {
    return _repository.watchAllEvents();
  }

  Future<void> rsvp({required String eventId, required String userId}) {
    return _repository.rsvpToEvent(eventId: eventId, userId: userId);
  }

  Future<void> cancelRsvp({required String eventId, required String userId}) {
    return _repository.cancelRsvp(eventId: eventId, userId: userId);
  }
}
