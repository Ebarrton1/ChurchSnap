import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/sermons/providers/sermon_providers.dart';

class AdminSermonsScreen extends ConsumerWidget {
  const AdminSermonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonsAsync = ref.watch(adminSermonsProvider);

    return ChurchSnapScreen(
      title: 'Manage Sermons',
      subtitle: 'Publish and organize church sermons.',
      children: [
        FilledButton.icon(
          onPressed: () {
            // The create-sermon dialog will be added next.
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Sermon'),
        ),
        const SizedBox(height: 16),
        sermonsAsync.when(
          loading: () =>
              const AppCard(child: Center(child: CircularProgressIndicator())),
          error: (_, _) =>
              const AppCard(child: Text('Unable to load sermons.')),
          data: (items) {
            if (items.isEmpty) {
              return const AppCard(
                child: Text('No published sermons are available.'),
              );
            }

            return Column(
              children: items.map((sermon) {
                final details = [
                  if (sermon.speaker.isNotEmpty) sermon.speaker,
                  if (sermon.scripture.isNotEmpty) sermon.scripture,
                ].join(' • ');

                return AppCard(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(sermon.icon)),
                    title: Text(
                      sermon.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: details.isEmpty ? null : Text(details),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            break;
                          case 'publish':
                            break;
                          case 'delete':
                            break;
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem<String>(
                          value: 'publish',
                          child: Text('Publish / Unpublish'),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
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
}
