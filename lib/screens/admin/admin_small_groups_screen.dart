import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/small_group/models/small_group.dart';
import '../../features/small_group/providers/small_group_providers.dart';

class AdminSmallGroupsScreen extends ConsumerWidget {
  const AdminSmallGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(smallGroupServiceProvider);

    return ChurchSnapScreen(
      title: 'Small Groups',
      subtitle: 'Manage church small groups.',
      children: [
        FilledButton.icon(
          onPressed: () => _showCreateGroupDialog(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Create Group'),
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
              return AppCard(child: Text('Error: ${snapshot.error}'));
            }

            final groups = snapshot.data ?? [];

            if (groups.isEmpty) {
              return const AppCard(child: Text('No small groups yet.'));
            }

            return Column(
              children: groups.map((group) {
                return AppCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.groups_rounded),
                    ),
                    title: Text(group.name),
                    subtitle: Text('${group.leaderName}\n${group.location}'),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(
                        '${group.memberIds.length}/${group.capacity}',
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final capacityController = TextEditingController(text: '12');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Small Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Group Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting Location',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final group = SmallGroup(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  leaderId: '',
                  leaderName: 'To Be Assigned',
                  location: locationController.text.trim(),
                  capacity: int.tryParse(capacityController.text) ?? 12,
                );

                await ref.read(smallGroupServiceProvider).addGroup(group);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      descriptionController.dispose();
      locationController.dispose();
      capacityController.dispose();
    });
  }
}
