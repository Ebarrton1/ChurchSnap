import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final repository = EventRepository();
    final userId = authController?.currentUser?.id ?? 'guest';

    return ChurchSnapScreen(
      title: 'Events',
      subtitle: 'RSVP and stay connected with church life.',
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
              return const AppCard(child: Text('Unable to load events.'));
            }

            final events = snapshot.data ?? <ChurchEvent>[];

            if (events.isEmpty) {
              return const AppCard(child: Text('No upcoming events yet.'));
            }

            return Column(
              children: events.map((event) {
                final isGoing = event.attendeeIds.contains(userId);

                return AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Icon(event.icon)),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${event.when}\n${event.location}\n${event.rsvpCount} going',
                    ),
                    isThreeLine: true,
                    trailing: FilledButton.tonalIcon(
                      onPressed: () {
                        final service = ref.read(eventServiceProvider);

                        if (isGoing) {
                          service.cancelRsvp(eventId: event.id, userId: userId);
                        } else {
                          service.rsvp(eventId: event.id, userId: userId);
                        }
                      },
                      icon: Icon(
                        isGoing ? Icons.check_rounded : Icons.add_rounded,
                      ),
                      label: Text(isGoing ? 'Going' : 'RSVP'),
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
