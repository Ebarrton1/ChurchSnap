import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/groups_ministries/models/group_ministry_join_request.dart';
import '../../features/groups_ministries/repositories/group_ministry_join_repository.dart';
import '../../features/ministries/models/ministry.dart';
import '../../features/ministries/repositories/ministry_repository.dart';
import '../../features/small_group/models/small_group.dart';
import '../../features/small_group/repositories/small_group_repository.dart';

class GroupsAndMinistriesScreen extends StatefulWidget {
  const GroupsAndMinistriesScreen({
    super.key,
    required this.churchId,
    required this.userId,
    required this.memberName,
  });

  final String churchId;
  final String userId;
  final String memberName;

  @override
  State<GroupsAndMinistriesScreen> createState() =>
      _GroupsAndMinistriesScreenState();
}

class _GroupsAndMinistriesScreenState extends State<GroupsAndMinistriesScreen> {
  late final MinistryRepository _ministryRepository;
  late final SmallGroupRepository _smallGroupRepository;
  late final GroupMinistryJoinRepository _joinRepository;

  final Set<String> _busyTargets = <String>{};
  bool _showMinistries = true;

  @override
  void initState() {
    super.initState();

    _ministryRepository = MinistryRepository(churchId: widget.churchId);
    _smallGroupRepository = SmallGroupRepository(churchId: widget.churchId);
    _joinRepository = GroupMinistryJoinRepository(churchId: widget.churchId);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChurchSnapScreen(
        title: 'Groups & Ministries',
        subtitle: 'Connect, serve, and grow with your church community.',
        children: [
          StreamBuilder<List<Ministry>>(
            stream: _ministryRepository.watchMinistries(),
            builder: (context, ministrySnapshot) {
              return StreamBuilder<List<SmallGroup>>(
                stream: _smallGroupRepository.watchGroups(),
                builder: (context, groupSnapshot) {
                  return StreamBuilder<List<GroupMinistryJoinRequest>>(
                    stream: _joinRepository.watchMemberRequests(widget.userId),
                    builder: (context, requestSnapshot) {
                      if (_isWaiting(
                        ministrySnapshot,
                        groupSnapshot,
                        requestSnapshot,
                      )) {
                        return const AppCard(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final error =
                          ministrySnapshot.error ??
                          groupSnapshot.error ??
                          requestSnapshot.error;

                      if (error != null) {
                        return AppCard(
                          child: ListTile(
                            leading: const Icon(Icons.error_outline_rounded),
                            title: const Text(
                              'Unable to load groups and ministries',
                            ),
                            subtitle: Text('$error'),
                          ),
                        );
                      }

                      final ministries =
                          (ministrySnapshot.data ?? const <Ministry>[])
                              .where((ministry) => ministry.isActive)
                              .toList();

                      final groups =
                          (groupSnapshot.data ?? const <SmallGroup>[])
                              .where((group) => group.active)
                              .toList();

                      final requests =
                          requestSnapshot.data ??
                          const <GroupMinistryJoinRequest>[];

                      return _buildCatalog(
                        context,
                        ministries: ministries,
                        groups: groups,
                        requests: requests,
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCatalog(
    BuildContext context, {
    required List<Ministry> ministries,
    required List<SmallGroup> groups,
    required List<GroupMinistryJoinRequest> requests,
  }) {
    final joinedMinistries = ministries
        .where((ministry) => ministry.memberIds.contains(widget.userId))
        .length;

    final joinedGroups = groups
        .where((group) => group.memberIds.contains(widget.userId))
        .length;

    final pendingCount = requests.where((request) => request.isPending).length;

    final requestsByTarget = <String, GroupMinistryJoinRequest>{
      for (final request in requests) request.targetKey: request,
    };

    final entries = _showMinistries
        ? ministries.map(_CatalogEntry.fromMinistry).toList()
        : groups.map(_CatalogEntry.fromSmallGroup).toList();

    return Column(
      children: [
        AppCard(
          child: Wrap(
            spacing: 18,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _SummaryMetric(
                icon: Icons.church_rounded,
                label: 'My ministries',
                value: joinedMinistries,
              ),
              _SummaryMetric(
                icon: Icons.groups_rounded,
                label: 'My groups',
                value: joinedGroups,
              ),
              _SummaryMetric(
                icon: Icons.pending_actions_rounded,
                label: 'Pending',
                value: pendingCount,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Icons.church_rounded),
              label: Text('Ministries'),
            ),
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Icons.groups_rounded),
              label: Text('Small Groups'),
            ),
          ],
          selected: <bool>{_showMinistries},
          onSelectionChanged: (selection) {
            setState(() {
              _showMinistries = selection.first;
            });
          },
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          AppCard(
            child: ListTile(
              leading: Icon(
                _showMinistries ? Icons.church_outlined : Icons.groups_outlined,
              ),
              title: Text(
                _showMinistries
                    ? 'No active ministries yet'
                    : 'No active small groups yet',
              ),
              subtitle: const Text(
                'New opportunities will appear here when they are published.',
              ),
            ),
          )
        else
          ...entries.map((entry) {
            final request = requestsByTarget[entry.targetKey];
            final joined = entry.memberIds.contains(widget.userId);

            return _buildEntryCard(
              context,
              entry: entry,
              request: request,
              joined: joined,
            );
          }),
      ],
    );
  }

  Widget _buildEntryCard(
    BuildContext context, {
    required _CatalogEntry entry,
    required GroupMinistryJoinRequest? request,
    required bool joined,
  }) {
    final busy = _busyTargets.contains(entry.targetKey);
    final groupFull =
        entry.targetType == GroupMinistryJoinRequest.smallGroupType &&
        !joined &&
        entry.capacity > 0 &&
        entry.memberIds.length >= entry.capacity;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Icon(
                entry.targetType == GroupMinistryJoinRequest.ministryType
                    ? Icons.church_rounded
                    : Icons.groups_rounded,
              ),
            ),
            title: Text(
              entry.name,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              entry.leaderName.isEmpty
                  ? 'Leader not yet assigned'
                  : 'Leader: ${entry.leaderName}',
            ),
            trailing: Chip(label: Text('${entry.memberIds.length} members')),
          ),
          if (entry.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(entry.description),
          ],
          if (entry.location.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 19),
                const SizedBox(width: 7),
                Expanded(child: Text(entry.location)),
              ],
            ),
          ],
          if (entry.meetingDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 19),
                const SizedBox(width: 7),
                Text(_formatDate(entry.meetingDate!)),
              ],
            ),
          ],
          if (entry.targetType == GroupMinistryJoinRequest.smallGroupType) ...[
            const SizedBox(height: 8),
            Text(
              'Capacity: ${entry.memberIds.length}/${entry.capacity}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (request != null && request.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Your note: ${request.note}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: _buildAction(
              context,
              entry: entry,
              request: request,
              joined: joined,
              busy: busy,
              groupFull: groupFull,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    BuildContext context, {
    required _CatalogEntry entry,
    required GroupMinistryJoinRequest? request,
    required bool joined,
    required bool busy,
    required bool groupFull,
  }) {
    if (busy) {
      return const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }

    if (joined) {
      return const Chip(
        avatar: Icon(Icons.check_circle_rounded, size: 18),
        label: Text('Joined'),
      );
    }

    if (request?.isPending == true) {
      return OutlinedButton.icon(
        onPressed: () => _cancelRequest(request!),
        icon: const Icon(Icons.close_rounded),
        label: const Text('Cancel Request'),
      );
    }

    if (request?.isApproved == true) {
      return const Chip(
        avatar: Icon(Icons.verified_rounded, size: 18),
        label: Text('Approved'),
      );
    }

    if (groupFull) {
      return const Chip(
        avatar: Icon(Icons.block_rounded, size: 18),
        label: Text('Group Full'),
      );
    }

    return FilledButton.icon(
      onPressed: () => _requestToJoin(
        entry,
        previousRequest: request?.isDeclined == true ? request : null,
      ),
      icon: Icon(
        request?.isDeclined == true
            ? Icons.refresh_rounded
            : Icons.person_add_alt_1_rounded,
      ),
      label: Text(
        request?.isDeclined == true ? 'Request Again' : 'Request to Join',
      ),
    );
  }

  Future<void> _requestToJoin(
    _CatalogEntry entry, {
    GroupMinistryJoinRequest? previousRequest,
  }) async {
    final noteController = TextEditingController();

    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            previousRequest == null
                ? 'Request to Join'
                : 'Submit a New Request',
          ),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Send a request to join ${entry.name}. '
                  'A church leader will review it.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Note for the leader (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(noteController.text.trim());
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );

    noteController.dispose();

    if (note == null || !mounted) {
      return;
    }

    await _runBusy(entry.targetKey, () async {
      if (previousRequest == null) {
        await _joinRepository.submitRequest(
          userId: widget.userId,
          memberName: widget.memberName,
          targetType: entry.targetType,
          targetId: entry.id,
          targetName: entry.name,
          note: note,
        );
      } else {
        await _joinRepository.resubmitRequest(
          previousRequest: previousRequest,
          memberName: widget.memberName,
          note: note,
        );
      }
    }, successMessage: 'Your join request was sent.');
  }

  Future<void> _cancelRequest(GroupMinistryJoinRequest request) {
    return _runBusy(
      request.targetKey,
      () => _joinRepository.removeRequest(request),
      successMessage: 'Your join request was cancelled.',
    );
  }

  Future<void> _runBusy(
    String targetKey,
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() {
      _busyTargets.add(targetKey);
    });

    try {
      await action();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to complete this request: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busyTargets.remove(targetKey);
        });
      }
    }
  }

  static bool _isWaiting(
    AsyncSnapshot<List<Ministry>> ministries,
    AsyncSnapshot<List<SmallGroup>> groups,
    AsyncSnapshot<List<GroupMinistryJoinRequest>> requests,
  ) {
    return (ministries.connectionState == ConnectionState.waiting &&
            !ministries.hasData) ||
        (groups.connectionState == ConnectionState.waiting &&
            !groups.hasData) ||
        (requests.connectionState == ConnectionState.waiting &&
            !requests.hasData);
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

class _CatalogEntry {
  const _CatalogEntry({
    required this.id,
    required this.targetType,
    required this.name,
    required this.description,
    required this.leaderName,
    required this.memberIds,
    this.location = '',
    this.meetingDate,
    this.capacity = 0,
  });

  final String id;
  final String targetType;
  final String name;
  final String description;
  final String leaderName;
  final List<String> memberIds;
  final String location;
  final DateTime? meetingDate;
  final int capacity;

  String get targetKey => '$targetType:$id';

  factory _CatalogEntry.fromMinistry(Ministry ministry) {
    return _CatalogEntry(
      id: ministry.id,
      targetType: GroupMinistryJoinRequest.ministryType,
      name: ministry.name,
      description: ministry.description,
      leaderName: ministry.leaderName,
      memberIds: ministry.memberIds,
    );
  }

  factory _CatalogEntry.fromSmallGroup(SmallGroup group) {
    return _CatalogEntry(
      id: group.id,
      targetType: GroupMinistryJoinRequest.smallGroupType,
      name: group.name,
      description: group.description,
      leaderName: group.leaderName,
      memberIds: group.memberIds,
      location: group.location,
      meetingDate: group.meetingDate,
      capacity: group.capacity,
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
