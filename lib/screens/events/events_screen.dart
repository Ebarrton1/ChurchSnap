import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../models/church_event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final Set<String> rsvps = {};

  final events = const [
    ChurchEvent(
      title: 'Sabbath Worship',
      when: 'Saturday • 11:00 AM',
      location: 'Main Sanctuary',
      icon: Icons.wb_twilight_rounded,
    ),
    ChurchEvent(
      title: 'Sunday Worship',
      when: 'Sunday • 10:00 AM',
      location: 'Main Sanctuary',
      icon: Icons.church_rounded,
    ),
    ChurchEvent(
      title: 'Community Outreach',
      when: 'Saturday • 2:00 PM',
      location: 'Fellowship Hall',
      icon: Icons.handshake_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'Events',
      subtitle: 'RSVP and stay connected with church life.',
      children: [
        const SectionTitle(title: 'Upcoming'),
        ...events.map((event) {
          final going = rsvps.contains(event.title);
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
                      ? rsvps.remove(event.title)
                      : rsvps.add(event.title),
                ),
                icon: Icon(going ? Icons.check_rounded : Icons.add_rounded),
                label: Text(going ? 'Going' : 'RSVP'),
              ),
            ),
          );
        }),
      ],
    );
  }
}
