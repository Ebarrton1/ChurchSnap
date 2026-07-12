import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/volunteer_repository.dart';
import '../services/volunteer_service.dart';

final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  return VolunteerRepository();
});

final volunteerServiceProvider = Provider<VolunteerService>((ref) {
  return VolunteerService(ref.read(volunteerRepositoryProvider));
});

final volunteerRepositoryByChurchProvider =
    Provider.family<VolunteerRepository, String>((ref, churchId) {
      return VolunteerRepository(churchId: churchId);
    });

final volunteerServiceByChurchProvider =
    Provider.family<VolunteerService, String>((ref, churchId) {
      return VolunteerService(
        ref.read(volunteerRepositoryByChurchProvider(churchId)),
      );
    });
