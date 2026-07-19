import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/app_roles.dart';
import '../../../screens/admin/admin_member_directory_screen.dart';
import '../../auth/state/auth_controller.dart';
import '../models/web_admin_donation_amount.dart';
import '../models/web_admin_value_formatter.dart';
import '../widgets/web_admin_responsive_navigation.dart';
import 'web_admin_action_center.dart';
import 'web_admin_operations_reports.dart';
import 'web_admin_staff_access.dart';

class ChurchSnapWebAdminShell extends StatefulWidget {
  const ChurchSnapWebAdminShell({super.key, required this.authController});

  final AuthController authController;

  @override
  State<ChurchSnapWebAdminShell> createState() =>
      _ChurchSnapWebAdminShellState();
}

class _ChurchSnapWebAdminShellState extends State<ChurchSnapWebAdminShell> {
  int _selectedIndex = 0;

  String get _churchId {
    final value = widget.authController.currentUser?.churchId.trim() ?? '';
    return value.isEmpty ? 'demo-church' : value;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;

    if (!widget.authController.isAdmin || user == null) {
      return _WebAccessDenied(authController: widget.authController);
    }

    final pages = <Widget>[
      _WebOverviewPage(
        churchId: _churchId,
        onOpenMembers: () => _selectPage(1),
        onOpenEvents: () => _selectPage(2),
        onOpenPrayer: () => _selectPage(3),
        onOpenGiving: () => _selectPage(4),
      ),
      AdminMemberDirectoryScreen(churchId: _churchId),
      _WebEventsPage(churchId: _churchId),
      _WebPrayerPage(churchId: _churchId),
      _WebGivingPage(churchId: _churchId),
      WebAdminActionCenter(
        churchId: _churchId,
        onOpenMembers: () => _selectPage(1),
        onOpenEvents: () => _selectPage(2),
        onOpenPrayer: () => _selectPage(3),
        onOpenGiving: () => _selectPage(4),
      ),
      WebAdminOperationsReports(churchId: _churchId),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 980;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 24,
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.church_rounded),
                SizedBox(width: 10),
                Text(
                  'ChurchSnap Windows Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (user.role == AppRoles.admin)
                IconButton(
                  tooltip: 'Staff access',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WebAdminStaffAccessScreen(
                          churchId: _churchId,
                          currentUserId: user.id,
                          currentUserRole: user.role,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings_rounded),
                ),
              IconButton(
                tooltip: 'Sign out',
                onPressed: widget.authController.signOut,
                icon: const Icon(Icons.logout_rounded),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: Row(
            children: [
              if (useRail)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectPage,
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 18),
                    child: _WebBadge(),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: Text('Overview'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline_rounded),
                      selectedIcon: Icon(Icons.people_rounded),
                      label: Text('Members'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.event_outlined),
                      selectedIcon: Icon(Icons.event_rounded),
                      label: Text('Events'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.volunteer_activism_outlined),
                      selectedIcon: Icon(Icons.volunteer_activism_rounded),
                      label: Text('Prayer'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.payments_outlined),
                      selectedIcon: Icon(Icons.payments_rounded),
                      label: Text('Giving'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.task_alt_outlined),
                      selectedIcon: Icon(Icons.task_alt_rounded),
                      label: Text('Action Center'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics_rounded),
                      label: Text('Reports'),
                    ),
                  ],
                ),
              if (useRail) const VerticalDivider(width: 1),
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: pages),
              ),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : WebAdminResponsiveNavigation(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectPage,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: 'Overview',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline_rounded),
                      selectedIcon: Icon(Icons.people_rounded),
                      label: 'Members',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.event_outlined),
                      selectedIcon: Icon(Icons.event_rounded),
                      label: 'Events',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.volunteer_activism_outlined),
                      selectedIcon: Icon(Icons.volunteer_activism_rounded),
                      label: 'Prayer',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.payments_outlined),
                      selectedIcon: Icon(Icons.payments_rounded),
                      label: 'Giving',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.task_alt_outlined),
                      selectedIcon: Icon(Icons.task_alt_rounded),
                      label: 'Action Center',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics_rounded),
                      label: 'Reports',
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _selectPage(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }
}

class _WebBadge extends StatelessWidget {
  const _WebBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text('WEB', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _WebAccessDenied extends StatelessWidget {
  const _WebAccessDenied({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.admin_panel_settings_outlined, size: 64),
                  const SizedBox(height: 18),
                  const Text(
                    'Authorized leaders only',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${user?.displayName ?? 'This account'} does not have '
                    'permission to use the ChurchSnap Windows administration '
                    'dashboard.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: authController.signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WebOverviewPage extends StatelessWidget {
  const _WebOverviewPage({
    required this.churchId,
    required this.onOpenMembers,
    required this.onOpenEvents,
    required this.onOpenPrayer,
    required this.onOpenGiving,
  });

  final String churchId;
  final VoidCallback onOpenMembers;
  final VoidCallback onOpenEvents;
  final VoidCallback onOpenPrayer;
  final VoidCallback onOpenGiving;

  @override
  Widget build(BuildContext context) {
    final church = FirebaseFirestore.instance
        .collection('churches')
        .doc(churchId);

    return _WebPageFrame(
      title: 'Overview',
      subtitle: 'A live administrative snapshot of ChurchSnap.',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _LiveCountCard(
                label: 'Members',
                icon: Icons.people_rounded,
                stream: church.collection('members').snapshots(),
                onTap: onOpenMembers,
              ),
              _LiveCountCard(
                label: 'Events',
                icon: Icons.event_rounded,
                stream: church.collection('events').snapshots(),
                onTap: onOpenEvents,
              ),
              _LiveCountCard(
                label: 'Prayer Requests',
                icon: Icons.volunteer_activism_rounded,
                stream: church.collection('prayer_requests').snapshots(),
                onTap: onOpenPrayer,
              ),
              _LiveCountCard(
                label: 'Giving Records',
                icon: Icons.payments_rounded,
                stream: church.collection('donations').snapshots(),
                onTap: onOpenGiving,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Windows integration status',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const _StatusPanel(),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Wrap(
          spacing: 22,
          runSpacing: 18,
          children: const [
            _StatusItem(
              icon: Icons.cloud_done_rounded,
              title: 'Shared Firebase data',
              detail: 'Android and Windows use the same church records.',
            ),
            _StatusItem(
              icon: Icons.security_rounded,
              title: 'Role-protected access',
              detail: 'Only administrators and pastors enter this dashboard.',
            ),
            _StatusItem(
              icon: Icons.sync_rounded,
              title: 'Live updates',
              detail: 'Changes appear across connected ChurchSnap clients.',
            ),
            _StatusItem(
              icon: Icons.phone_android_rounded,
              title: 'Android preserved',
              detail: 'The member experience remains Android-first.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveCountCard extends StatelessWidget {
  const _LiveCountCard({
    required this.label,
    required this.icon,
    required this.stream,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 245,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length;

                return Row(
                  children: [
                    CircleAvatar(child: Icon(icon)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            snapshot.hasError
                                ? 'Unavailable'
                                : '${count ?? '...'}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WebEventsPage extends StatelessWidget {
  const _WebEventsPage({required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('churches')
        .doc(churchId)
        .collection('events')
        .snapshots();

    return _WebRecordPage(
      title: 'Events',
      subtitle: 'Review events synchronized from ChurchSnap.',
      stream: stream,
      emptyMessage: 'No events are available.',
      itemBuilder: (context, document) {
        final data = document.data();
        final title = WebAdminValueFormatter.text(data, const [
          'title',
          'name',
        ], fallback: 'Untitled event');
        final location = WebAdminValueFormatter.text(data, const [
          'location',
          'venue',
        ], fallback: 'Location not set');
        final status = WebAdminValueFormatter.text(data, const [
          'status',
        ], fallback: 'Published status not set');
        final dateValue =
            data['startDate'] ?? data['date'] ?? data['createdAt'];

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.event_rounded)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${WebAdminValueFormatter.date(dateValue)}\n$location â€¢ $status',
          ),
          isThreeLine: true,
        );
      },
    );
  }
}

class _WebPrayerPage extends StatelessWidget {
  const _WebPrayerPage({required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('churches')
        .doc(churchId)
        .collection('prayer_requests')
        .snapshots();

    return _WebRecordPage(
      title: 'Prayer Requests',
      subtitle: 'Authorized pastoral-care review only.',
      stream: stream,
      emptyMessage: 'No prayer requests are available.',
      itemBuilder: (context, document) {
        final data = document.data();
        final request = WebAdminValueFormatter.text(data, const [
          'request',
          'prayer',
          'body',
          'message',
        ], fallback: 'Prayer request text not provided');
        final member = WebAdminValueFormatter.text(data, const [
          'memberName',
          'displayName',
          'name',
        ], fallback: 'Anonymous or private member');
        final status = WebAdminValueFormatter.text(data, const [
          'status',
        ], fallback: 'New');
        final privateRequest =
            data['isPrivate'] == true || data['private'] == true;

        return ListTile(
          leading: CircleAvatar(
            child: Icon(
              privateRequest
                  ? Icons.lock_rounded
                  : Icons.volunteer_activism_rounded,
            ),
          ),
          title: Text(
            member,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text('$request\nStatus: $status'),
          isThreeLine: true,
        );
      },
    );
  }
}

class _WebGivingPage extends StatelessWidget {
  const _WebGivingPage({required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('churches')
        .doc(churchId)
        .collection('donations')
        .snapshots();

    return _WebRecordPage(
      title: 'Giving Records',
      subtitle: 'Private finance information for authorized leaders.',
      stream: stream,
      emptyMessage: 'No giving records are available.',
      itemBuilder: (context, document) {
        final data = document.data();
        final member = WebAdminValueFormatter.text(data, const [
          'memberName',
          'donorName',
          'displayName',
        ], fallback: 'Member name not stored');
        final fund = WebAdminValueFormatter.text(data, const [
          'fundName',
          'fund',
          'category',
        ], fallback: 'Fund not set');
        final status = WebAdminValueFormatter.text(data, const [
          'status',
        ], fallback: 'Status not set');
        final currency = WebAdminValueFormatter.text(data, const [
          'currency',
        ], fallback: 'USD');
        final amount = WebAdminValueFormatter.money(
          WebAdminDonationAmount.read(data),
          currency: currency,
        );

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.payments_rounded)),
          title: Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text('$member\n$fund - $status'),
          isThreeLine: true,
        );
      },
    );
  }
}

class _WebRecordPage extends StatelessWidget {
  const _WebRecordPage({
    required this.title,
    required this.subtitle,
    required this.stream,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  final String title;
  final String subtitle;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final String emptyMessage;
  final Widget Function(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  )
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    return _WebPageFrame(
      title: title,
      subtitle: subtitle,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _WebErrorState(error: snapshot.error!);
          }

          final documents = snapshot.data?.docs ?? const [];

          if (documents.isEmpty) {
            return Center(
              child: Text(
                emptyMessage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            itemCount: documents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return Card(child: itemBuilder(context, documents[index]));
            },
          );
        },
      ),
    );
  }
}

class _WebPageFrame extends StatelessWidget {
  const _WebPageFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _WebErrorState extends StatelessWidget {
  const _WebErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Unable to load this dashboard section',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
