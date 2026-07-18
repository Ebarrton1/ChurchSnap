import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/sermons/providers/sermon_providers.dart';
import '../../models/sermon.dart';

class AdminSermonsScreen extends ConsumerWidget {
  const AdminSermonsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonsAsync = ref.watch(adminSermonsByChurchProvider(churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Manage Sermons',
        subtitle: 'Publish and organize church sermons.',
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openSermonDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Sermon'),
            ),
          ),
          const SizedBox(height: 16),
          sermonsAsync.when(
            loading: () => const AppCard(
              child: Center(child: CircularProgressIndicator()),
            ),
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
                      'Use Add Sermon to publish your first message.',
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
                          sermon.featured
                              ? Icons.star_rounded
                              : Icons.play_circle_rounded,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              sermon.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
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
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openSermonDialog(context, sermon: sermon);
                            return;
                          }

                          if (value == 'publish') {
                            _togglePublished(context, ref, sermon);
                            return;
                          }

                          if (value == 'feature') {
                            _setFeatured(context, ref, sermon);
                            return;
                          }

                          if (value == 'delete') {
                            _confirmDelete(context, ref, sermon);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.edit_rounded),
                              title: Text('Edit'),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'publish',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                sermon.published
                                    ? Icons.visibility_off_rounded
                                    : Icons.publish_rounded,
                              ),
                              title: Text(
                                sermon.published ? 'Unpublish' : 'Publish',
                              ),
                            ),
                          ),
                          if (!sermon.featured)
                            const PopupMenuItem<String>(
                              value: 'feature',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.star_rounded),
                                title: Text('Set Featured'),
                              ),
                            ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.delete_outline_rounded),
                              title: Text('Delete'),
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
      ),
    );
  }

  Future<void> _openSermonDialog(BuildContext context, {Sermon? sermon}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _SermonDialog(churchId: churchId, sermon: sermon),
    );

    if (saved != true || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sermon == null
              ? 'Sermon added successfully.'
              : 'Sermon updated successfully.',
        ),
      ),
    );
  }

  Future<void> _togglePublished(
    BuildContext context,
    WidgetRef ref,
    Sermon sermon,
  ) async {
    try {
      await ref
          .read(sermonServiceByChurchProvider(churchId))
          .setPublished(sermonId: sermon.id, published: !sermon.published);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sermon.published ? 'Sermon unpublished.' : 'Sermon published.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      _showError(context, 'Unable to update sermon: $error');
    }
  }

  Future<void> _setFeatured(
    BuildContext context,
    WidgetRef ref,
    Sermon sermon,
  ) async {
    try {
      await ref
          .read(sermonServiceByChurchProvider(churchId))
          .setFeatured(sermon.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Featured sermon updated.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

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
            'Delete "${sermon.title}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: true,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(sermonServiceByChurchProvider(churchId))
          .deleteSermon(sermon.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sermon deleted.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      _showError(context, 'Unable to delete sermon: $error');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SermonDialog extends ConsumerStatefulWidget {
  const _SermonDialog({required this.churchId, this.sermon});

  final String churchId;
  final Sermon? sermon;

  @override
  ConsumerState<_SermonDialog> createState() => _SermonDialogState();
}

class _SermonDialogState extends ConsumerState<_SermonDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _speakerController;
  late final TextEditingController _scriptureController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _audioUrlController;
  late final TextEditingController _notesUrlController;
  late final TextEditingController _thumbnailUrlController;

  late DateTime _sermonDate;
  late bool _published;
  late bool _featured;

  bool _saving = false;
  String? _errorMessage;

  bool get _isEditing => widget.sermon != null;

  @override
  void initState() {
    super.initState();

    final sermon = widget.sermon;

    _titleController = TextEditingController(text: sermon?.title ?? '');
    _speakerController = TextEditingController(text: sermon?.speaker ?? '');
    _scriptureController = TextEditingController(text: sermon?.scripture ?? '');
    _durationController = TextEditingController(text: sermon?.duration ?? '');
    _descriptionController = TextEditingController(
      text: sermon?.description ?? '',
    );
    _videoUrlController = TextEditingController(text: sermon?.videoUrl ?? '');
    _audioUrlController = TextEditingController(text: sermon?.audioUrl ?? '');
    _notesUrlController = TextEditingController(text: sermon?.notesUrl ?? '');
    _thumbnailUrlController = TextEditingController(
      text: sermon?.thumbnailUrl ?? '',
    );

    _sermonDate = sermon?.sermonDate ?? DateTime.now();
    _published = sermon?.published ?? true;
    _featured = sermon?.featured ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _speakerController.dispose();
    _scriptureController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _audioUrlController.dispose();
    _notesUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Sermon' : 'Add Sermon'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Title *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _speakerController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Speaker'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _scriptureController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Scripture',
                  hintText: 'Example: John 3:16',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _durationController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  hintText: 'Example: 42 min',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                enabled: !_saving,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _videoUrlController,
                enabled: !_saving,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Video URL'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _audioUrlController,
                enabled: !_saving,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Audio URL'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesUrlController,
                enabled: !_saving,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Notes URL'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _thumbnailUrlController,
                enabled: !_saving,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Thumbnail URL'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_rounded),
                title: const Text('Sermon Date'),
                subtitle: Text(
                  '${_sermonDate.month}/'
                  '${_sermonDate.day}/'
                  '${_sermonDate.year}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _saving ? null : _chooseDate,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Published'),
                subtitle: const Text(
                  'Published sermons are visible to members.',
                ),
                value: _published,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _published = value;
                        });
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Featured'),
                subtitle: const Text(
                  'Only one sermon can be featured at a time.',
                ),
                value: _featured,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _featured = value;
                        });
                      },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
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
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _chooseDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _sermonDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _sermonDate = selectedDate;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'A sermon title is required.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(sermonServiceByChurchProvider(widget.churchId));

      final existingSermon = widget.sermon;

      final updatedSermon = Sermon(
        id: existingSermon?.id ?? '',
        title: title,
        speaker: _speakerController.text.trim(),
        scripture: _scriptureController.text.trim(),
        duration: _durationController.text.trim(),
        description: _descriptionController.text.trim(),
        videoUrl: _videoUrlController.text.trim(),
        audioUrl: _audioUrlController.text.trim(),
        notesUrl: _notesUrlController.text.trim(),
        thumbnailUrl: _thumbnailUrlController.text.trim(),
        published: _published,
        featured: _featured,
        sermonDate: _sermonDate,
        createdAt: existingSermon?.createdAt ?? DateTime.now(),
      );

      late final String sermonId;

      if (existingSermon == null) {
        sermonId = await service.addSermon(updatedSermon);
      } else {
        sermonId = existingSermon.id;

        await service.updateSermon(existingSermon.id, updatedSermon);
      }

      if (_featured) {
        await service.setFeatured(sermonId);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _errorMessage = 'Unable to save sermon: $error';
      });
    }
  }
}
