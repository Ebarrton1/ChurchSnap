import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_events_screen.dart';
import 'admin_attendance_screen.dart';
import 'admin_members_screen.dart';
import 'admin_ministries_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'Admin Dashboard',
      subtitle: 'Manage ChurchSnap content.',
      children: [
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.campaign_rounded),
            title: const Text('Announcements'),
            subtitle: const Text('Publish church announcements'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminAnnouncementsScreen(),
                ),
              );
            },
          ),
        ),

        AppCard(
          child: ListTile(
            leading: const Icon(Icons.event_rounded),
            title: const Text('Events'),
            subtitle: const Text('Manage church events'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminEventsScreen()),
              );
            },
          ),
        ),

        AppCard(
          child: ListTile(
            leading: const Icon(Icons.how_to_reg_rounded),
            title: const Text('Attendance'),
            subtitle: const Text('View event check-ins'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminAttendanceScreen(),
                ),
              );
            },
          ),
        ),

        AppCard(
          child: ListTile(
            leading: const Icon(Icons.play_circle_fill_rounded),
            title: const Text('Sermons'),
            subtitle: const Text('Coming soon'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),

        AppCard(
          child: ListTile(
            leading: const Icon(Icons.favorite_rounded),
            title: const Text('Prayer Requests'),
            subtitle: const Text('Coming soon'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),

        AppCard(
          child: ListTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('Members'),
            subtitle: const Text('Manage church members'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminMembersScreen()),
              );
            },
          ),
        ),

        AppCard(
          child: ListTile(
            leading: const Icon(Icons.groups_rounded),
            title: const Text('Ministries'),
            subtitle: const Text('Manage ministries and volunteer teams'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminMinistriesScreen(),
                ),
              );
            },
          ),
        ),

        AppCard(
          child: ListTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('Members'),
            subtitle: const Text('Coming soon'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      ],
    );
  }
}
