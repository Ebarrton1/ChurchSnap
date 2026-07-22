import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/small_group/models/small_group.dart';
import '../../features/groups_ministries/models/group_ministry_join_request.dart';
import '../../features/small_group/providers/small_group_providers.dart';
import 'admin_group_ministry_join_requests_screen.dart';

class AdminSmallGroupsScreen extends ConsumerWidget {
  const AdminSmallGroupsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(smallGroupServiceByChurchProvider(churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Small Groups',
        subtitle: 'Manage church small groups.',
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => _openGroupDialog(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Group'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AdminGroupMinistryJoinRequestsScreen(
                        churchId: churchId,
                        targetType: GroupMinistryJoinRequest.smallGroupType,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.how_to_reg_rounded),
                label: const Text('Join Requests'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<SmallGroup>>(
            stream: service.watchGroups(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load small groups'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final groups = snapshot.data ?? <SmallGroup>[];

              if (groups.isEmpty) {
                return const AppCard(child: Text('No small groups yet.'));
              }

              return Column(
                children: groups.map((group) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.groups_rounded),
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${group.leaderName.isEmpty ? 'Leader not assigned' : group.leaderName}\n'
                        '${group.location.isEmpty ? 'Location not set' : group.location}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openGroupDialog(context, ref, group: group);
                            return;
                          }

                          if (value == 'delete') {
                            _deleteGroup(context, ref, group);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openGroupDialog(
    BuildContext context,
    WidgetRef ref, {
    SmallGroup? group,
  }) async {
    final updatedGroup = await showDialog<SmallGroup>(
      context: context,
      builder: (_) => _SmallGroupDialog(group: group),
    );

    if (updatedGroup == null || !context.mounted) {
      return;
    }

    try {
      final service = ref.read(smallGroupServiceByChurchProvider(churchId));

      if (group == null) {
        await service.addGroup(updatedGroup);
      } else {
        await service.updateGroup(updatedGroup);
      }

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            group == null ? 'Small group created.' : 'Small group updated.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save small group: $error')),
      );
    }
  }

  Future<void> _deleteGroup(
    BuildContext context,
    WidgetRef ref,
    SmallGroup group,
  ) async {
    try {
      await ref
          .read(smallGroupServiceByChurchProvider(churchId))
          .deleteGroup(group.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Small group deleted.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete small group: $error')),
      );
    }
  }
}

class _SmallGroupDialog extends StatefulWidget {
  const _SmallGroupDialog({this.group});

  final SmallGroup? group;

  @override
  State<_SmallGroupDialog> createState() => _SmallGroupDialogState();
}

class _SmallGroupDialogState extends State<_SmallGroupDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _leaderNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;

  late bool _active;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.group?.name ?? '');

    _descriptionController = TextEditingController(
      text: widget.group?.description ?? '',
    );

    _leaderNameController = TextEditingController(
      text: widget.group?.leaderName ?? '',
    );

    _locationController = TextEditingController(
      text: widget.group?.location ?? '',
    );

    _capacityController = TextEditingController(
      text: '${widget.group?.capacity ?? 12}',
    );

    _active = widget.group?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _leaderNameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.group == null ? 'Create Small Group' : 'Edit Small Group',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _leaderNameController,
                decoration: const InputDecoration(labelText: 'Leader Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Location',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active group'),
                value: _active,
                onChanged: (value) {
                  setState(() {
                    _active = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();

            if (name.isEmpty) {
              return;
            }

            final capacity =
                int.tryParse(_capacityController.text.trim()) ?? 12;

            Navigator.of(context).pop(
              SmallGroup(
                id: widget.group?.id ?? '',
                name: name,
                description: _descriptionController.text.trim(),
                leaderId: widget.group?.leaderId ?? '',
                leaderName: _leaderNameController.text.trim(),
                location: _locationController.text.trim(),
                meetingDate: widget.group?.meetingDate,
                capacity: capacity < 1 ? 1 : capacity,
                memberIds: widget.group?.memberIds ?? const <String>[],
                active: _active,
              ),
            );
          },
          child: Text(widget.group == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
