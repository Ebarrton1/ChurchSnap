import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../announcements/repositories/announcement_repository.dart';
import '../services/admin_announcement_service.dart';

final adminAnnouncementServiceProvider = Provider<AdminAnnouncementService>((
  ref,
) {
  return AdminAnnouncementService(AnnouncementRepository());
});
