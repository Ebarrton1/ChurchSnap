import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/media/models/media_item.dart';
import '../../features/media/providers/media_providers.dart';

class AdminMediaScreen extends ConsumerWidget {
  const AdminMediaScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaService = ref.read(mediaServiceByChurchProvider(churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Media Library',
        subtitle: 'Manage media for $churchId.',
        children: [
          FilledButton.icon(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => _MediaDialog(churchId: churchId),
              );
            },
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
                return AppCard(
                  child: Text('Unable to load media: ${snapshot.error}'),
                );
              }

              final media = snapshot.data ?? <MediaItem>[];

              if (media.isEmpty) {
                return const AppCard(
                  child: Text('No published media uploaded yet.'),
                );
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
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Icon(icon)),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${item.mediaType} • ${item.category}\n'
                        '${item.speaker.isEmpty ? 'No speaker' : item.speaker}',
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
      ),
    );
  }
}

class _MediaDialog extends ConsumerStatefulWidget {
  const _MediaDialog({required this.churchId});

  final String churchId;

  @override
  ConsumerState<_MediaDialog> createState() => _MediaDialogState();
}

class _MediaDialogState extends ConsumerState<_MediaDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _speakerController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _mediaUrlController;
  late final TextEditingController _thumbnailUrlController;
  late final TextEditingController _durationController;

  String _mediaType = 'video';
  String _category = 'Sermons';
  bool _published = true;
  bool _featured = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _speakerController = TextEditingController();
    _descriptionController = TextEditingController();
    _mediaUrlController = TextEditingController();
    _thumbnailUrlController = TextEditingController();
    _durationController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _speakerController.dispose();
    _descriptionController.dispose();
    _mediaUrlController.dispose();
    _thumbnailUrlController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Media'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _speakerController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Speaker'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                enabled: !_saving,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _mediaType,
                decoration: const InputDecoration(labelText: 'Media Type'),
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
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _mediaType = value;
                          _errorMessage = null;
                        });
                      },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Sermons', child: Text('Sermons')),
                  DropdownMenuItem(value: 'Worship', child: Text('Worship')),
                  DropdownMenuItem(value: 'Youth', child: Text('Youth')),
                  DropdownMenuItem(
                    value: 'Bible Study',
                    child: Text('Bible Study'),
                  ),
                  DropdownMenuItem(
                    value: 'Documents',
                    child: Text('Documents'),
                  ),
                  DropdownMenuItem(value: 'General', child: Text('General')),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _category = value;
                          _errorMessage = null;
                        });
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mediaUrlController,
                enabled: !_saving,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Media URL',
                  hintText: 'YouTube, podcast, PDF or image URL',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _thumbnailUrlController,
                enabled: !_saving,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Thumbnail URL'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _durationController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  hintText: '42 min',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Published'),
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
                const SizedBox(height: 12),
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
          onPressed: _saving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _saveMedia,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text(_saving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _saveMedia() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a media title.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(mediaServiceByChurchProvider(widget.churchId));

      await service.addMedia(
        MediaItem(
          title: title,
          speaker: _speakerController.text.trim(),
          description: _descriptionController.text.trim(),
          mediaType: _mediaType,
          category: _category,
          mediaUrl: _mediaUrlController.text.trim(),
          thumbnailUrl: _thumbnailUrlController.text.trim(),
          duration: _durationController.text.trim(),
          published: _published,
          featured: _featured,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      debugPrint('Media saving failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _errorMessage = 'Unable to save media: $error';
      });
    }
  }
}
