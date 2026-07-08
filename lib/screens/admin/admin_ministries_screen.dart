import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/ministries/models/ministry.dart';
import '../../features/ministries/providers/ministry_providers.dart';

class AdminMinistriesScreen extends ConsumerWidget {
  const AdminMinistriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ministryService = ref.read(ministryServiceProvider);

    return ChurchSnapScreen(
      title: 'Ministries',
      subtitle: 'Manage church ministries and volunteer teams.',
      children: [
        FilledButton.icon(
          onPressed: () => _showMinistryDialog(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Ministry'),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Ministry>>(
          stream: ministryService.watchMinistries(),
          builder: (context, snapshot) {
            final ministries = snapshot.data ?? [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (ministries.isEmpty) {
              return const AppCard(child: Text('No ministries yet.'));
            }

            return Column(
              children: ministries.map((ministry) {
                return AppCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.groups_rounded),
                    ),
                    title: Text(ministry.name),
                    subtitle: Text(
                      '${ministry.leaderName.isEmpty ? 'No leader assigned' : ministry.leaderName}\n${ministry.memberIds.length} volunteers',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showMinistryDialog(context, ref, ministry: ministry);
                        }

                        if (value == 'delete') {
                          ref
                              .read(ministryServiceProvider)
                              .deleteMinistry(ministry.id);
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
    );
  }

  void _showMinistryDialog(
    BuildContext context,
    WidgetRef ref, {
    Ministry? ministry,
  }) {
    final nameController = TextEditingController(text: ministry?.name ?? '');
    final descriptionController = TextEditingController(
      text: ministry?.description ?? '',
    );
    final leaderNameController = TextEditingController(
      text: ministry?.leaderName ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(ministry == null ? 'Add Ministry' : 'Edit Ministry'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ministry name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: leaderNameController,
                  decoration: const InputDecoration(labelText: 'Leader name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
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
                final updated = Ministry(
                  id: ministry?.id ?? '',
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  leaderName: leaderNameController.text.trim(),
                  leaderId: ministry?.leaderId ?? '',
                  memberIds: ministry?.memberIds ?? const [],
                  isActive: ministry?.isActive ?? true,
                );

                if (ministry == null) {
                  await ref.read(ministryServiceProvider).addMinistry(updated);
                } else {
                  await ref
                      .read(ministryServiceProvider)
                      .updateMinistry(updated);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      descriptionController.dispose();
      leaderNameController.dispose();
    });
  }
}
