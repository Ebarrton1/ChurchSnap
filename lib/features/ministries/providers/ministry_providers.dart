import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/ministry_repository.dart';
import '../services/ministry_service.dart';

final ministryRepositoryProvider = Provider<MinistryRepository>(
  (ref) => MinistryRepository(),
);

final ministryServiceProvider = Provider<MinistryService>(
  (ref) => MinistryService(ref.read(ministryRepositoryProvider)),
);

final ministryRepositoryByChurchProvider =
    Provider.family<MinistryRepository, String>((ref, churchId) {
      return MinistryRepository(churchId: churchId);
    });

final ministryServiceByChurchProvider =
    Provider.family<MinistryService, String>((ref, churchId) {
      return MinistryService(
        ref.read(ministryRepositoryByChurchProvider(churchId)),
      );
    });
