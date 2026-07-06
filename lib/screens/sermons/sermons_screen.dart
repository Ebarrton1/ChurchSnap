import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../models/sermon.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  final Set<String> saved = {};

  final sermons = const [
    Sermon(
      title: 'Faith That Moves Mountains',
      speaker: 'Pastor John',
      scripture: 'Matthew 17:20',
      duration: '42 min',
    ),
    Sermon(
      title: 'Walking by Faith',
      speaker: 'Pastor John',
      scripture: '2 Corinthians 5:7',
      duration: '38 min',
    ),
    Sermon(
      title: 'Grace for the Journey',
      speaker: 'Guest Speaker',
      scripture: 'Ephesians 2:8',
      duration: '35 min',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'Sermons',
      subtitle: 'Watch, listen, and grow in faith.',
      children: [
        const SectionTitle(title: 'Featured Messages'),
        ...sermons.map((sermon) {
          final isSaved = saved.contains(sermon.title);
          return AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(sermon.icon)),
              title: Text(
                sermon.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                '${sermon.speaker} • ${sermon.duration} • ${sermon.scripture}',
              ),
              trailing: IconButton(
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                onPressed: () => setState(
                  () => isSaved
                      ? saved.remove(sermon.title)
                      : saved.add(sermon.title),
                ),
              ),
              onTap: () => _showSermon(context, sermon),
            ),
          );
        }),
      ],
    );
  }

  void _showSermon(BuildContext context, Sermon sermon) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sermon.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('${sermon.speaker} • ${sermon.scripture}'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play Sermon'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
