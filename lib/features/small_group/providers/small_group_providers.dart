import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/small_group_repository.dart';
import '../services/small_group_service.dart';

final smallGroupRepositoryProvider = Provider<SmallGroupRepository>((ref) {
  return SmallGroupRepository();
});

final smallGroupServiceProvider = Provider<SmallGroupService>((ref) {
  return SmallGroupService(ref.read(smallGroupRepositoryProvider));
});
