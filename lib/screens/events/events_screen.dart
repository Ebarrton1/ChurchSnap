import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/check_in/models/check_in_record.dart';
import '../../features/check_in/providers/check_in_providers.dart';
import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/events/providers/event_providers.dart';
import '../../features/events/repositories/event_repository.dart';
import '../../models/church_event.dart';

class EventsScreen extends ConsumerWidget {
  final AuthController? authController;

  const EventsScreen({super.key, this.authController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId =
        authController?.currentUser?.churchId.trim().isNotEmpty == true
        ? authController!.currentUser!.churchId.trim()
        : 'demo-church';
    final repository = EventRepository(churchId: churchId);
    final userId = authController?.currentUser?.id ?? 'guest';

    return ChurchSnapScreen(
      title: 'Events',
      subtitle: 'RSVP and stay connected with church life. Church: $churchId',
      children: [
        const SectionTitle(title: 'Upcoming'),
        StreamBuilder<List<ChurchEvent>>(
          stream: repository.watchPublishedEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return AppCard(
                child: Text('Unable to load events: ${snapshot.error}'),
              );
            }

            final events = snapshot.data ?? <ChurchEvent>[];

            if (events.isEmpty) {
              return AppCard(
                child: Text('No upcoming events found for church: $churchId'),
              );
            }

            return Column(
              children: events.map((event) {
                final isGoing = event.attendeeIds.contains(userId);

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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${event.when}\n${event.location}\n${event.rsvpCount} going',
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
                                onPressed: () async {
                                  final service = ref.read(
                                    eventServiceByChurchProvider(churchId),
                                  );

                                  try {
                                    if (isGoing) {
                                      await service.cancelRsvp(
                                        eventId: event.id,
                                        userId: userId,
                                      );
                                    } else {
                                      await service.rsvp(
                                        eventId: event.id,
                                        userId: userId,
                                      );
                                    }

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isGoing
                                              ? 'RSVP removed.'
                                              : 'RSVP confirmed.',
                                        ),
                                      ),
                                    );
                                  } catch (error) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('RSVP failed: $error'),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  isGoing
                                      ? Icons.check_rounded
                                      : Icons.add_rounded,
                                ),
                                label: Text(isGoing ? 'Going' : 'RSVP'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(
                                          checkInServiceByChurchProvider(
                                            churchId,
                                          ),
                                        )
                                        .checkIn(
                                          CheckInRecord(
                                            eventId: event.id,
                                            userId: userId,
                                            displayName:
                                                authController
                                                    ?.currentUser
                                                    ?.displayName ??
                                                'Guest',
                                          ),
                                        );

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Checked in successfully.',
                                        ),
                                      ),
                                    );
                                  } catch (error) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Check-in failed: $error',
                                        ),
                                      ),
                                    );
                                  }
                                },
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
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
