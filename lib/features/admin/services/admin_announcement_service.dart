import '../../../models/announcement.dart';
import '../../announcements/repositories/announcement_repository.dart';

class AdminAnnouncementService {
  AdminAnnouncementService(this._repository);

  final AnnouncementRepository _repository;

  Future<void> publishAnnouncement({
    required String title,
    required String message,
    String tag = 'General',
  }) {
    return _repository.addAnnouncement(
      Announcement(title: title, message: message, tag: tag),
    );
  }
}
