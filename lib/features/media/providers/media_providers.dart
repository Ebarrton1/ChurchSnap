import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/media_repository.dart';
import '../services/media_service.dart';

final mediaRepositoryProvider = Provider<MediaRepository>(
  (ref) => MediaRepository(),
);

final mediaServiceProvider = Provider<MediaService>(
  (ref) => MediaService(ref.read(mediaRepositoryProvider)),
);
