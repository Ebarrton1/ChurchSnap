import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final memberCountProvider = StreamProvider<int>((ref) {
  return ref.read(dashboardRepositoryProvider).watchMemberCount();
});

final eventCountProvider = StreamProvider<int>((ref) {
  return ref.read(dashboardRepositoryProvider).watchEventCount();
});

final smallGroupCountProvider = StreamProvider<int>((ref) {
  return ref.read(dashboardRepositoryProvider).watchSmallGroupCount();
});

final ministryCountProvider = StreamProvider<int>((ref) {
  return ref.read(dashboardRepositoryProvider).watchMinistryCount();
});

final mediaCountProvider = StreamProvider<int>((ref) {
  return ref.read(dashboardRepositoryProvider).watchMediaCount();
});

final checkInCountProvider = StreamProvider<int>((ref) {
  return ref.read(dashboardRepositoryProvider).watchCheckInCount();
});

final dashboardRepositoryByChurchProvider =
    Provider.family<DashboardRepository, String>((ref, churchId) {
      return DashboardRepository(churchId: churchId);
    });

final memberCountByChurchProvider = StreamProvider.family<int, String>((
  ref,
  churchId,
) {
  return ref
      .read(dashboardRepositoryByChurchProvider(churchId))
      .watchMemberCount();
});

final eventCountByChurchProvider = StreamProvider.family<int, String>((
  ref,
  churchId,
) {
  return ref
      .read(dashboardRepositoryByChurchProvider(churchId))
      .watchEventCount();
});

final smallGroupCountByChurchProvider = StreamProvider.family<int, String>((
  ref,
  churchId,
) {
  return ref
      .read(dashboardRepositoryByChurchProvider(churchId))
      .watchSmallGroupCount();
});

final ministryCountByChurchProvider = StreamProvider.family<int, String>((
  ref,
  churchId,
) {
  return ref
      .read(dashboardRepositoryByChurchProvider(churchId))
      .watchMinistryCount();
});

final mediaCountByChurchProvider = StreamProvider.family<int, String>((
  ref,
  churchId,
) {
  return ref
      .read(dashboardRepositoryByChurchProvider(churchId))
      .watchMediaCount();
});

final checkInCountByChurchProvider = StreamProvider.family<int, String>((
  ref,
  churchId,
) {
  return ref
      .read(dashboardRepositoryByChurchProvider(churchId))
      .watchCheckInCount();
});
