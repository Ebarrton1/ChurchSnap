import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_attendance_screen.dart';
import 'admin_events_screen.dart';
import 'admin_members_screen.dart';
import 'admin_ministries_screen.dart';
import 'admin_media_screen.dart';
import '../../features/dashboard/providers/dashboard_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_role_management_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_prayer_requests_screen.dart';
import 'admin_qr_scanner_screen.dart';
import 'admin_sermons_screen.dart';
import 'admin_small_groups_screen.dart';
import 'admin_volunteer_schedule_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChurchSnapScreen(
      title: 'Admin Dashboard',
      subtitle: 'Manage ChurchSnap content and people.',
      children: [
        const SectionTitle(title: 'Church Overview'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _DashboardStatCard(
              title: 'Members',
              icon: Icons.people_rounded,
              value:
                  ref.watch(memberCountByChurchProvider(churchId)).value ?? 0,
            ),
            _DashboardStatCard(
              title: 'Events',
              icon: Icons.event_rounded,
              value: ref.watch(eventCountByChurchProvider(churchId)).value ?? 0,
            ),
            _DashboardStatCard(
              title: 'Small Groups',
              icon: Icons.groups_rounded,
              value:
                  ref.watch(smallGroupCountByChurchProvider(churchId)).value ??
                  0,
            ),
            _DashboardStatCard(
              title: 'Ministries',
              icon: Icons.church_rounded,
              value:
                  ref.watch(ministryCountByChurchProvider(churchId)).value ?? 0,
            ),
            _DashboardStatCard(
              title: 'Media',
              icon: Icons.video_library_rounded,
              value: ref.watch(mediaCountByChurchProvider(churchId)).value ?? 0,
            ),
            _DashboardStatCard(
              title: 'Check-ins',
              icon: Icons.how_to_reg_rounded,
              value:
                  ref.watch(checkInCountByChurchProvider(churchId)).value ?? 0,
            ),
          ],
        ),

        const SectionTitle(title: 'Content'),
        _AdminNavCard(
          icon: Icons.campaign_rounded,
          title: 'Announcements',
          subtitle: 'Publish church announcements',
          screen: AdminAnnouncementsScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.event_rounded,
          title: 'Events',
          subtitle: 'Manage church events',
          screen: AdminEventsScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.play_circle_fill_rounded,
          title: 'Sermons',
          subtitle: 'Publish and manage church sermons',
          screen: AdminSermonsScreen(churchId: churchId),
        ),

        _AdminNavCard(
          icon: Icons.video_library_rounded,
          title: 'Media',
          subtitle: 'Videos, podcasts, photos and documents',
          screen: AdminMediaScreen(churchId: churchId),
        ),
        const SectionTitle(title: 'People'),
        _AdminNavCard(
          icon: Icons.people_rounded,
          title: 'Members',
          subtitle: 'Manage church members',
          screen: AdminMembersScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Roles & Permissions',
          subtitle: 'Manage user roles and access',
          screen: AdminRoleManagementScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.how_to_reg_rounded,
          title: 'Attendance',
          subtitle: 'View event check-ins',
          screen: AdminAttendanceScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.groups_rounded,
          title: 'Ministries',
          subtitle: 'Manage ministries and volunteer teams',
          screen: AdminMinistriesScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.group_work_rounded,
          title: 'Small Groups',
          subtitle: 'Manage church small groups',
          screen: AdminSmallGroupsScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.volunteer_activism_rounded,
          title: 'Volunteers',
          subtitle: 'Schedule ministry volunteers',
          screen: AdminVolunteerScheduleScreen(churchId: churchId),
        ),

        const SectionTitle(title: 'Care'),
        _AdminNavCard(
          icon: Icons.favorite_rounded,
          title: 'Prayer Requests',
          subtitle: 'Review public and private requests',
          screen: AdminPrayerRequestsScreen(churchId: churchId),
        ),

        const SectionTitle(title: 'Finance'),
        const _ComingSoonCard(
          icon: Icons.volunteer_activism_rounded,
          title: 'Giving',
        ),

        _AdminNavCard(
          icon: Icons.notifications_active_rounded,
          title: 'Notifications',
          subtitle: 'Create and manage church notifications',
          screen: AdminNotificationsScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.qr_code_scanner_rounded,
          title: 'QR Check-In',
          subtitle: 'Scan member QR codes and record attendance',
          screen: AdminQrScannerScreen(churchId: churchId),
        ),
        const _ComingSoonCard(
          icon: Icons.calendar_month_rounded,
          title: 'Calendar',
        ),
      ],
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int value;

  const _DashboardStatCard({
    required this.title,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: AppCard(
        child: Column(
          children: [
            Icon(icon, size: 34),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title),
          ],
        ),
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
