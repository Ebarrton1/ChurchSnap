import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/notifications/models/member_notification.dart';
import '../../features/notifications/providers/member_notification_providers.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({
    super.key,
    required this.churchId,
    required this.memberId,
  });

  final String churchId;
  final String memberId;

  NotificationInboxScope get _scope => (churchId: churchId, memberId: memberId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(memberNotificationInboxProvider(_scope));

    return Material(
      child: ChurchSnapScreen(
        title: 'Notifications',
        subtitle: 'Church updates sent directly to your account.',
        children: [
          inboxAsync.when(
            loading: () => const AppCard(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text('Unable to load notifications'),
                subtitle: Text('$error'),
              ),
            ),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Icon(Icons.notifications_none_rounded),
                    ),
                    title: Text(
                      'No notifications yet',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      'New church notifications will appear here.',
                    ),
                  ),
                );
              }

              final unreadCount = notifications
                  .where((notification) => !notification.isRead)
                  .length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            unreadCount == 0
                                ? 'You are all caught up.'
                                : '$unreadCount unread '
                                      '${unreadCount == 1 ? 'notification' : 'notifications'}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: unreadCount == 0
                              ? null
                              : () => _markAllRead(context, ref, notifications),
                          icon: const Icon(Icons.done_all_rounded),
                          label: const Text('Mark all read'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...notifications.map(
                    (notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NotificationCard(
                        notification: notification,
                        onOpen: () =>
                            _openNotification(context, ref, notification),
                        onToggleRead: () =>
                            _toggleRead(context, ref, notification),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openNotification(
    BuildContext context,
    WidgetRef ref,
    MemberNotification notification,
  ) async {
    final service = ref.read(memberNotificationInboxServiceProvider(_scope));

    if (!notification.isRead) {
      try {
        await service.markRead(notification.id);
      } catch (error) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to mark notification read: $error')),
        );
      }
    }

    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(child: Icon(_iconForType(notification.type))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(sheetContext).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateTime(notification.createdAt),
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Text(
                  notification.body,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.bodyLarge?.copyWith(height: 1.55),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleRead(
    BuildContext context,
    WidgetRef ref,
    MemberNotification notification,
  ) async {
    final service = ref.read(memberNotificationInboxServiceProvider(_scope));

    try {
      if (notification.isRead) {
        await service.markUnread(notification.id);
      } else {
        await service.markRead(notification.id);
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update notification: $error')),
      );
    }
  }

  Future<void> _markAllRead(
    BuildContext context,
    WidgetRef ref,
    List<MemberNotification> notifications,
  ) async {
    try {
      await ref
          .read(memberNotificationInboxServiceProvider(_scope))
          .markAllRead(notifications);
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to mark notifications read: $error')),
      );
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onOpen,
    required this.onToggleRead,
  });

  final MemberNotification notification;
  final VoidCallback onOpen;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onOpen,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(child: Icon(_iconForType(notification.type))),
            if (!notification.isRead)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w700 : FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '${notification.body}\n${_formatDateTime(notification.createdAt)}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: notification.isRead ? 'Mark unread' : 'Mark read',
          onPressed: onToggleRead,
          icon: Icon(
            notification.isRead
                ? Icons.mark_email_unread_outlined
                : Icons.done_rounded,
          ),
        ),
      ),
    );
  }
}

IconData _iconForType(String type) {
  switch (type) {
    case 'event':
      return Icons.event_rounded;
    case 'prayer':
      return Icons.favorite_rounded;
    case 'volunteer':
      return Icons.volunteer_activism_rounded;
    case 'media':
      return Icons.play_circle_fill_rounded;
    default:
      return Icons.campaign_rounded;
  }
}

String _formatDateTime(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) {
    return 'Recently';
  }

  final local = value.toLocal();
  final hour = local.hour == 0
      ? 12
      : local.hour > 12
      ? local.hour - 12
      : local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';

  return '${local.month}/${local.day}/${local.year} '
      '$hour:$minute $period';
}
