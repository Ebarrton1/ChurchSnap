import '../models/ministry.dart';
import '../repositories/ministry_repository.dart';

class MinistryService {
  MinistryService(this._repository);

  final MinistryRepository _repository;

  Stream<List<Ministry>> watchMinistries() {
    return _repository.watchMinistries();
  }

  Future<void> addMinistry(Ministry ministry) {
    return _repository.addMinistry(ministry);
  }

  Future<void> updateMinistry(Ministry ministry) {
    return _repository.updateMinistry(ministry);
  }

  Future<void> deleteMinistry(String ministryId) {
    return _repository.deleteMinistry(ministryId);
  }
}
