import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/check_in/models/check_in_record.dart';
import '../../features/check_in/providers/check_in_providers.dart';
import '../../features/events/providers/event_providers.dart';
import '../../models/church_event.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key, this.authController});

  final AuthController? authController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = authController?.currentUser;

    final rawChurchId = currentUser?.churchId.trim() ?? '';

    final churchId = rawChurchId.isEmpty ? 'demo-church' : rawChurchId;

    final userId = currentUser?.id.trim() ?? '';

    final eventsAsync = ref.watch(publishedEventsByChurchProvider(churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Events',
        subtitle: 'RSVP and stay connected with church life.',
        children: [
          const SectionTitle(title: 'Upcoming'),
          eventsAsync.when(
            loading: () => const AppCard(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => AppCard(
              child: ListTile(
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text('Unable to load events'),
                subtitle: Text('$error'),
              ),
            ),
            data: (events) {
              if (events.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.event_available_rounded),
                    title: Text('No upcoming events'),
                    subtitle: Text('New church events will appear here.'),
                  ),
                );
              }

              return Column(
                children: events.map((event) {
                  final isGoing = event.attendeeIds.contains(userId);

                  return _EventCard(
                    event: event,
                    isGoing: isGoing,
                    canRespond: userId.isNotEmpty,
                    onRsvp: () => _toggleRsvp(
                      context,
                      ref,
                      churchId: churchId,
                      userId: userId,
                      event: event,
                      isGoing: isGoing,
                    ),
                    onCheckIn: () => _checkIn(
                      context,
                      ref,
                      churchId: churchId,
                      userId: userId,
                      displayName:
                          currentUser?.displayName ?? 'ChurchSnap Member',
                      event: event,
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

  Future<void> _toggleRsvp(
    BuildContext context,
    WidgetRef ref, {
    required String churchId,
    required String userId,
    required ChurchEvent event,
    required bool isGoing,
  }) async {
    if (userId.isEmpty) {
      return;
    }

    try {
      final service = ref.read(eventServiceByChurchProvider(churchId));

      if (isGoing) {
        await service.cancelRsvp(eventId: event.id, userId: userId);
      } else {
        await service.rsvp(eventId: event.id, userId: userId);
      }

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isGoing ? 'RSVP removed.' : 'RSVP confirmed.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('RSVP failed: $error')));
    }
  }

  Future<void> _checkIn(
    BuildContext context,
    WidgetRef ref, {
    required String churchId,
    required String userId,
    required String displayName,
    required ChurchEvent event,
  }) async {
    if (userId.isEmpty) {
      return;
    }

    try {
      await ref
          .read(checkInServiceByChurchProvider(churchId))
          .checkIn(
            CheckInRecord(
              eventId: event.id,
              userId: userId,
              displayName: displayName,
            ),
          );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Checked in successfully.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Check-in failed: $error')));
    }
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.isGoing,
    required this.canRespond,
    required this.onRsvp,
    required this.onCheckIn,
  });

  final ChurchEvent event;
  final bool isGoing;
  final bool canRespond;
  final VoidCallback onRsvp;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(event.icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event.when}\n'
                        '${event.location}\n'
                        '${event.rsvpCount} going',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: canRespond ? onRsvp : null,
                    icon: Icon(
                      isGoing ? Icons.check_rounded : Icons.add_rounded,
                    ),
                    label: Text(isGoing ? 'Going' : 'RSVP'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: canRespond ? onCheckIn : null,
                    icon: const Icon(Icons.how_to_reg_rounded),
                    label: const Text('Check In'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
