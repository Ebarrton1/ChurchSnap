import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/groups_ministries/models/group_ministry_join_request.dart';
import '../../features/groups_ministries/repositories/group_ministry_join_repository.dart';

class AdminGroupMinistryJoinRequestsScreen extends StatefulWidget {
  const AdminGroupMinistryJoinRequestsScreen({
    super.key,
    required this.churchId,
    required this.targetType,
  });

  final String churchId;
  final String targetType;

  @override
  State<AdminGroupMinistryJoinRequestsScreen> createState() =>
      _AdminGroupMinistryJoinRequestsScreenState();
}

class _AdminGroupMinistryJoinRequestsScreenState
    extends State<AdminGroupMinistryJoinRequestsScreen> {
  late final GroupMinistryJoinRepository _repository;
  final Set<String> _busyRequestIds = <String>{};

  @override
  void initState() {
    super.initState();

    _repository = GroupMinistryJoinRepository(churchId: widget.churchId);
  }

  @override
  Widget build(BuildContext context) {
    final isGroup =
        widget.targetType == GroupMinistryJoinRequest.smallGroupType;
    final title = isGroup
        ? 'Small Group Join Requests'
        : 'Ministry Join Requests';

    return Material(
      child: ChurchSnapScreen(
        title: title,
        subtitle: 'Approve or decline member requests.',
        children: [
          StreamBuilder<List<GroupMinistryJoinRequest>>(
            stream: _repository.watchRequestsByType(widget.targetType),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load join requests'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final requests =
                  snapshot.data ?? const <GroupMinistryJoinRequest>[];

              if (requests.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.inbox_outlined),
                    title: Text('No join requests'),
                    subtitle: Text(
                      'Member requests will appear here for review.',
                    ),
                  ),
                );
              }

              return Column(
                children: requests
                    .map((request) {
                      return _buildRequestCard(request);
                    })
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(GroupMinistryJoinRequest request) {
    final busy = _busyRequestIds.contains(request.id);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Icon(
                request.targetType == GroupMinistryJoinRequest.smallGroupType
                    ? Icons.groups_rounded
                    : Icons.church_rounded,
              ),
            ),
            title: Text(
              request.memberName.isEmpty
                  ? 'ChurchSnap Member'
                  : request.memberName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              '${request.targetTypeLabel}: ${request.targetName}\n'
              'Member ID: ${request.userId}',
            ),
            isThreeLine: true,
            trailing: _StatusChip(status: request.status),
          ),
          if (request.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Member note',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(request.note),
          ],
          if (request.createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Submitted ${_formatDate(request.createdAt!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (request.isPending) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: busy
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Wrap(
                      spacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _review(request, approve: false),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Decline'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _review(request, approve: true),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Approve'),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _review(
    GroupMinistryJoinRequest request, {
    required bool approve,
  }) async {
    final reviewerId = FirebaseAuth.instance.currentUser?.uid.trim() ?? '';

    if (reviewerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An authenticated administrator is required.'),
        ),
      );
      return;
    }

    setState(() {
      _busyRequestIds.add(request.id);
    });

    try {
      await _repository.reviewRequest(
        request: request,
        approve: approve,
        reviewerId: reviewerId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve
                  ? '${request.memberName} was added successfully.'
                  : 'The join request was declined.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to review this request: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busyRequestIds.remove(request.id);
        });
      }
    }
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      GroupMinistryJoinRequest.approvedStatus => Icons.check_circle_rounded,
      GroupMinistryJoinRequest.declinedStatus => Icons.cancel_rounded,
      _ => Icons.pending_rounded,
    };

    final label = switch (status) {
      GroupMinistryJoinRequest.approvedStatus => 'Approved',
      GroupMinistryJoinRequest.declinedStatus => 'Declined',
      _ => 'Pending',
    };

    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
