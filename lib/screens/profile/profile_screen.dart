import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../volunteers/my_schedule_screen.dart';
import 'attendance_history_screen.dart';
import 'giving_history_screen.dart';
import 'my_qr_code_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final member = authController.currentUser;

    if (member == null) {
      return ChurchSnapScreen(
        title: 'Profile',
        subtitle: 'Your ChurchSnap account',
        children: const [
          AppCard(
            child: ListTile(
              leading: Icon(Icons.person_outline_rounded),
              title: Text('No member profile available'),
              subtitle: Text('Sign in to view your profile.'),
            ),
          ),
        ],
      );
    }

    final displayName = member.displayName.trim().isEmpty
        ? 'ChurchSnap Member'
        : member.displayName.trim();

    final initial = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

    final rawChurchId = member.churchId.trim();

    final churchId = rawChurchId.isEmpty ? 'demo-church' : rawChurchId;

    return ChurchSnapScreen(
      title: 'My Profile',
      subtitle: 'Your ChurchSnap member account',
      children: [
        AppCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 52,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(member.email, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              Chip(
                avatar: const Icon(Icons.verified_user_rounded, size: 18),
                label: Text(_formatRole(member.role)),
              ),
            ],
          ),
        ),
        const SectionTitle(title: 'Member Details'),
        AppCard(
          child: Column(
            children: [
              _ProfileDetailTile(
                icon: Icons.badge_rounded,
                label: 'Member ID',
                value: member.id,
              ),
              const Divider(),
              _ProfileDetailTile(
                icon: Icons.email_rounded,
                label: 'Email',
                value: member.email,
              ),
              const Divider(),
              _ProfileDetailTile(
                icon: Icons.security_rounded,
                label: 'Role',
                value: _formatRole(member.role),
              ),
            ],
          ),
        ),
        const SectionTitle(title: 'Quick Actions'),
        AppCard(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.qr_code_rounded)),
            title: const Text(
              'My QR Code',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Show your personal code when checking in'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyQrCodeScreen(
                    memberId: member.id,
                    memberName: displayName,
                  ),
                ),
              );
            },
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.history_rounded)),
            title: const Text(
              'Attendance History',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('View your previous event check-ins'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceHistoryScreen(
                    memberId: member.id,
                    churchId: churchId,
                  ),
                ),
              );
            },
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.volunteer_activism_rounded),
            ),
            title: const Text(
              'My Schedule',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('View your ministry volunteer assignments'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MyScheduleScreen(authController: authController),
                ),
              );
            },
          ),
        ),
        const AppCard(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.favorite_rounded)),
            title: Text(
              'My Prayer Requests',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text('Review prayer requests you have submitted'),
            trailing: Chip(label: Text('Coming soon')),
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.receipt_long_rounded),
            ),
            title: const Text(
              'Giving History',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Review verified contributions'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GivingHistoryScreen(
                    churchId: churchId,
                    memberId: member.id,
                  ),
                ),
              );
            },
          ),
        ),
        const SectionTitle(title: 'Account'),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Sign out of your ChurchSnap account'),
            onTap: () async {
              await authController.signOut();
            },
          ),
        ),
      ],
    );
  }

  static String _formatRole(String role) {
    switch (role) {
      case 'ministryLeader':
        return 'Ministry Leader';
      case 'groupLeader':
        return 'Group Leader';
      case 'admin':
        return 'Administrator';
      case 'pastor':
        return 'Pastor';
      case 'volunteer':
        return 'Volunteer';
      case 'visitor':
        return 'Visitor';
      default:
        return 'Member';
    }
  }
}

class _ProfileDetailTile extends StatelessWidget {
  const _ProfileDetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
