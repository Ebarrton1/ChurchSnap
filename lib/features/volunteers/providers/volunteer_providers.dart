import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/volunteer_repository.dart';
import '../services/volunteer_service.dart';

final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  return VolunteerRepository();
});

final volunteerServiceProvider = Provider<VolunteerService>((ref) {
  return VolunteerService(ref.read(volunteerRepositoryProvider));
});
