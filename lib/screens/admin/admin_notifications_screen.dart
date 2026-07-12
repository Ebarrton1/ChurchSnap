import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/app_roles.dart';
import '../../core/widgets/churchsnap_screen.dart';
import '../../features/notifications/models/app_notification.dart';
import '../../features/notifications/providers/notification_providers.dart';

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(notificationServiceByChurchProvider(churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Notifications',
        subtitle: 'Send church-wide updates and reminders.',
        children: [
          FilledButton.icon(
            onPressed: () => _openNotificationDialog(context),
            icon: const Icon(Icons.add_alert_rounded),
            label: const Text('Create Notification'),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<AppNotification>>(
            stream: service.watchNotifications(),
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
                    title: const Text('Unable to load notifications'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final notifications = snapshot.data ?? <AppNotification>[];

              if (notifications.isEmpty) {
                return const AppCard(
                  child: Text('No notifications created yet.'),
                );
              }

              return Column(
                children: notifications.map((notification) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.notifications_rounded),
                      ),
                      title: Text(
                        notification.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${notification.body}\n'
                        'Target: ${notification.targetRole}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openNotificationDialog(
                              context,
                              notification: notification,
                            );
                            return;
                          }

                          if (value == 'delete') {
                            _deleteNotification(context, ref, notification);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.edit_rounded),
                              title: Text('Edit'),
                            ),
                          ),
                          PopupMenuItem(
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

  Future<void> _openNotificationDialog(
    BuildContext context, {
    AppNotification? notification,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _NotificationDialog(churchId: churchId, notification: notification),
    );

    if (saved != true || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notification == null
              ? 'Notification created.'
              : 'Notification updated.',
        ),
      ),
    );
  }

  Future<void> _deleteNotification(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    try {
      await ref
          .read(notificationServiceByChurchProvider(churchId))
          .deleteNotification(notification.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Notification deleted.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete notification: $error')),
      );
    }
  }
}

class _NotificationDialog extends ConsumerStatefulWidget {
  const _NotificationDialog({required this.churchId, this.notification});

  final String churchId;
  final AppNotification? notification;

  @override
  ConsumerState<_NotificationDialog> createState() =>
      _NotificationDialogState();
}

class _NotificationDialogState extends ConsumerState<_NotificationDialog> {
  late final TextEditingController _titleController;

  late final TextEditingController _bodyController;

  late String _targetRole;
  late String _type;

  bool _saving = false;
  String? _errorMessage;

  bool get _isEditing => widget.notification != null;

  @override
  void initState() {
    super.initState();

    final notification = widget.notification;

    _titleController = TextEditingController(text: notification?.title ?? '');

    _bodyController = TextEditingController(text: notification?.body ?? '');

    _targetRole = notification?.targetRole ?? 'all';
    _type = notification?.type ?? 'announcement';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Notification' : 'Create Notification'),
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
                controller: _bodyController,
                enabled: !_saving,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _targetRole,
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
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _targetRole = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'announcement',
                    child: Text('Announcement'),
                  ),
                  DropdownMenuItem(value: 'event', child: Text('Event')),
                  DropdownMenuItem(value: 'prayer', child: Text('Prayer')),
                  DropdownMenuItem(
                    value: 'volunteer',
                    child: Text('Volunteer'),
                  ),
                  DropdownMenuItem(value: 'media', child: Text('Media')),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _type = value;
                        });
                      },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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
              : Text(_isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      setState(() {
        _errorMessage = 'Enter both a title and a message.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(
        notificationServiceByChurchProvider(widget.churchId),
      );

      final existingNotification = widget.notification;

      if (existingNotification == null) {
        await service.sendNotification(
          AppNotification(
            title: title,
            body: body,
            type: _type,
            targetRole: _targetRole,
          ),
        );
      } else {
        await service.updateNotification(
          id: existingNotification.id,
          title: title,
          body: body,
          type: _type,
          targetRole: _targetRole,
        );
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
        _errorMessage = _isEditing
            ? 'Unable to update notification: $error'
            : 'Unable to create notification: $error';
      });
    }
  }
}
