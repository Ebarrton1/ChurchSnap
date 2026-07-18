import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/announcements/providers/announcement_providers.dart';
import '../../features/admin/providers/admin_providers.dart';
import '../../models/announcement.dart';

class AdminAnnouncementsListScreen extends ConsumerWidget {
  const AdminAnnouncementsListScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(
      announcementsByChurchProvider(churchId),
    );

    return ChurchSnapScreen(
      title: 'Announcements',
      subtitle: 'Manage published announcements for $churchId.',
      children: [
        announcementsAsync.when(
          loading: () =>
              const AppCard(child: Center(child: CircularProgressIndicator())),
          error: (_, _) =>
              const AppCard(child: Text('Unable to load announcements.')),
          data: (announcements) {
            if (announcements.isEmpty) {
              return const AppCard(child: Text('No announcements yet.'));
            }

            return Column(
              children: announcements.map((announcement) {
                return AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.campaign_rounded),
                    ),
                    title: Text(
                      announcement.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${announcement.tag}\n${announcement.message}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, ref, announcement);
                        }

                        if (value == 'delete') {
                          _deleteAnnouncement(context, ref, announcement);
                        }
                      },
                      itemBuilder: (context) => const [
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

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Announcement announcement,
  ) {
    final titleController = TextEditingController(text: announcement.title);
    final messageController = TextEditingController(text: announcement.message);
    var tag = announcement.tag;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Announcement'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tag,
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(value: 'Events', child: Text('Events')),
                    DropdownMenuItem(value: 'Youth', child: Text('Youth')),
                    DropdownMenuItem(value: 'Prayer', child: Text('Prayer')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      tag = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  ChurchSnapNavigation.closeAllWindows(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final updated = Announcement(
                  id: announcement.id,
                  title: titleController.text.trim(),
                  message: messageController.text.trim(),
                  tag: tag,
                  published: announcement.published,
                  createdAt: announcement.createdAt,
                );

                await ref
                    .read(adminAnnouncementServiceByChurchProvider(churchId))
                    .updateAnnouncement(announcement.id, updated);

                if (dialogContext.mounted) {
                  ChurchSnapNavigation.closeAllWindows(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      messageController.dispose();
    });
  }

  Future<void> _deleteAnnouncement(
    BuildContext context,
    WidgetRef ref,
    Announcement announcement,
  ) async {
    await ref
        .read(adminAnnouncementServiceByChurchProvider(churchId))
        .deleteAnnouncement(announcement.id);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Announcement deleted.')));
    }
  }
}
