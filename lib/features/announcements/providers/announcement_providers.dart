import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../models/announcement.dart';
import '../repositories/announcement_repository.dart';

final announcementsProvider = StreamProvider<List<Announcement>>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.watchPublishedAnnouncements();
});

final announcementRepositoryByChurchProvider =
    Provider.family<AnnouncementRepository, String>((ref, churchId) {
      return AnnouncementRepository(churchId: churchId);
    });

final announcementsByChurchProvider =
    StreamProvider.family<List<Announcement>, String>((ref, churchId) {
      final repository = ref.watch(
        announcementRepositoryByChurchProvider(churchId),
      );

      return repository.watchPublishedAnnouncements();
    });
