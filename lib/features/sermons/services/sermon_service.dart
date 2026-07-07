import '../../../models/sermon.dart';
import '../repositories/sermon_repository.dart';

class SermonService {
  SermonService(this._repository);

  final SermonRepository _repository;

  Stream<List<Sermon>> watchPublishedSermons() {
    return _repository.watchPublishedSermons();
  }
}
