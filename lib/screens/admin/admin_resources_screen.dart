import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/resources/models/church_resource.dart';
import '../../features/resources/providers/church_resource_providers.dart';
import '../../features/resources/repositories/church_resource_repository.dart';
import '../resources/pdf_resource_viewer_screen.dart';

class AdminResourcesScreen extends ConsumerStatefulWidget {
  const AdminResourcesScreen({super.key, required this.churchId});

  final String churchId;

  @override
  ConsumerState<AdminResourcesScreen> createState() =>
      _AdminResourcesScreenState();
}

class _AdminResourcesScreenState extends ConsumerState<AdminResourcesScreen> {
  String? _busyMessage;

  bool get _busy => _busyMessage != null;

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(
      adminChurchResourcesByChurchProvider(widget.churchId),
    );

    return Material(
      child: Stack(
        children: [
          ChurchSnapScreen(
            title: 'Manage Resources',
            subtitle: 'Upload books, lessons, study guides, and useful links.',
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resource Library',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Files may be up to 25 MB. PDF is recommended for books '
                      'and lesson material.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: _busy ? null : _chooseAndUploadFile,
                          icon: const Icon(Icons.upload_file_rounded),
                          label: const Text('Upload File'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _addExternalLink,
                          icon: const Icon(Icons.add_link_rounded),
                          label: const Text('Add Link'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SectionTitle(title: 'Published and Draft Resources'),
              resourcesAsync.when(
                loading: () => const AppCard(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, _) => AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load resources'),
                    subtitle: Text('$error'),
                  ),
                ),
                data: (resources) {
                  if (resources.isEmpty) {
                    return const AppCard(
                      child: ListTile(
                        leading: Icon(Icons.library_add_outlined),
                        title: Text('No resources uploaded yet'),
                        subtitle: Text(
                          'Use Upload File or Add Link to create the library.',
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: resources.map((resource) {
                      return _AdminResourceCard(
                        resource: resource,
                        onOpen: () => _openResource(resource),
                        onTogglePublished: () => _togglePublished(resource),
                        onDelete: () => _confirmDelete(resource),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          if (_busy)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(_busyMessage ?? 'Working...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _chooseAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'epub',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'txt',
        'jpg',
        'jpeg',
        'png',
      ],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final selectedFile = result.files.single;

    if (selectedFile.size > ChurchResourceRepository.maxUploadBytes) {
      _showMessage('The selected file is larger than 25 MB.');
      return;
    }

    final bytes = selectedFile.bytes;

    if (bytes == null || bytes.isEmpty) {
      _showMessage('ChurchSnap could not read the selected file.');
      return;
    }

    final draft = await _showResourceDialog(
      suggestedTitle: _titleFromFileName(selectedFile.name),
      fileName: selectedFile.name,
    );

    if (draft == null || !mounted) {
      return;
    }

    await _runBusy(
      'Uploading ${selectedFile.name}...',
      () {
        return ref
            .read(churchResourceRepositoryByChurchProvider(widget.churchId))
            .uploadResource(
              title: draft.title,
              description: draft.description,
              category: draft.category,
              bytes: Uint8List.fromList(bytes),
              fileName: selectedFile.name,
              contentType: _contentTypeForFile(selectedFile.name),
              published: draft.published,
            );
      },
      successMessage: 'Resource uploaded successfully.',
    );
  }

  Future<void> _addExternalLink() async {
    final draft = await _showResourceDialog(linkMode: true);

    if (draft == null || !mounted) {
      return;
    }

    await _runBusy(
      'Saving resource link...',
      () {
        return ref
            .read(churchResourceRepositoryByChurchProvider(widget.churchId))
            .addLinkResource(
              title: draft.title,
              description: draft.description,
              category: draft.category,
              externalUrl: draft.externalUrl,
              published: draft.published,
            );
      },
      successMessage: 'Resource link added successfully.',
    );
  }

  Future<_ResourceDraft?> _showResourceDialog({
    String suggestedTitle = '',
    String fileName = '',
    bool linkMode = false,
  }) {
    var title = suggestedTitle;
    var description = '';
    var externalUrl = '';
    var category = ChurchResourceCategory.other;
    var published = true;
    String? validationMessage;

    return showDialog<_ResourceDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submit() {
              final cleanTitle = title.trim();

              if (cleanTitle.isEmpty) {
                setDialogState(() {
                  validationMessage = 'Enter a resource title.';
                });
                return;
              }

              final cleanExternalUrl = externalUrl.trim();

              if (linkMode) {
                final uri = Uri.tryParse(cleanExternalUrl);

                if (uri == null ||
                    !uri.hasScheme ||
                    (uri.scheme != 'https' && uri.scheme != 'http')) {
                  setDialogState(() {
                    validationMessage = 'Enter a complete http or https link.';
                  });
                  return;
                }
              }

              Navigator.pop(
                dialogContext,
                _ResourceDraft(
                  title: cleanTitle,
                  description: description.trim(),
                  category: category,
                  published: published,
                  externalUrl: cleanExternalUrl,
                ),
              );
            }

            return AlertDialog(
              title: Text(linkMode ? 'Add Resource Link' : 'Upload Resource'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 460,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (fileName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.description_rounded),
                            title: Text(fileName),
                            subtitle: const Text('Selected file'),
                          ),
                        ),
                      TextFormField(
                        initialValue: suggestedTitle,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Resource title',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          title = value;

                          if (validationMessage != null) {
                            setDialogState(() {
                              validationMessage = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          description = value;
                        },
                      ),
                      if (linkMode) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'https:// resource link',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            externalUrl = value;

                            if (validationMessage != null) {
                              setDialogState(() {
                                validationMessage = null;
                              });
                            }
                          },
                          onFieldSubmitted: (_) => submit(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ChurchResourceCategory>(
                        initialValue: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: ChurchResourceCategory.values.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            category = value;
                          });
                        },
                      ),
                      const SizedBox(height: 6),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Publish immediately'),
                        subtitle: Text(
                          published
                              ? 'Members can see this resource.'
                              : 'Keep this resource as an admin draft.',
                        ),
                        value: published,
                        onChanged: (value) {
                          setDialogState(() {
                            published = value;
                          });
                        },
                      ),
                      if (validationMessage != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            validationMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: submit,
                  child: Text(linkMode ? 'Add Link' : 'Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _togglePublished(ChurchResource resource) async {
    await _runBusy(
      resource.published
          ? 'Unpublishing resource...'
          : 'Publishing resource...',
      () {
        return ref
            .read(churchResourceRepositoryByChurchProvider(widget.churchId))
            .setPublished(
              resourceId: resource.id,
              published: !resource.published,
            );
      },
      successMessage: resource.published
          ? 'Resource moved to drafts.'
          : 'Resource published.',
    );
  }

  Future<void> _confirmDelete(ChurchResource resource) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Resource'),
          content: Text(
            'Delete "${resource.title}"? Uploaded files will also be removed '
            'from Firebase Storage.',
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

    if (confirmed != true || !mounted) {
      return;
    }

    await _runBusy('Deleting resource...', () {
      return ref
          .read(churchResourceRepositoryByChurchProvider(widget.churchId))
          .deleteResource(resource);
    }, successMessage: 'Resource deleted.');
  }

  Future<void> _openResource(ChurchResource resource) async {
    final uri = Uri.tryParse(resource.openUrl);

    if (uri == null) {
      _showMessage('This resource does not have a valid link.');
      return;
    }

    if (resource.isPdf) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PdfResourceViewerScreen(resource: resource),
        ),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      _showMessage('No app was available to open this resource.');
    }
  }

  Future<void> _runBusy(
    String message,
    Future<Object?> Function() operation, {
    required String successMessage,
  }) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busyMessage = message;
    });

    try {
      await operation();

      if (mounted) {
        _showMessage(successMessage);
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Unable to complete the resource action: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _busyMessage = null;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _titleFromFileName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    final withoutExtension = dotIndex > 0
        ? fileName.substring(0, dotIndex)
        : fileName;

    return withoutExtension
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _contentTypeForFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    return switch (extension) {
      'pdf' => 'application/pdf',
      'epub' => 'application/epub+zip',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt' => 'application/vnd.ms-powerpoint',
      'pptx' =>
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt' => 'text/plain',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      _ => 'application/octet-stream',
    };
  }
}

class _AdminResourceCard extends StatelessWidget {
  const _AdminResourceCard({
    required this.resource,
    required this.onOpen,
    required this.onTogglePublished,
    required this.onDelete,
  });

  final ChurchResource resource;
  final VoidCallback onOpen;
  final VoidCallback onTogglePublished;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final details = [
      resource.category.label,
      resource.kind.label,
      if (resource.sizeLabel.isNotEmpty) resource.sizeLabel,
    ].join(' | ');

    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          child: Icon(
            resource.kind == ChurchResourceKind.link
                ? Icons.link_rounded
                : Icons.description_rounded,
          ),
        ),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          resource.description.isEmpty
              ? details
              : '${resource.description}\n$details',
        ),
        isThreeLine: resource.description.isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'open':
                onOpen();
              case 'publish':
                onTogglePublished();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (context) {
            return [
              if (resource.canOpen)
                const PopupMenuItem(value: 'open', child: Text('Open')),
              PopupMenuItem(
                value: 'publish',
                child: Text(resource.published ? 'Move to drafts' : 'Publish'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ];
          },
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ),
    );
  }
}

class _ResourceDraft {
  const _ResourceDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.published,
    this.externalUrl = '',
  });

  final String title;
  final String description;
  final ChurchResourceCategory category;
  final bool published;
  final String externalUrl;
}
