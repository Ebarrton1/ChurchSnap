import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/prayer_request.dart';
import '../repositories/prayer_repository.dart';
import '../services/prayer_service.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository();
});

final prayerServiceProvider = Provider<PrayerService>((ref) {
  return PrayerService(ref.watch(prayerRepositoryProvider));
});

final prayerRequestsProvider = StreamProvider<List<PrayerRequest>>((ref) {
  return ref.watch(prayerServiceProvider).watchPublishedPrayerRequests();
});

final prayerRepositoryByChurchProvider =
    Provider.family<PrayerRepository, String>((ref, churchId) {
      return PrayerRepository(churchId: churchId);
    });

final prayerServiceByChurchProvider = Provider.family<PrayerService, String>((
  ref,
  churchId,
) {
  return PrayerService(ref.watch(prayerRepositoryByChurchProvider(churchId)));
});

final prayerRequestsByChurchProvider =
    StreamProvider.family<List<PrayerRequest>, String>((ref, churchId) {
      return ref
          .watch(prayerServiceByChurchProvider(churchId))
          .watchPublishedPrayerRequests();
    });
