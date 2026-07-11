import '../../../models/sermon.dart';
import '../repositories/sermon_repository.dart';

class SermonService {
  SermonService(this._repository);

  final SermonRepository _repository;

  Stream<List<Sermon>> watchPublishedSermons() {
    return _repository.watchPublishedSermons();
  }

  Stream<List<Sermon>> watchAllSermons() {
    return _repository.watchAllSermons();
  }

  Future<String> addSermon(Sermon sermon) {
    return _repository.addSermon(sermon);
  }

  Future<void> updateSermon(String sermonId, Sermon sermon) {
    return _repository.updateSermon(sermonId, sermon);
  }

  Future<void> deleteSermon(String sermonId) {
    return _repository.deleteSermon(sermonId);
  }

  Future<void> setPublished({
    required String sermonId,
    required bool published,
  }) {
    return _repository.setPublished(sermonId: sermonId, published: published);
  }

  Future<void> setFeatured(String sermonId) {
    return _repository.setFeatured(sermonId);
  }
}
