import '../../../models/prayer_request.dart';
import '../repositories/prayer_repository.dart';

class PrayerService {
  PrayerService(this._repository);

  final PrayerRepository _repository;

  Stream<List<PrayerRequest>> watchPublishedPrayerRequests() {
    return _repository.watchPublishedPrayerRequests();
  }

  Stream<List<PrayerRequest>> watchAllPrayerRequests() {
    return _repository.watchAllPrayerRequests();
  }

  Future<void> submitPrayerRequest(PrayerRequest request) {
    return _repository.addPrayerRequest(request);
  }

  Future<void> setPublished({
    required String prayerId,
    required bool published,
  }) {
    return _repository.setPublished(prayerId: prayerId, published: published);
  }

  Future<void> deletePrayerRequest(String prayerId) {
    return _repository.deletePrayerRequest(prayerId);
  }
}
