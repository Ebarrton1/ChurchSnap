import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/sermons/providers/sermon_providers.dart';
import '../../models/sermon.dart';

class SermonsScreen extends ConsumerStatefulWidget {
  const SermonsScreen({super.key});

  @override
  ConsumerState<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends ConsumerState<SermonsScreen> {
  final Set<String> saved = {};

  @override
  Widget build(BuildContext context) {
    final sermonsAsync = ref.watch(sermonsProvider);

    return ChurchSnapScreen(
      title: 'Sermons',
      subtitle: 'Watch, listen, and grow in faith.',
      children: [
        const SectionTitle(title: 'Featured Messages'),
        sermonsAsync.when(
          loading: () =>
              const AppCard(child: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) =>
              const AppCard(child: Text('Unable to load sermons.')),
          data: (sermons) {
            if (sermons.isEmpty) {
              return const AppCard(child: Text('No sermons available yet.'));
            }

            return Column(
              children: sermons.map((sermon) {
                final sermonKey = sermon.id.isEmpty ? sermon.title : sermon.id;
                final isSaved = saved.contains(sermonKey);

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
                      onPressed: () {
                        setState(() {
                          if (isSaved) {
                            saved.remove(sermonKey);
                          } else {
                            saved.add(sermonKey);
                          }
                        });
                      },
                    ),
                    onTap: () => _showSermon(context, sermon),
                  ),
                );
              }).toList(),
            );
          },
        ),
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
            if (sermon.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(sermon.description),
            ],
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
