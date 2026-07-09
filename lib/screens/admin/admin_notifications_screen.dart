import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/app_roles.dart';
import '../../core/widgets/churchsnap_screen.dart';
import '../../features/notifications/models/app_notification.dart';
import '../../features/notifications/providers/notification_providers.dart';

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(notificationServiceProvider);

    return ChurchSnapScreen(
      title: 'Notifications',
      subtitle: 'Send church-wide updates and reminders.',
      children: [
        FilledButton.icon(
          onPressed: () => _showNotificationDialog(context, ref),
          icon: const Icon(Icons.add_alert_rounded),
          label: const Text('Create Notification'),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<AppNotification>>(
          stream: service.watchNotifications(),
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (notifications.isEmpty) {
              return const AppCard(
                child: Text('No notifications created yet.'),
              );
            }

            return Column(
              children: notifications.map((notification) {
                return AppCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.notifications_rounded),
                    ),
                    title: Text(notification.title),
                    subtitle: Text(
                      '${notification.body}\nTarget: ${notification.targetRole}',
                    ),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(notification.sent ? 'Sent' : 'Draft'),
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

  void _showNotificationDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    var targetRole = 'all';
    var type = 'announcement';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Notification'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Message'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: targetRole,
                      decoration: const InputDecoration(labelText: 'Audience'),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(
                          value: AppRoles.member,
                          child: Text('Members'),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.volunteer,
                          child: Text('Volunteers'),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.ministryLeader,
                          child: Text('Ministry Leaders'),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.groupLeader,
                          child: Text('Group Leaders'),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.admin,
                          child: Text('Admins'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => targetRole = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const [
                        DropdownMenuItem(
                          value: 'announcement',
                          child: Text('Announcement'),
                        ),
                        DropdownMenuItem(value: 'event', child: Text('Event')),
                        DropdownMenuItem(
                          value: 'prayer',
                          child: Text('Prayer'),
                        ),
                        DropdownMenuItem(
                          value: 'volunteer',
                          child: Text('Volunteer'),
                        ),
                        DropdownMenuItem(value: 'media', child: Text('Media')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => type = value);
                        }
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
                    final body = bodyController.text.trim();

                    if (title.isEmpty || body.isEmpty) return;

                    await ref
                        .read(notificationServiceProvider)
                        .sendNotification(
                          AppNotification(
                            title: title,
                            body: body,
                            type: type,
                            targetRole: targetRole,
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
      bodyController.dispose();
    });
  }
}
