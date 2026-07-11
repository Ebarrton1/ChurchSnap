import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/churchsnap_screen.dart';
import '../../features/sermons/providers/sermon_providers.dart';
import '../../models/sermon.dart';

class AdminSermonsScreen extends ConsumerWidget {
  const AdminSermonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonsAsync = ref.watch(adminSermonsProvider);

    return ChurchSnapScreen(
      title: 'Manage Sermons',
      subtitle: 'Publish and organize church sermons.',
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _showSermonDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Sermon'),
          ),
        ),
        const SizedBox(height: 16),
        sermonsAsync.when(
          loading: () =>
              const AppCard(child: Center(child: CircularProgressIndicator())),
          error: (error, _) => AppCard(
            child: ListTile(
              leading: const Icon(Icons.error_outline_rounded),
              title: const Text('Unable to load sermons'),
              subtitle: Text('$error'),
            ),
          ),
          data: (sermons) {
            if (sermons.isEmpty) {
              return const AppCard(
                child: ListTile(
                  leading: Icon(Icons.play_circle_outline_rounded),
                  title: Text('No sermons have been added'),
                  subtitle: Text(
                    'Use the Add Sermon button to publish your first message.',
                  ),
                ),
              );
            }
            return Column(
              children: sermons.map((sermon) {
                final details = [
                  if (sermon.speaker.isNotEmpty) sermon.speaker,
                  if (sermon.scripture.isNotEmpty) sermon.scripture,
                  if (sermon.duration.isNotEmpty) sermon.duration,
                ].join(' • ');

                return AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Icon(
                        sermon.featured ? Icons.star_rounded : sermon.icon,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            sermon.title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (sermon.featured)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Chip(label: Text('Featured')),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (details.isNotEmpty) Text(details),
                        const SizedBox(height: 4),
                        Text(
                          sermon.published ? 'Published' : 'Draft',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: sermon.published
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            _showSermonDialog(context, ref, sermon: sermon);
                            break;
                          case 'publish':
                            await _togglePublished(context, ref, sermon);
                            break;
                          case 'feature':
                            await _setFeatured(context, ref, sermon);
                            break;
                          case 'delete':
                            await _confirmDelete(context, ref, sermon);
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_rounded),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'publish',
                          child: ListTile(
                            leading: Icon(
                              sermon.published
                                  ? Icons.visibility_off_rounded
                                  : Icons.publish_rounded,
                            ),
                            title: Text(
                              sermon.published ? 'Unpublish' : 'Publish',
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (!sermon.featured)
                          const PopupMenuItem<String>(
                            value: 'feature',
                            child: ListTile(
                              leading: Icon(Icons.star_rounded),
                              title: Text('Set Featured'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline_rounded),
                            title: Text('Delete'),
                            contentPadding: EdgeInsets.zero,
                          ),
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

  void _showSermonDialog(
    BuildContext context,
    WidgetRef ref, {
    Sermon? sermon,
  }) {
    final titleController = TextEditingController(text: sermon?.title ?? '');
    final speakerController = TextEditingController(
      text: sermon?.speaker ?? '',
    );
    final scriptureController = TextEditingController(
      text: sermon?.scripture ?? '',
    );
    final durationController = TextEditingController(
      text: sermon?.duration ?? '',
    );
    final descriptionController = TextEditingController(
      text: sermon?.description ?? '',
    );
    final videoUrlController = TextEditingController(
      text: sermon?.videoUrl ?? '',
    );
    final audioUrlController = TextEditingController(
      text: sermon?.audioUrl ?? '',
    );
    final notesUrlController = TextEditingController(
      text: sermon?.notesUrl ?? '',
    );
    final thumbnailUrlController = TextEditingController(
      text: sermon?.thumbnailUrl ?? '',
    );

    var sermonDate = sermon?.sermonDate ?? DateTime.now();
    var published = sermon?.published ?? true;
    var featured = sermon?.featured ?? false;
    var isSaving = false;
    String? validationMessage;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(sermon == null ? 'Add Sermon' : 'Edit Sermon'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title *'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: speakerController,
                        decoration: const InputDecoration(labelText: 'Speaker'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: scriptureController,
                        decoration: const InputDecoration(
                          labelText: 'Scripture',
                          hintText: 'Example: John 3:16',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                          hintText: 'Example: 42 min',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: videoUrlController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Video URL',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: audioUrlController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Audio URL',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesUrlController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Notes URL',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: thumbnailUrlController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Thumbnail URL',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month_rounded),
                        title: const Text('Sermon Date'),
                        subtitle: Text(_formatDate(sermonDate)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: isSaving
                            ? null
                            : () async {
                                final selectedDate = await showDatePicker(
                                  context: dialogContext,
                                  initialDate: sermonDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 3650),
                                  ),
                                );
                                if (selectedDate == null ||
                                    !dialogContext.mounted) {
                                  return;
                                }
                                setDialogState(() {
                                  sermonDate = selectedDate;
                                });
                              },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Published'),
                        subtitle: const Text(
                          'Published sermons are visible to members.',
                        ),
                        value: published,
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  published = value;
                                });
                              },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Featured'),
                        subtitle: const Text(
                          'Only one sermon can be featured at a time.',
                        ),
                        value: featured,
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  featured = value;
                                });
                              },
                      ),
                      if (validationMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          validationMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            setDialogState(() {
                              validationMessage = 'A sermon title is required.';
                            });
                            return;
                          }
                          setDialogState(() {
                            isSaving = true;
                            validationMessage = null;
                          });
                          try {
                            final service = ref.read(sermonServiceProvider);
                            final updatedSermon = Sermon(
                              id: sermon?.id ?? '',
                              title: title,
                              speaker: speakerController.text.trim(),
                              scripture: scriptureController.text.trim(),
                              duration: durationController.text.trim(),
                              description: descriptionController.text.trim(),
                              videoUrl: videoUrlController.text.trim(),
                              audioUrl: audioUrlController.text.trim(),
                              notesUrl: notesUrlController.text.trim(),
                              thumbnailUrl: thumbnailUrlController.text.trim(),
                              published: published,
                              featured: featured,
                              sermonDate: sermonDate,
                              createdAt: sermon?.createdAt ?? DateTime.now(),
                            );
                            String sermonId;
                            if (sermon == null) {
                              sermonId = await service.addSermon(updatedSermon);
                            } else {
                              sermonId = sermon.id;
                              await service.updateSermon(
                                sermon.id,
                                updatedSermon,
                              );
                            }
                            if (featured) {
                              await service.setFeatured(sermonId);
                            }
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  sermon == null
                                      ? 'Sermon added successfully.'
                                      : 'Sermon updated successfully.',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!dialogContext.mounted) return;
                            setDialogState(() {
                              isSaving = false;
                              validationMessage =
                                  'Unable to save sermon: $error';
                            });
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      speakerController.dispose();
      scriptureController.dispose();
      durationController.dispose();
      descriptionController.dispose();
      videoUrlController.dispose();
      audioUrlController.dispose();
      notesUrlController.dispose();
      thumbnailUrlController.dispose();
    });
  }

  Future<void> _togglePublished(
    BuildContext context,
    WidgetRef ref,
    Sermon sermon,
  ) async {
    try {
      await ref
          .read(sermonServiceProvider)
          .setPublished(sermonId: sermon.id, published: !sermon.published);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sermon.published ? 'Sermon unpublished.' : 'Sermon published.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Unable to update sermon: $error');
    }
  }

  Future<void> _setFeatured(
    BuildContext context,
    WidgetRef ref,
    Sermon sermon,
  ) async {
    try {
      await ref.read(sermonServiceProvider).setFeatured(sermon.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Featured sermon updated.')));
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Unable to feature sermon: $error');
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Sermon sermon,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Sermon'),
          content: Text(
            'Are you sure you want to delete "${sermon.title}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(sermonServiceProvider).deleteSermon(sermon.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sermon deleted.')));
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Unable to delete sermon: $error');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
