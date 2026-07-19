import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/app_roles.dart';
import '../models/web_admin_staff_member.dart';
import '../services/web_admin_staff_access_service.dart';
import 'web_admin_audit_log.dart';

class WebAdminStaffAccessScreen extends StatefulWidget {
  const WebAdminStaffAccessScreen({
    super.key,
    required this.churchId,
    required this.currentUserId,
    required this.currentUserRole,
  });

  final String churchId;
  final String currentUserId;
  final String currentUserRole;

  @override
  State<WebAdminStaffAccessScreen> createState() =>
      _WebAdminStaffAccessScreenState();
}

class _WebAdminStaffAccessScreenState extends State<WebAdminStaffAccessScreen> {
  late final WebAdminStaffAccessService _service;
  final TextEditingController _searchController = TextEditingController();

  String _search = '';
  String? _selectedRole;
  bool _leadershipOnly = false;
  String? _savingMemberId;

  bool get _canManageRoles => widget.currentUserRole == AppRoles.admin;

  @override
  void initState() {
    super.initState();

    _service = WebAdminStaffAccessService(
      firestore: FirebaseFirestore.instance,
      churchId: widget.churchId,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_canManageRoles) {
      return const _StaffAccessDenied();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Staff Access',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Administrative activity',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WebAdminAuditLogScreen(
                    churchId: widget.churchId,
                    currentUserRole: widget.currentUserRole,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: StreamBuilder<List<WebAdminStaffMember>>(
        stream: _service.watchMembers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _StaffAccessError(error: snapshot.error);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = snapshot.data!;
          final visibleMembers = _filterMembers(members);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roles and permissions',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Assign ChurchSnap access carefully. Your own '
                      'administrator role is protected, and every role change '
                      'creates an administrative audit record.',
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
                    _RoleSummaryCard(
                      label: 'Administrators',
                      count: WebAdminStaffAccessService.countRole(
                        members,
                        AppRoles.admin,
                      ),
                      icon: Icons.admin_panel_settings_rounded,
                    ),
                    _RoleSummaryCard(
                      label: 'Pastors',
                      count: WebAdminStaffAccessService.countRole(
                        members,
                        AppRoles.pastor,
                      ),
                      icon: Icons.church_rounded,
                    ),
                    _RoleSummaryCard(
                      label: 'Ministry leaders',
                      count: WebAdminStaffAccessService.countRole(
                        members,
                        AppRoles.ministryLeader,
                      ),
                      icon: Icons.groups_rounded,
                    ),
                    _RoleSummaryCard(
                      label: 'Volunteers',
                      count: WebAdminStaffAccessService.countRole(
                        members,
                        AppRoles.volunteer,
                      ),
                      icon: Icons.volunteer_activism_rounded,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final search = TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _search = value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        labelText: 'Search members',
                        hintText: 'Name or email',
                        border: OutlineInputBorder(),
                      ),
                    );
                    final roleFilter = DropdownButtonFormField<String?>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role filter',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All roles'),
                        ),
                        ...AppRoles.assignableRoles.map(
                          (role) => DropdownMenuItem<String?>(
                            value: role,
                            child: Text(AppRoles.label(role)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedRole = value);
                      },
                    );

                    if (constraints.maxWidth < 760) {
                      return Column(
                        children: [
                          search,
                          const SizedBox(height: 12),
                          roleFilter,
                          const SizedBox(height: 4),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Leadership roles only'),
                            value: _leadershipOnly,
                            onChanged: (value) {
                              setState(() => _leadershipOnly = value);
                            },
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 2, child: search),
                        const SizedBox(width: 12),
                        Expanded(child: roleFilter),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 210,
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Leadership only'),
                            value: _leadershipOnly,
                            onChanged: (value) {
                              setState(() => _leadershipOnly = value);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: visibleMembers.isEmpty
                    ? const _NoStaffResults()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
                        itemCount: visibleMembers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final member = visibleMembers[index];

                          return _StaffMemberCard(
                            member: member,
                            isCurrentUser: member.id == widget.currentUserId,
                            isSaving: _savingMemberId == member.id,
                            onRoleChanged: (role) {
                              _requestRoleChange(member, role);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<WebAdminStaffMember> _filterMembers(List<WebAdminStaffMember> members) {
    final query = _search.trim().toLowerCase();

    return members
        .where((member) {
          final searchMatches =
              query.isEmpty ||
              member.displayName.toLowerCase().contains(query) ||
              member.email.toLowerCase().contains(query);
          final roleMatches =
              _selectedRole == null || member.role == _selectedRole;
          final leadershipMatches = !_leadershipOnly || member.isLeadership;

          return searchMatches && roleMatches && leadershipMatches;
        })
        .toList(growable: false);
  }

  Future<void> _requestRoleChange(
    WebAdminStaffMember member,
    String newRole,
  ) async {
    if (member.id == widget.currentUserId || member.role == newRole) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Confirm role change'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppRoles.label(member.role)} â†’ '
                    '${AppRoles.label(newRole)}',
                  ),
                  const SizedBox(height: 12),
                  Text(AppRoles.description(newRole)),
                  if (newRole == AppRoles.admin) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Administrator access includes sensitive role and '
                      'permission management.',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Change Role'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _savingMemberId = member.id);

    try {
      await _service.changeRole(
        member: member,
        newRole: newRole,
        actorId: widget.currentUserId,
        actorRole: widget.currentUserRole,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member.displayName} is now '
            '${AppRoles.label(newRole)}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to change role: $error')));
    } finally {
      if (mounted) {
        setState(() => _savingMemberId = null);
      }
    }
  }
}

class _RoleSummaryCard extends StatelessWidget {
  const _RoleSummaryCard({
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
      width: 205,
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

class _StaffMemberCard extends StatelessWidget {
  const _StaffMemberCard({
    required this.member,
    required this.isCurrentUser,
    required this.isSaving,
    required this.onRoleChanged,
  });

  final WebAdminStaffMember member;
  final bool isCurrentUser;
  final bool isSaving;
  final ValueChanged<String> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final identity = Row(
              children: [
                CircleAvatar(
                  child: Text(
                    member.displayName.isEmpty
                        ? '?'
                        : member.displayName[0].toUpperCase(),
                  ),
                ),
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
                            member.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (isCurrentUser)
                            const Chip(label: Text('Your account')),
                          if (!member.isActive)
                            const Chip(label: Text('Inactive')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(member.email),
                      const SizedBox(height: 4),
                      Text(
                        AppRoles.description(member.role),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            );
            final roleControl = isSaving
                ? const SizedBox(
                    width: 48,
                    height: 48,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  )
                : SizedBox(
                    width: 230,
                    child: DropdownButtonFormField<String>(
                      initialValue: member.role,
                      decoration: InputDecoration(
                        labelText: isCurrentUser
                            ? 'Protected role'
                            : 'Assigned role',
                        border: const OutlineInputBorder(),
                      ),
                      items: AppRoles.assignableRoles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(AppRoles.label(role)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: isCurrentUser
                          ? null
                          : (role) {
                              if (role != null) {
                                onRoleChanged(role);
                              }
                            },
                    ),
                  );

            if (constraints.maxWidth < 720) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [identity, const SizedBox(height: 16), roleControl],
              );
            }

            return Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: 20),
                roleControl,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NoStaffResults extends StatelessWidget {
  const _NoStaffResults();

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
              Icon(Icons.person_search_rounded, size: 54),
              SizedBox(height: 12),
              Text(
                'No matching members',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 6),
              Text('Adjust the search or role filters.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffAccessError extends StatelessWidget {
  const _StaffAccessError({required this.error});

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
                'Unable to load staff access',
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

class _StaffAccessDenied extends StatelessWidget {
  const _StaffAccessDenied();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Access')),
      body: const Center(
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
                  'Pastors and other leaders may use their assigned dashboard '
                  'areas, but only an administrator can manage account roles.',
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
