import 'package:flutter/material.dart';

import '../../models/announcement.dart';
import '../../models/church_event.dart';
import '../../models/ministry.dart';
import '../../models/prayer_request.dart';
import '../../models/sermon.dart';

class DemoData {
  static const sermons = [
    Sermon(
      title: 'Faith That Moves Mountains',
      speaker: 'Pastor John',
      scripture: 'Matthew 17:20',
      duration: '42 min',
    ),
    Sermon(
      title: 'Walking by Faith',
      speaker: 'Pastor John',
      scripture: '2 Corinthians 5:7',
      duration: '38 min',
    ),
    Sermon(
      title: 'Grace for the Journey',
      speaker: 'Guest Speaker',
      scripture: 'Ephesians 2:8',
      duration: '35 min',
    ),
  ];

  static const events = [
    ChurchEvent(
      title: 'Sabbath Worship',
      when: 'Saturday • 11:00 AM',
      location: 'Main Sanctuary',
      icon: Icons.wb_twilight_rounded,
    ),
    ChurchEvent(
      title: 'Sunday Worship',
      when: 'Sunday • 10:00 AM',
      location: 'Main Sanctuary',
      icon: Icons.church_rounded,
    ),
    ChurchEvent(
      title: 'Community Outreach',
      when: 'Saturday • 9:00 AM',
      location: 'Church Parking Lot',
      icon: Icons.handshake_rounded,
    ),
  ];

  static const prayers = [
    PrayerRequest(
      name: 'Church Family',
      request: 'Pray for healing, strength, and unity this week.',
    ),
  ];

  static const announcements = [
    Announcement(
      title: 'Volunteer Team Meeting',
      message: 'Wednesday at 7:00 PM in the fellowship hall.',
      tag: 'Ministry',
    ),
    Announcement(
      title: 'Coffee Fellowship',
      message: 'Join us after worship for coffee, snacks, and connection.',
      tag: 'Weekend',
    ),
  ];

  static const ministries = [
    Ministry(
      title: 'Life Groups',
      description: 'Midweek groups for prayer, Bible study, and connection.',
      schedule: 'Wednesdays • 7:00 PM',
    ),
    Ministry(
      title: 'Worship Team',
      description:
          'Serve through music, media, sound, and Sunday/Sabbath worship support.',
      schedule: 'Thursdays • 6:30 PM',
      icon: Icons.music_note_rounded,
    ),
    Ministry(
      title: 'Outreach Team',
      description: 'Help with community meals, visits, and local missions.',
      schedule: 'Saturdays • 9:00 AM',
      icon: Icons.volunteer_activism_rounded,
    ),
  ];
}
