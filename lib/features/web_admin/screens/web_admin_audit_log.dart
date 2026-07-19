import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/app_roles.dart';
import '../models/web_admin_audit_entry.dart';
import '../services/web_admin_audit_log_service.dart';

class WebAdminAuditLogScreen extends StatefulWidget {
  const WebAdminAuditLogScreen({
    super.key,
    required this.churchId,
    required this.currentUserRole,
  });

  final String churchId;
  final String currentUserRole;

  @override
  State<WebAdminAuditLogScreen> createState() => _WebAdminAuditLogScreenState();
}

class _WebAdminAuditLogScreenState extends State<WebAdminAuditLogScreen> {
  late final WebAdminAuditLogService _service;

  String _search = '';
  String? _selectedAction;
  WebAdminAuditPeriod _period = WebAdminAuditPeriod.thirtyDays;

  bool get _canView => widget.currentUserRole == AppRoles.admin;

  @override
  void initState() {
    super.initState();

    _service = WebAdminAuditLogService(
      firestore: FirebaseFirestore.instance,
      churchId: widget.churchId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_canView) {
      return const _AuditAccessDenied();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Administrative Activity',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: StreamBuilder<List<WebAdminAuditEntry>>(
        stream: _service.watchEntries(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _AuditError(error: snapshot.error);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data!;
          final actions = entries.map((entry) => entry.action).toSet().toList()
            ..sort();
          final visibleEntries = WebAdminAuditLogService.filterEntries(
            entries: entries,
            search: _search,
            action: _selectedAction,
            period: _period,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audit trail',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Review sensitive administrative actions. Audit records '
                      'are read-only and cannot be edited or deleted from '
                      'ChurchSnap.',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _AuditSummaryCard(
                      label: 'Visible records',
                      count: visibleEntries.length,
                      icon: Icons.receipt_long_rounded,
                    ),
                    _AuditSummaryCard(
                      label: 'Role changes',
                      count: WebAdminAuditLogService.countAction(
                        visibleEntries,
                        'member_role_changed',
                      ),
                      icon: Icons.manage_accounts_rounded,
                    ),
                    _AuditSummaryCard(
                      label: 'Administrators active',
                      count: WebAdminAuditLogService.uniqueActorCount(
                        visibleEntries,
                      ),
                      icon: Icons.admin_panel_settings_rounded,
                    ),
                    _AuditSummaryCard(
                      label: 'Members affected',
                      count: WebAdminAuditLogService.uniqueTargetCount(
                        visibleEntries,
                      ),
                      icon: Icons.people_alt_rounded,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final search = TextField(
                      onChanged: (value) => setState(() => _search = value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        labelText: 'Search activity',
                        hintText: 'Member, administrator, role, or action',
                        border: OutlineInputBorder(),
                      ),
                    );
                    final actionFilter = DropdownButtonFormField<String?>(
                      initialValue: _selectedAction,
                      decoration: const InputDecoration(
                        labelText: 'Action',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All actions'),
                        ),
                        ...actions.map(
                          (action) => DropdownMenuItem<String?>(
                            value: action,
                            child: Text(_actionLabel(action)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedAction = value);
                      },
                    );
                    final periodFilter =
                        DropdownButtonFormField<WebAdminAuditPeriod>(
                          initialValue: _period,
                          decoration: const InputDecoration(
                            labelText: 'Period',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: WebAdminAuditPeriod.today,
                              child: Text('Today'),
                            ),
                            DropdownMenuItem(
                              value: WebAdminAuditPeriod.sevenDays,
                              child: Text('Last 7 days'),
                            ),
                            DropdownMenuItem(
                              value: WebAdminAuditPeriod.thirtyDays,
                              child: Text('Last 30 days'),
                            ),
                            DropdownMenuItem(
                              value: WebAdminAuditPeriod.all,
                              child: Text('All time'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _period = value);
                            }
                          },
                        );

                    if (constraints.maxWidth < 840) {
                      return Column(
                        children: [
                          search,
                          const SizedBox(height: 12),
                          actionFilter,
                          const SizedBox(height: 12),
                          periodFilter,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 2, child: search),
                        const SizedBox(width: 12),
                        Expanded(child: actionFilter),
                        const SizedBox(width: 12),
                        Expanded(child: periodFilter),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: visibleEntries.isEmpty
                    ? const _NoAuditEntries()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
                        itemCount: visibleEntries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _AuditEntryCard(entry: visibleEntries[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _actionLabel(String action) {
    return WebAdminAuditEntry(
      id: '',
      action: action,
      actorId: '',
      actorRole: '',
      targetMemberId: '',
      targetDisplayName: '',
      previousRole: '',
      newRole: '',
      createdAt: null,
    ).actionLabel;
  }
}

class _AuditSummaryCard extends StatelessWidget {
  const _AuditSummaryCard({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditEntryCard extends StatelessWidget {
  const _AuditEntryCard({required this.entry});

  final WebAdminAuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final createdAt = entry.createdAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(child: Icon(Icons.history_rounded)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        entry.actionLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (createdAt != null)
                        Chip(label: Text(_formatDate(createdAt))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.targetDisplayName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppRoles.label(entry.previousRole)} â†’ '
                    '${AppRoles.label(entry.newRole)}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Performed by ${_shortId(entry.actorId)} '
                    '(${AppRoles.label(entry.actorRole)})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _shortId(String value) {
    if (value.length <= 14) {
      return value;
    }

    return '${value.substring(0, 7)}â€¦${value.substring(value.length - 5)}';
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _NoAuditEntries extends StatelessWidget {
  const _NoAuditEntries();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        margin: EdgeInsets.all(24),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fact_check_outlined, size: 54),
              SizedBox(height: 12),
              Text(
                'No matching activity',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 6),
              Text(
                'Adjust the search, action, or period filters.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditError extends StatelessWidget {
  const _AuditError({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 52),
              const SizedBox(height: 12),
              const Text(
                'Unable to load administrative activity',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text('$error', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditAccessDenied extends StatelessWidget {
  const _AuditAccessDenied();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Card(
          margin: EdgeInsets.all(24),
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 58),
                SizedBox(height: 14),
                Text(
                  'Administrator access required',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'Administrative audit records are available only to '
                  'ChurchSnap administrators.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
