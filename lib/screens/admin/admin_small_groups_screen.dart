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
          onPressed: () {
            // We'll implement the creation dialog next.
          },
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
}
