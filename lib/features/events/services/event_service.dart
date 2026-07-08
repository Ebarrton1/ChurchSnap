import '../repositories/event_repository.dart';

class EventService {
  EventService(this._repository);

  final EventRepository _repository;

  Future<void> rsvp({required String eventId, required String userId}) {
    return _repository.rsvpToEvent(eventId: eventId, userId: userId);
  }

  Future<void> cancelRsvp({required String eventId, required String userId}) {
    return _repository.cancelRsvp(eventId: eventId, userId: userId);
  }
}
