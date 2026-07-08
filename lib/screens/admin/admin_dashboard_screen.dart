import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_attendance_screen.dart';
import 'admin_events_screen.dart';
import 'admin_members_screen.dart';
import 'admin_ministries_screen.dart';
import 'admin_media_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'Admin Dashboard',
      subtitle: 'Manage ChurchSnap content and people.',
      children: [
        const SectionTitle(title: 'Overview'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.65,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: const [
            _StatCard(label: 'Members', value: 'Live'),
            _StatCard(label: 'Attendance', value: 'Live'),
            _StatCard(label: 'Events', value: 'Live'),
            _StatCard(label: 'Ministries', value: 'Live'),
          ],
        ),

        const SectionTitle(title: 'Content'),
        _AdminNavCard(
          icon: Icons.campaign_rounded,
          title: 'Announcements',
          subtitle: 'Publish church announcements',
          screen: AdminAnnouncementsScreen(),
        ),
        _AdminNavCard(
          icon: Icons.event_rounded,
          title: 'Events',
          subtitle: 'Manage church events',
          screen: AdminEventsScreen(),
        ),
        const _ComingSoonCard(
          icon: Icons.play_circle_fill_rounded,
          title: 'Sermons',
        ),

        _AdminNavCard(
          icon: Icons.video_library_rounded,
          title: 'Media',
          subtitle: 'Videos, podcasts, photos and documents',
          screen: const AdminMediaScreen(),
        ),
        const SectionTitle(title: 'People'),
        _AdminNavCard(
          icon: Icons.people_rounded,
          title: 'Members',
          subtitle: 'Manage church members',
          screen: AdminMembersScreen(),
        ),
        _AdminNavCard(
          icon: Icons.how_to_reg_rounded,
          title: 'Attendance',
          subtitle: 'View event check-ins',
          screen: AdminAttendanceScreen(),
        ),
        _AdminNavCard(
          icon: Icons.groups_rounded,
          title: 'Ministries',
          subtitle: 'Manage ministries and volunteer teams',
          screen: AdminMinistriesScreen(),
        ),
        const _ComingSoonCard(
          icon: Icons.volunteer_activism_rounded,
          title: 'Volunteers',
        ),

        const SectionTitle(title: 'Care'),
        const _ComingSoonCard(
          icon: Icons.favorite_rounded,
          title: 'Prayer Requests',
        ),

        const SectionTitle(title: 'Finance'),
        const _ComingSoonCard(
          icon: Icons.volunteer_activism_rounded,
          title: 'Giving',
        ),

        const SectionTitle(title: 'Operations'),
        const _ComingSoonCard(
          icon: Icons.notifications_active_rounded,
          title: 'Notifications',
        ),
        const _ComingSoonCard(
          icon: Icons.qr_code_scanner_rounded,
          title: 'QR Check-In',
        ),
        const _ComingSoonCard(
          icon: Icons.calendar_month_rounded,
          title: 'Calendar',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _AdminNavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  const _AdminNavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ComingSoonCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: const Text('Coming soon'),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
