import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/sermon.dart';
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
