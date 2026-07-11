import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/sermon.dart';
import '../repositories/sermon_bookmark_repository.dart';
import '../repositories/sermon_download_repository.dart';
import '../repositories/sermon_repository.dart';
import '../services/sermon_service.dart';

final sermonRepositoryProvider = Provider<SermonRepository>((ref) {
  return SermonRepository();
});

final sermonServiceProvider = Provider<SermonService>((ref) {
  return SermonService(ref.watch(sermonRepositoryProvider));
});

final sermonsProvider = StreamProvider<List<Sermon>>((ref) {
  return ref.watch(sermonServiceProvider).watchPublishedSermons();
});

final adminSermonsProvider = StreamProvider<List<Sermon>>((ref) {
  return ref.watch(sermonServiceProvider).watchAllSermons();
});

final sermonRepositoryByChurchProvider =
    Provider.family<SermonRepository, String>((ref, churchId) {
      return SermonRepository(churchId: churchId);
    });

final sermonServiceByChurchProvider = Provider.family<SermonService, String>((
  ref,
  churchId,
) {
  return SermonService(ref.watch(sermonRepositoryByChurchProvider(churchId)));
});

final sermonsByChurchProvider = StreamProvider.family<List<Sermon>, String>((
  ref,
  churchId,
) {
  return ref
      .watch(sermonServiceByChurchProvider(churchId))
      .watchPublishedSermons();
});

final sermonBookmarkRepositoryProvider = Provider<SermonBookmarkRepository>((
  ref,
) {
  return SermonBookmarkRepository();
});

final sermonBookmarkIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(sermonBookmarkRepositoryProvider).watchBookmarkedSermonIds();
});

final sermonBookmarkRepositoryByChurchProvider =
    Provider.family<SermonBookmarkRepository, String>((ref, churchId) {
      return SermonBookmarkRepository(churchId: churchId);
    });

final sermonBookmarkIdsByChurchProvider =
    StreamProvider.family<Set<String>, String>((ref, churchId) {
      return ref
          .watch(sermonBookmarkRepositoryByChurchProvider(churchId))
          .watchBookmarkedSermonIds();
    });

final sermonDownloadRepositoryProvider = Provider<SermonDownloadRepository>((
  ref,
) {
  return SermonDownloadRepository();
});
