import '../../../models/prayer_request.dart';
import '../repositories/prayer_repository.dart';

class PrayerService {
  PrayerService(this._repository);

  final PrayerRepository _repository;

  Stream<List<PrayerRequest>> watchPublishedPrayerRequests() {
    return _repository.watchPublishedPrayerRequests();
  }
}
