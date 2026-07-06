import '../../models/announcement.dart';
import '../../models/church_event.dart';
import '../../models/ministry.dart';
import '../../models/prayer_request.dart';
import '../../models/sermon.dart';
import '../demo/demo_data.dart';

abstract class ChurchRepository {
  Future<List<Sermon>> getSermons();
  Future<List<ChurchEvent>> getEvents();
  Future<List<PrayerRequest>> getPrayerRequests();
  Future<List<Announcement>> getAnnouncements();
  Future<List<Ministry>> getMinistries();
}

class MockChurchRepository implements ChurchRepository {
  @override
  Future<List<Sermon>> getSermons() async => DemoData.sermons;

  @override
  Future<List<ChurchEvent>> getEvents() async => DemoData.events;

  @override
  Future<List<PrayerRequest>> getPrayerRequests() async => DemoData.prayers;

  @override
  Future<List<Announcement>> getAnnouncements() async => DemoData.announcements;

  @override
  Future<List<Ministry>> getMinistries() async => DemoData.ministries;
}
