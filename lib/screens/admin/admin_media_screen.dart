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
          onPressed: () => _showMediaDialog(context, ref),
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
                final icon = switch (item.mediaType.toLowerCase()) {
                  'audio' => Icons.podcasts_rounded,
                  'pdf' => Icons.picture_as_pdf_rounded,
                  'image' => Icons.image_rounded,
                  'livestream' => Icons.live_tv_rounded,
                  _ => Icons.video_library_rounded,
                };

                return AppCard(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(icon)),
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.mediaType} • ${item.category}\n${item.speaker.isEmpty ? 'No speaker' : item.speaker}',
                    ),
                    isThreeLine: true,
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

  void _showMediaDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final speakerController = TextEditingController();
    final descriptionController = TextEditingController();
    final mediaUrlController = TextEditingController();
    final thumbnailUrlController = TextEditingController();
    final durationController = TextEditingController();

    var mediaType = 'video';
    var category = 'Sermons';
    var published = true;
    var featured = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Media'),
              content: SingleChildScrollView(
                child: Column(
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: mediaType,
                      decoration: const InputDecoration(
                        labelText: 'Media Type',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'video', child: Text('Video')),
                        DropdownMenuItem(value: 'audio', child: Text('Audio')),
                        DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                        DropdownMenuItem(value: 'image', child: Text('Image')),
                        DropdownMenuItem(
                          value: 'livestream',
                          child: Text('Livestream'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => mediaType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Sermons',
                          child: Text('Sermons'),
                        ),
                        DropdownMenuItem(
                          value: 'Worship',
                          child: Text('Worship'),
                        ),
                        DropdownMenuItem(value: 'Youth', child: Text('Youth')),
                        DropdownMenuItem(
                          value: 'Bible Study',
                          child: Text('Bible Study'),
                        ),
                        DropdownMenuItem(
                          value: 'Documents',
                          child: Text('Documents'),
                        ),
                        DropdownMenuItem(
                          value: 'General',
                          child: Text('General'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => category = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mediaUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Media URL',
                        hintText: 'YouTube, Vimeo, podcast, PDF, image URL',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: thumbnailUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Thumbnail URL',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        hintText: '42 min',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Published'),
                      value: published,
                      onChanged: (value) {
                        setDialogState(() => published = value);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Featured'),
                      value: featured,
                      onChanged: (value) {
                        setDialogState(() => featured = value);
                      },
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
                    final title = titleController.text.trim();

                    if (title.isEmpty) return;

                    await ref
                        .read(mediaServiceProvider)
                        .addMedia(
                          MediaItem(
                            title: title,
                            speaker: speakerController.text.trim(),
                            description: descriptionController.text.trim(),
                            mediaType: mediaType,
                            category: category,
                            mediaUrl: mediaUrlController.text.trim(),
                            thumbnailUrl: thumbnailUrlController.text.trim(),
                            duration: durationController.text.trim(),
                            published: published,
                            featured: featured,
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
      },
    ).whenComplete(() {
      titleController.dispose();
      speakerController.dispose();
      descriptionController.dispose();
      mediaUrlController.dispose();
      thumbnailUrlController.dispose();
      durationController.dispose();
    });
  }
}
