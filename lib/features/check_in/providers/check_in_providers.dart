import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/check_in_repository.dart';
import '../services/check_in_service.dart';

final checkInRepositoryProvider = Provider<CheckInRepository>(
  (ref) => CheckInRepository(),
);

final checkInServiceProvider = Provider<CheckInService>(
  (ref) => CheckInService(ref.read(checkInRepositoryProvider)),
);

final checkInRepositoryByChurchProvider =
    Provider.family<CheckInRepository, String>((ref, churchId) {
      return CheckInRepository(churchId: churchId);
    });

final checkInServiceByChurchProvider = Provider.family<CheckInService, String>((
  ref,
  churchId,
) {
  return CheckInService(ref.read(checkInRepositoryByChurchProvider(churchId)));
});
