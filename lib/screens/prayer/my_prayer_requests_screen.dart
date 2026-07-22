import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../models/prayer_request.dart';

class MyPrayerRequestsScreen extends StatelessWidget {
  const MyPrayerRequestsScreen({
    super.key,
    required this.churchId,
    required this.userId,
  });

  final String churchId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final requests = FirebaseFirestore.instance
        .collection('churches')
        .doc(churchId)
        .collection('prayer_requests')
        .where('createdByUid', isEqualTo: userId)
        .snapshots();

    return Material(
      child: ChurchSnapScreen(
        title: 'My Prayer Requests',
        subtitle: 'Review the prayer requests you have submitted.',
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: requests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load your prayer requests'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final items =
                  (snapshot.data?.docs ?? const [])
                      .map(
                        (document) =>
                            PrayerRequest.fromMap(document.id, document.data()),
                      )
                      .toList()
                    ..sort((left, right) {
                      final leftDate =
                          left.createdAt ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      final rightDate =
                          right.createdAt ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      return rightDate.compareTo(leftDate);
                    });

              if (items.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.favorite_outline_rounded),
                    title: Text('No submitted prayer requests'),
                    subtitle: Text(
                      'Prayer requests you submit will appear here.',
                    ),
                  ),
                );
              }

              return Column(
                children: items
                    .map((request) {
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
                          title: Text(
                            request.request,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Chip(
                                  avatar: Icon(
                                    request.isPrivate
                                        ? Icons.lock_outline_rounded
                                        : Icons.public_rounded,
                                    size: 17,
                                  ),
                                  label: Text(
                                    request.isPrivate ? 'Private' : 'Public',
                                  ),
                                ),
                                Chip(
                                  avatar: Icon(
                                    request.published
                                        ? Icons.visibility_rounded
                                        : Icons.pending_rounded,
                                    size: 17,
                                  ),
                                  label: Text(
                                    request.published
                                        ? 'Visible'
                                        : 'Pastoral review',
                                  ),
                                ),
                                if (request.createdAt != null)
                                  Text(_formatDate(request.createdAt!)),
                              ],
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    })
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '${local.year}-$month-$day $hour:$minute';
  }
}
