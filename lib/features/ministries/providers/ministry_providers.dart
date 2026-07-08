import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/ministry_repository.dart';
import '../services/ministry_service.dart';

final ministryRepositoryProvider = Provider<MinistryRepository>(
  (ref) => MinistryRepository(),
);

final ministryServiceProvider = Provider<MinistryService>(
  (ref) => MinistryService(ref.read(ministryRepositoryProvider)),
);
