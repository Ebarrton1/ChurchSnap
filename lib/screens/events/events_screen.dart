import 'package:flutter/material.dart';

import 'package:churchsnap/features/events/repositories/event_repository.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../models/church_event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final Set<String> rsvps = {};

  @override
  Widget build(BuildContext context) {
    final repository = EventRepository();

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
                final going = rsvps.contains(event.id);

                return AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Icon(event.icon)),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('${event.when}\n${event.location}'),
                    isThreeLine: true,
                    trailing: FilledButton.tonalIcon(
                      onPressed: () => setState(
                        () => going
                            ? rsvps.remove(event.id)
                            : rsvps.add(event.id),
                      ),
                      icon: Icon(
                        going ? Icons.check_rounded : Icons.add_rounded,
                      ),
                      label: Text(going ? 'Going' : 'RSVP'),
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
