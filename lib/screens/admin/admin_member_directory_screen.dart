import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/member_directory_entry.dart';
import '../../features/members/providers/member_directory_providers.dart';
import 'admin_member_profile_screen.dart';

enum _DirectoryView { visible, removed }

enum _DirectoryAction { openProfile, remove, restore }

class AdminMemberDirectoryScreen extends ConsumerStatefulWidget {
  const AdminMemberDirectoryScreen({super.key, required this.churchId});

  final String churchId;

  @override
  ConsumerState<AdminMemberDirectoryScreen> createState() =>
      _AdminMemberDirectoryScreenState();
}

class _AdminMemberDirectoryScreenState
    extends ConsumerState<AdminMemberDirectoryScreen> {
  _DirectoryView _view = _DirectoryView.visible;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _busyMemberIds = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(
      memberDirectoryEntriesByChurchProvider(widget.churchId),
    );

    return Material(
      child: ChurchSnapScreen(
        title: 'Church Member Directory',
        subtitle: 'View, search, remove, and restore directory members.',
        children: [
          const AppCard(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.shield_outlined)),
              title: Text(
                'Safe member removal',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                'Removing a person hides the member from this directory. '
                'It does not delete the account, giving history, attendance, '
                'RSVPs, prayer records, or private profile information.',
              ),
            ),
          ),
          const SizedBox(height: 14),
          entriesAsync.when(
            loading: () => const AppCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, _) => AppCard(
              child: ListTile(
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text('Unable to load the member directory'),
                subtitle: Text('$error'),
              ),
            ),
            data: (entries) => _buildDirectory(entries),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectory(List<MemberDirectoryEntry> entries) {
    final visibleCount = entries.where((entry) => !entry.isRemoved).length;
    final removedCount = entries.where((entry) => entry.isRemoved).length;
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    final filteredEntries = entries.where((entry) {
      final belongsToView = _view == _DirectoryView.visible
          ? !entry.isRemoved
          : entry.isRemoved;

      if (!belongsToView) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      return entry.searchableText.contains(normalizedQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_DirectoryView>(
          segments: [
            ButtonSegment<_DirectoryView>(
              value: _DirectoryView.visible,
              icon: const Icon(Icons.people_alt_rounded),
              label: Text('Visible ($visibleCount)'),
            ),
            ButtonSegment<_DirectoryView>(
              value: _DirectoryView.removed,
              icon: const Icon(Icons.person_off_rounded),
              label: Text('Removed ($removedCount)'),
            ),
          ],
          selected: <_DirectoryView>{_view},
          onSelectionChanged: (selection) {
            setState(() {
              _view = selection.first;
            });
          },
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            labelText: 'Search members',
            hintText: 'Name, email, phone, or role',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _searchController.clear();

                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        if (filteredEntries.isEmpty)
          AppCard(
            child: ListTile(
              leading: Icon(
                _view == _DirectoryView.visible
                    ? Icons.people_outline_rounded
                    : Icons.person_off_outlined,
              ),
              title: Text(
                normalizedQuery.isEmpty
                    ? _view == _DirectoryView.visible
                          ? 'No visible members found'
                          : 'No removed members'
                    : 'No matching members',
              ),
              subtitle: Text(
                normalizedQuery.isEmpty
                    ? _view == _DirectoryView.visible
                          ? 'Member records will appear here when available.'
                          : 'Members removed from the directory can be restored here.'
                    : 'Try a different name, email, phone number, or role.',
              ),
            ),
          )
        else
          ...filteredEntries.map(_buildMemberCard),
      ],
    );
  }

  Widget _buildMemberCard(MemberDirectoryEntry entry) {
    final displayName = entry.displayName.isEmpty
        ? 'Unnamed Member'
        : entry.displayName;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isCurrentUser = currentUserId == entry.id;
    final isBusy = _busyMemberIds.contains(entry.id);
    final details = <String>[
      if (entry.email.isNotEmpty) entry.email,
      if (entry.phone.isNotEmpty) entry.phone,
      _roleLabel(entry.role),
      entry.isActive ? 'Active account' : 'Inactive account',
    ];

    if (entry.isRemoved && entry.removalReason.isNotEmpty) {
      details.add('Reason: ${entry.removalReason}');
    }

    if (entry.isRemoved && entry.removedAt != null) {
      details.add('Removed: ${_formatDate(entry.removedAt!)}');
    }

    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundImage: entry.photoUrl.isEmpty
              ? null
              : NetworkImage(entry.photoUrl),
          child: entry.photoUrl.isEmpty
              ? Text(
                  displayName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            if (isCurrentUser)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Chip(label: Text('You')),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(details.join('\n')),
        ),
        isThreeLine: true,
        onTap: isBusy ? null : () => _openMemberProfile(entry),
        trailing: isBusy
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : PopupMenuButton<_DirectoryAction>(
                tooltip: 'Member actions',
                onSelected: (action) => _handleAction(action, entry),
                itemBuilder: (_) => [
                  const PopupMenuItem<_DirectoryAction>(
                    value: _DirectoryAction.openProfile,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.person_search_rounded),
                      title: Text('Open Member Profile'),
                    ),
                  ),
                  const PopupMenuDivider(),
                  if (entry.isRemoved)
                    PopupMenuItem<_DirectoryAction>(
                      value: _DirectoryAction.restore,
                      enabled: !isCurrentUser,
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.settings_backup_restore_rounded),
                        title: Text('Restore to Directory'),
                      ),
                    )
                  else
                    PopupMenuItem<_DirectoryAction>(
                      value: _DirectoryAction.remove,
                      enabled: !isCurrentUser,
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.person_remove_alt_1_rounded),
                        title: Text('Remove from Directory'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleAction(
    _DirectoryAction action,
    MemberDirectoryEntry entry,
  ) async {
    switch (action) {
      case _DirectoryAction.openProfile:
        await _openMemberProfile(entry);
        break;
      case _DirectoryAction.remove:
        await _confirmRemove(entry);
        break;
      case _DirectoryAction.restore:
        await _confirmRestore(entry);
        break;
    }
  }

  Future<void> _openMemberProfile(MemberDirectoryEntry entry) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AdminMemberProfileScreen(
          churchId: widget.churchId,
          member: entry.toChurchMember(),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(MemberDirectoryEntry entry) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final displayName = entry.displayName.isEmpty
            ? 'this member'
            : entry.displayName;

        return AlertDialog(
          title: const Text('Remove from directory?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$displayName will be hidden from the Church Member '
                  'Directory but the account and historical records will remain.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason (optional)',
                    hintText:
                        'Moved, transferred membership, requested privacy...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: true,
              ),
              icon: const Icon(Icons.person_remove_alt_1_rounded),
              label: const Text('Remove'),
            ),
          ],
        );
      },
    );

    final reason = reasonController.text.trim();
    reasonController.dispose();

    if (confirmed != true || !mounted) {
      return;
    }

    await _changeDirectoryStatus(entry: entry, visible: false, reason: reason);
  }

  Future<void> _confirmRestore(MemberDirectoryEntry entry) async {
    final displayName = entry.displayName.isEmpty
        ? 'this member'
        : entry.displayName;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restore to directory?'),
          content: Text(
            '$displayName will become visible again in the Church Member '
            'Directory.',
          ),
          actions: [
            TextButton(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: true,
              ),
              icon: const Icon(Icons.settings_backup_restore_rounded),
              label: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _changeDirectoryStatus(entry: entry, visible: true);
  }

  Future<void> _changeDirectoryStatus({
    required MemberDirectoryEntry entry,
    required bool visible,
    String reason = '',
  }) async {
    setState(() {
      _busyMemberIds.add(entry.id);
    });

    try {
      final repository = ref.read(
        memberDirectoryRepositoryByChurchProvider(widget.churchId),
      );

      if (visible) {
        await repository.restoreToDirectory(memberId: entry.id);
      } else {
        await repository.removeFromDirectory(
          memberId: entry.id,
          reason: reason,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            visible
                ? 'Member restored to the directory.'
                : 'Member removed from the directory.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            visible
                ? 'Unable to restore the member: $error'
                : 'Unable to remove the member: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyMemberIds.remove(entry.id);
        });
      }
    }
  }

  static String _roleLabel(String role) {
    switch (role.trim()) {
      case 'groupLeader':
        return 'Group Leader';
      case 'ministryLeader':
        return 'Ministry Leader';
      case 'admin':
        return 'Administrator';
      case 'pastor':
        return 'Pastor';
      case 'volunteer':
        return 'Volunteer';
      case 'visitor':
        return 'Visitor';
      case 'member':
        return 'Member';
      default:
        final normalized = role.trim();

        if (normalized.isEmpty) {
          return 'Member';
        }

        return normalized;
    }
  }

  static String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');

    return '${localDate.year}-$month-$day';
  }
}
