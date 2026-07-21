import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/auth/app_roles.dart';
import '../../features/web_admin/screens/web_admin_action_center.dart';
import '../../features/web_admin/screens/web_admin_audit_log.dart';
import '../../features/web_admin/screens/web_admin_operations_reports.dart';
import '../../features/web_admin/screens/web_admin_staff_access.dart';
import 'admin_events_screen.dart';
import 'admin_giving_screen.dart';
import 'admin_member_directory_screen.dart';
import 'admin_prayer_requests_screen.dart';

class AdminActionCenterScreen extends StatelessWidget {
  const AdminActionCenterScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Action Center',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: WebAdminActionCenter(
        churchId: churchId,
        onOpenMembers: () =>
            _open(context, AdminMemberDirectoryScreen(churchId: churchId)),
        onOpenEvents: () =>
            _open(context, AdminEventsScreen(churchId: churchId)),
        onOpenPrayer: () =>
            _open(context, AdminPrayerRequestsScreen(churchId: churchId)),
        onOpenGiving: () =>
            _open(context, AdminGivingScreen(churchId: churchId)),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class AdminOperationsReportsScreen extends StatelessWidget {
  const AdminOperationsReportsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Operations Reports',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: WebAdminOperationsReports(churchId: churchId),
    );
  }
}

class AdminStaffAccessScreen extends StatelessWidget {
  const AdminStaffAccessScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    return _AdminIdentityLoader(
      churchId: churchId,
      title: 'Staff Access',
      builder: (userId, role) {
        return WebAdminStaffAccessScreen(
          churchId: churchId,
          currentUserId: userId,
          currentUserRole: role,
        );
      },
    );
  }
}

class AdminActivityLogScreen extends StatelessWidget {
  const AdminActivityLogScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    return _AdminIdentityLoader(
      churchId: churchId,
      title: 'Administrative Activity',
      builder: (_, role) {
        return WebAdminAuditLogScreen(
          churchId: churchId,
          currentUserRole: role,
        );
      },
    );
  }
}

class _AdminIdentityLoader extends StatelessWidget {
  const _AdminIdentityLoader({
    required this.churchId,
    required this.title,
    required this.builder,
  });

  final String churchId;
  final String title;
  final Widget Function(String userId, String role) builder;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid.trim() ?? '';

    if (userId.isEmpty) {
      return _AdminIdentityUnavailable(
        title: title,
        message: 'No signed-in administrator account was found.',
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('churches')
          .doc(churchId)
          .collection('members')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AdminIdentityUnavailable(
            title: title,
            message:
                'Unable to verify administrator access: '
                '${snapshot.error}',
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!.data()?['role']?.toString().trim() ?? '';

        if (role != AppRoles.admin) {
          return _AdminIdentityUnavailable(
            title: title,
            message: 'Only an administrator can use this protected tool.',
          );
        }

        return builder(userId, role);
      },
    );
  }
}

class _AdminIdentityUnavailable extends StatelessWidget {
  const _AdminIdentityUnavailable({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
