import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/ministries/models/ministry.dart';
import '../../features/ministries/providers/ministry_providers.dart';

class AdminMinistriesScreen extends ConsumerWidget {
  const AdminMinistriesScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ministryService = ref.read(ministryServiceByChurchProvider(churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Ministries',
        subtitle: 'Manage church ministries and volunteer teams.',
        children: [
          FilledButton.icon(
            onPressed: () => _openMinistryDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Ministry'),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Ministry>>(
            stream: ministryService.watchMinistries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load ministries'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final ministries = snapshot.data ?? <Ministry>[];

              if (ministries.isEmpty) {
                return const AppCard(child: Text('No ministries yet.'));
              }

              return Column(
                children: ministries.map((ministry) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.groups_rounded),
                      ),
                      title: Text(
                        ministry.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${ministry.leaderName.isEmpty ? 'No leader assigned' : ministry.leaderName}\n'
                        '${ministry.memberIds.length} volunteers',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openMinistryDialog(
                              context,
                              ref,
                              ministry: ministry,
                            );
                          }

                          if (value == 'delete') {
                            _deleteMinistry(context, ref, ministry);
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
      ),
    );
  }

  Future<void> _openMinistryDialog(
    BuildContext context,
    WidgetRef ref, {
    Ministry? ministry,
  }) async {
    final updated = await showDialog<Ministry>(
      context: context,
      builder: (_) => _MinistryDialog(ministry: ministry),
    );

    if (updated == null || !context.mounted) {
      return;
    }

    try {
      final service = ref.read(ministryServiceByChurchProvider(churchId));

      if (ministry == null) {
        await service.addMinistry(updated);
      } else {
        await service.updateMinistry(updated);
      }

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ministry == null
                ? 'Ministry added successfully.'
                : 'Ministry updated successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save ministry: $error')),
      );
    }
  }

  Future<void> _deleteMinistry(
    BuildContext context,
    WidgetRef ref,
    Ministry ministry,
  ) async {
    try {
      await ref
          .read(ministryServiceByChurchProvider(churchId))
          .deleteMinistry(ministry.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete ministry: $error')),
      );
    }
  }
}

class _MinistryDialog extends StatefulWidget {
  const _MinistryDialog({this.ministry});

  final Ministry? ministry;

  @override
  State<_MinistryDialog> createState() => _MinistryDialogState();
}

class _MinistryDialogState extends State<_MinistryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _leaderNameController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.ministry?.name ?? '');

    _descriptionController = TextEditingController(
      text: widget.ministry?.description ?? '',
    );

    _leaderNameController = TextEditingController(
      text: widget.ministry?.leaderName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _leaderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ministry == null ? 'Add Ministry' : 'Edit Ministry'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ministry name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _leaderNameController,
                decoration: const InputDecoration(labelText: 'Leader name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();

            if (name.isEmpty) {
              return;
            }

            Navigator.of(context).pop(
              Ministry(
                id: widget.ministry?.id ?? '',
                name: name,
                description: _descriptionController.text.trim(),
                leaderName: _leaderNameController.text.trim(),
                leaderId: widget.ministry?.leaderId ?? '',
                memberIds: widget.ministry?.memberIds ?? const <String>[],
                isActive: widget.ministry?.isActive ?? true,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
