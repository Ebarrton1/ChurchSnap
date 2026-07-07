import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../models/sermon.dart';
import '../services/sermon_service.dart';

final sermonServiceProvider = Provider<SermonService>((ref) {
  return SermonService(ref.watch(sermonRepositoryProvider));
});

final sermonsProvider = StreamProvider<List<Sermon>>((ref) {
  return ref.watch(sermonServiceProvider).watchPublishedSermons();
});
