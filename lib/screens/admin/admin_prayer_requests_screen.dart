import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/prayer/providers/prayer_providers.dart';
import '../../models/prayer_request.dart';

class AdminPrayerRequestsScreen extends ConsumerWidget {
  const AdminPrayerRequestsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(
      adminPrayerRequestsByChurchProvider(churchId),
    );

    return Material(
      child: ChurchSnapScreen(
        title: 'Prayer Requests',
        subtitle: 'Review public and private prayer requests.',
        children: [
          requestsAsync.when(
            loading: () => const AppCard(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => AppCard(
              child: ListTile(
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text('Unable to load prayer requests'),
                subtitle: Text('$error'),
              ),
            ),
            data: (requests) {
              if (requests.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.favorite_outline_rounded),
                    title: Text('No prayer requests yet'),
                    subtitle: Text('Submitted requests will appear here.'),
                  ),
                );
              }

              return Column(
                children: requests.map((request) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Icon(
                          request.isPrivate
                              ? Icons.lock_rounded
                              : Icons.favorite_rounded,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.isPrivate
                                  ? 'Private Request'
                                  : request.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              request.published ? 'Published' : 'Hidden',
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${request.request}\n'
                        '${_formatDate(request.createdAt)}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'publish') {
                            _togglePublished(context, ref, request);
                            return;
                          }

                          if (value == 'delete') {
                            _confirmDelete(context, ref, request);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem<String>(
                            value: 'publish',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                request.published
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                              title: Text(
                                request.published
                                    ? 'Hide from Prayer Wall'
                                    : 'Publish to Prayer Wall',
                              ),
                            ),
                          ),
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

  Future<void> _togglePublished(
    BuildContext context,
    WidgetRef ref,
    PrayerRequest request,
  ) async {
    try {
      await ref
          .read(prayerServiceByChurchProvider(churchId))
          .setPublished(prayerId: request.id, published: !request.published);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            request.published
                ? 'Prayer request hidden.'
                : 'Prayer request published.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update prayer request: $error')),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PrayerRequest request,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Prayer Request'),
          content: const Text('Delete this prayer request permanently?'),
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

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(prayerServiceByChurchProvider(churchId))
          .deletePrayerRequest(request.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Prayer request deleted.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete prayer request: $error')),
      );
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

    return '${date.month}/${date.day}/${date.year}';
  }
}
