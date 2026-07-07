import '../../../models/church_event.dart';
import '../../events/repositories/event_repository.dart';

class AdminEventService {
  AdminEventService(this._repository);

  final EventRepository _repository;

  Future<void> publishEvent(ChurchEvent event) {
    return _repository.addEvent(event);
  }

  Future<void> updateEvent(String id, ChurchEvent event) {
    return _repository.updateEvent(id, event);
  }

  Future<void> deleteEvent(String id) {
    return _repository.deleteEvent(id);
  }
}
