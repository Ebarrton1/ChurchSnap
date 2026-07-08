import '../models/media_item.dart';
import '../repositories/media_repository.dart';

class MediaService {
  MediaService(this._repository);

  final MediaRepository _repository;

  Stream<List<MediaItem>> watchMedia() {
    return _repository.watchMedia();
  }

  Future<void> addMedia(MediaItem item) {
    return _repository.addMedia(item);
  }

  Future<void> updateMedia(MediaItem item) {
    return _repository.updateMedia(item);
  }

  Future<void> deleteMedia(String id) {
    return _repository.deleteMedia(id);
  }
}
