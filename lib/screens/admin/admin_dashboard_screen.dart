import 'package:flutter/material.dart';
import 'package:churchsnap/features/members/providers/member_baptism_providers.dart';

import '../../core/widgets/churchsnap_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_attendance_screen.dart';
import 'admin_calendar_screen.dart';
import 'admin_events_screen.dart';
import 'admin_home_appearance_screen.dart';
import 'admin_pastor_picture_screen.dart';
import 'admin_platform_tools_screen.dart';
import 'admin_church_connection_screen.dart';
import 'admin_member_directory_screen.dart';
import 'admin_member_count_management_screen.dart';
import 'admin_member_demographics_screen.dart';
import 'admin_recent_baptisms_screen.dart';
import 'admin_upcoming_celebrations_screen.dart';

import 'admin_ministries_screen.dart';
import 'admin_media_screen.dart';
import '../../features/dashboard/providers/dashboard_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_notifications_screen.dart';
import 'admin_prayer_requests_screen.dart';
import 'admin_qr_scanner_screen.dart';
import 'admin_sermons_screen.dart';
import 'admin_small_groups_screen.dart';
import 'admin_volunteer_schedule_screen.dart';

import 'admin_giving_screen.dart';
import 'admin_giving_currency_screen.dart';
import 'admin_giving_confirmations_screen.dart';

import 'admin_worship_settings_screen.dart';

import 'admin_resources_screen.dart';

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
              title: 'Recent Baptisms',
              icon: Icons.water_drop_rounded,
              value: ref.watch(recentBaptismCountProvider(churchId)).value ?? 0,
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

        _AdminNavCard(
          icon: Icons.manage_accounts_rounded,
          title: 'Members Count',
          subtitle: 'Exclude only members removed from the directory',
          screen: AdminMemberCountManagementScreen(churchId: churchId),
        ),
        const SectionTitle(title: 'Operations & Governance'),
        _AdminNavCard(
          icon: Icons.task_alt_rounded,
          title: 'Action Center',
          subtitle: 'Review prayer, event, member, and giving follow-up',
          screen: AdminActionCenterScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.analytics_rounded,
          title: 'Operations Reports',
          subtitle: 'View live membership, giving, prayer, and event reports',
          screen: AdminOperationsReportsScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.history_rounded,
          title: 'Administrative Activity',
          subtitle: 'Review protected administrative audit records',
          screen: AdminActivityLogScreen(churchId: churchId),
        ),
        const SectionTitle(title: 'Content'),
        _AdminNavCard(
          icon: Icons.library_books_rounded,
          title: 'Resource Library',
          subtitle: 'Upload books, lessons, guides, and links',
          screen: AdminResourcesScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.image_rounded,
          title: 'Home Welcome Picture',
          subtitle: 'Customize the home welcome background',
          screen: AdminHomeAppearanceScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.person_pin_rounded,
          title: 'Pastor Picture',
          subtitle: 'Customize the Today\u2019s Service pastor photo',
          screen: AdminPastorPictureScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.hub_rounded,
          title: 'Church Connection',
          subtitle: 'Publish visitor search, code, and QR settings',
          screen: AdminChurchConnectionScreen(churchId: churchId),
        ),
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
        _AdminNavCard(
          icon: Icons.church_rounded,
          title: 'Worship Settings',
          subtitle: 'Customize Home worship services and times',
          screen: AdminWorshipSettingsScreen(churchId: churchId),
        ),
        const SectionTitle(title: 'People'),
        _AdminNavCard(
          icon: Icons.people_rounded,
          title: 'Church Member Directory',
          subtitle: 'Search, remove, and restore directory members',
          screen: AdminMemberDirectoryScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.pie_chart_rounded,
          title: 'Member Demographics',
          subtitle: 'View aggregate age, gender, and marital-status totals',
          screen: AdminMemberDemographicsScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.celebration_rounded,
          title: 'Upcoming Celebrations',
          subtitle: 'Birthdays and anniversaries within the next 7 days',
          screen: AdminUpcomingCelebrationsScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.water_drop_rounded,
          title: 'Recent Baptisms',
          subtitle: 'Record and review members baptized in the last 30 days',
          screen: AdminRecentBaptismsScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Staff Access',
          subtitle: 'Manage roles with protected audit logging',
          screen: AdminStaffAccessScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.how_to_reg_rounded,
          title: 'Attendance',
          subtitle: 'Review and clear event check-ins',
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
        _AdminNavCard(
          icon: Icons.volunteer_activism_rounded,
          title: 'Giving',
          subtitle: 'Manage funds and verified contributions',
          screen: AdminGivingScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.currency_exchange_rounded,
          title: 'Giving Currencies',
          subtitle: 'Set the default and currencies givers may select',
          screen: AdminGivingCurrencyScreen(churchId: churchId),
        ),
        _AdminNavCard(
          icon: Icons.fact_check_rounded,
          title: 'Gift Confirmations',
          subtitle: 'Confirm the amount and currency actually received',
          screen: AdminGivingConfirmationsScreen(churchId: churchId),
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
        _AdminNavCard(
          icon: Icons.calendar_month_rounded,
          title: 'Calendar',
          subtitle: 'View church events by month',
          screen: AdminCalendarScreen(churchId: churchId),
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
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
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
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }
}
