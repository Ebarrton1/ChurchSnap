import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../groups/groups_and_ministries_screen.dart';
import '../prayer/my_prayer_requests_screen.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../volunteers/my_schedule_screen.dart';
import 'attendance_history_screen.dart';
import 'giving_history_screen.dart';
import 'my_qr_code_screen.dart';
import 'edit_my_member_profile_screen.dart';

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

    if (member.role == 'visitor') {
      return _buildVisitorProfile(
        authController: authController,
        displayName: displayName,
        initial: initial,
      );
    }

    return ChurchSnapScreen(
      title: 'My Profile',
      subtitle: 'Your ChurchSnap member account',
      children: [
        AppCard(
          child: Column(
            children: [
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('churches')
                    .doc(churchId)
                    .collection('members')
                    .doc(member.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  final photoUrl =
                      (snapshot.data?.data()?['photoUrl'] as String? ?? '')
                          .trim();

                  return _MemberProfilePhoto(
                    photoUrl: photoUrl,
                    initial: initial,
                    onEdit: () async {
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (_) => EditMyMemberProfileScreen(
                            churchId: churchId,
                            userId: member.id,
                            accountEmail: member.email,
                          ),
                        ),
                      );

                      if (updated == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Your profile picture and member details were saved.',
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
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
        AppCard(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.manage_accounts_rounded),
            ),
            title: const Text(
              'Complete or Edit My Details',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Update your directory profile and protected personal details',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => EditMyMemberProfileScreen(
                    churchId: churchId,
                    userId: member.id,
                    accountEmail: member.email,
                  ),
                ),
              );

              if (updated == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Your profile was saved and the member directory updated.',
                    ),
                  ),
                );
              }
            },
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
        AppCard(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.groups_rounded)),
            title: const Text(
              'Groups & Ministries',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Browse opportunities, request to join, and view your status',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GroupsAndMinistriesScreen(
                    churchId: churchId,
                    userId: member.id,
                    memberName: displayName,
                  ),
                ),
              );
            },
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.favorite_rounded)),
            title: const Text(
              'My Prayer Requests',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Review public and private requests you have submitted',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MyPrayerRequestsScreen(
                    churchId: churchId,
                    userId: member.id,
                  ),
                ),
              );
            },
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

  static Widget _buildVisitorProfile({
    required AuthController authController,
    required String displayName,
    required String initial,
  }) {
    return ChurchSnapScreen(
      title: 'Visitor Profile',
      subtitle: 'Public church access',
      children: [
        AppCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 46,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Chip(
                avatar: Icon(Icons.visibility_rounded, size: 18),
                label: Text('Visitor'),
              ),
            ],
          ),
        ),
        const SectionTitle(title: 'Visitor Access'),
        const AppCard(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.church_rounded)),
            title: Text(
              'Connected to this church',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'You can view published sermons, media, events, prayer updates, '
              'announcements, and giving information. Member records, RSVP, '
              'check-in, schedules, giving history, and admin tools stay private.',
            ),
          ),
        ),
        const SectionTitle(title: 'Account'),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text(
              'Leave visitor mode',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Sign out and choose another church or use a member account.',
            ),
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

class _MemberProfilePhoto extends StatelessWidget {
  const _MemberProfilePhoto({
    required this.photoUrl,
    required this.initial,
    required this.onEdit,
  });

  final String photoUrl;
  final String initial;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final normalizedPhotoUrl = photoUrl.trim();
    final hasPhoto = normalizedPhotoUrl.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    Widget fallbackAvatar() {
      return ColoredBox(
        color: colorScheme.primaryContainer,
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Semantics(
          button: true,
          label: hasPhoto ? 'Change profile picture' : 'Add profile picture',
          child: InkWell(
            onTap: onEdit,
            customBorder: const CircleBorder(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).shadowColor.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.network(
                            normalizedPhotoUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.fallback,
                            errorBuilder: (_, _, _) => fallbackAvatar(),
                          )
                        : fallbackAvatar(),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 4,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    child: const Icon(Icons.camera_alt_rounded, size: 21),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.add_a_photo_rounded),
          label: Text(hasPhoto ? 'Change Picture' : 'Add Picture'),
        ),
      ],
    );
  }
}
