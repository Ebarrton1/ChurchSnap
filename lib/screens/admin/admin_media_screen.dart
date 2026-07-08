import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/media/models/media_item.dart';
import '../../features/media/providers/media_providers.dart';

class AdminMediaScreen extends ConsumerWidget {
  const AdminMediaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaService = ref.read(mediaServiceProvider);

    return ChurchSnapScreen(
      title: 'Media Library',
      subtitle: 'Manage videos, podcasts, documents and more.',
      children: [
        FilledButton.icon(
          onPressed: () => _showAddMediaDialog(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Media'),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<MediaItem>>(
          stream: mediaService.watchMedia(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return AppCard(child: Text('Error: ${snapshot.error}'));
            }

            final media = snapshot.data ?? [];

            if (media.isEmpty) {
              return const AppCard(child: Text('No media uploaded yet.'));
            }

            return Column(
              children: media.map((item) {
                return AppCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.video_library_rounded),
                    ),
                    title: Text(item.title),
                    subtitle: Text('${item.mediaType} • ${item.category}'),
                    trailing: Chip(
                      label: Text(item.published ? 'Published' : 'Draft'),
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

  void _showAddMediaDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final speakerController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Media'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: speakerController,
                decoration: const InputDecoration(labelText: 'Speaker'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(mediaServiceProvider)
                    .addMedia(
                      MediaItem(
                        title: titleController.text.trim(),
                        speaker: speakerController.text.trim(),
                      ),
                    );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
