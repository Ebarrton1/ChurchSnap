import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/media_repository.dart';
import '../services/media_service.dart';
import '../services/media_storage_service.dart';

final mediaRepositoryProvider = Provider<MediaRepository>(
  (ref) => MediaRepository(),
);

final mediaServiceProvider = Provider<MediaService>(
  (ref) => MediaService(ref.read(mediaRepositoryProvider)),
);

final mediaRepositoryByChurchProvider =
    Provider.family<MediaRepository, String>((ref, churchId) {
      return MediaRepository(churchId: churchId);
    });

final mediaServiceByChurchProvider = Provider.family<MediaService, String>((
  ref,
  churchId,
) {
  return MediaService(ref.read(mediaRepositoryByChurchProvider(churchId)));
});

final mediaStorageServiceProvider = Provider<MediaStorageService>(
  (ref) => MediaStorageService(),
);
