import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/sermons/providers/sermon_providers.dart';
import '../../models/sermon.dart';
import 'sermon_detail_screen.dart';

class SermonsScreen extends ConsumerStatefulWidget {
  const SermonsScreen({super.key});

  @override
  ConsumerState<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends ConsumerState<SermonsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _savedSermons = {};

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sermonsAsync = ref.watch(sermonsProvider);

    return ChurchSnapScreen(
      title: 'Sermons',
      subtitle: 'Watch, listen, and grow in faith.',
      children: [
        AppCard(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search sermons',
              hintText: 'Title, speaker, or Scripture',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        sermonsAsync.when(
          loading: () =>
              const AppCard(child: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => AppCard(
            child: ListTile(
              leading: const Icon(Icons.error_outline_rounded),
              title: const Text('Unable to load sermons'),
              subtitle: Text('$error'),
            ),
          ),
          data: (sermons) {
            final publishedSermons =
                sermons.where((sermon) => sermon.published).toList()
                  ..sort((first, second) {
                    final firstDate =
                        first.sermonDate ??
                        first.createdAt ??
                        DateTime.fromMillisecondsSinceEpoch(0);

                    final secondDate =
                        second.sermonDate ??
                        second.createdAt ??
                        DateTime.fromMillisecondsSinceEpoch(0);

                    return secondDate.compareTo(firstDate);
                  });

            final filteredSermons = publishedSermons.where((sermon) {
              if (_searchQuery.isEmpty) {
                return true;
              }

              final searchableText = [
                sermon.title,
                sermon.speaker,
                sermon.scripture,
                sermon.description,
              ].join(' ').toLowerCase();

              return searchableText.contains(_searchQuery);
            }).toList();

            if (publishedSermons.isEmpty) {
              return const AppCard(
                child: ListTile(
                  leading: Icon(Icons.play_circle_outline_rounded),
                  title: Text('No sermons available yet'),
                  subtitle: Text('Published sermons will appear here.'),
                ),
              );
            }

            if (filteredSermons.isEmpty) {
              return const AppCard(
                child: ListTile(
                  leading: Icon(Icons.search_off_rounded),
                  title: Text('No matching sermons'),
                  subtitle: Text(
                    'Try searching with a different title, speaker, or Scripture.',
                  ),
                ),
              );
            }

            final featuredSermon = filteredSermons.firstWhere(
              (sermon) => sermon.featured,
              orElse: () => filteredSermons.first,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Featured Message'),
                _FeaturedSermonCard(
                  sermon: featuredSermon,
                  onOpen: () => _openSermon(featuredSermon),
                ),
                const SectionTitle(title: 'Recent Sermons'),
                ...filteredSermons.map((sermon) {
                  final sermonKey = sermon.id.isEmpty
                      ? sermon.title
                      : sermon.id;

                  final isSaved = _savedSermons.contains(sermonKey);

                  return _SermonCard(
                    sermon: sermon,
                    isSaved: isSaved,
                    onSave: () {
                      setState(() {
                        if (isSaved) {
                          _savedSermons.remove(sermonKey);
                        } else {
                          _savedSermons.add(sermonKey);
                        }
                      });
                    },
                    onOpen: () => _openSermon(sermon),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _openSermon(Sermon sermon) async {
    final sermonKey = sermon.id.isEmpty ? sermon.title : sermon.id;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => SermonDetailScreen(
          sermon: sermon,
          initiallySaved: _savedSermons.contains(sermonKey),
          onSavedChanged: (isSaved) {
            if (!mounted) return;

            setState(() {
              if (isSaved) {
                _savedSermons.add(sermonKey);
              } else {
                _savedSermons.remove(sermonKey);
              }
            });
          },
        ),
      ),
    );
  }
}

class _FeaturedSermonCard extends StatelessWidget {
  const _FeaturedSermonCard({required this.sermon, required this.onOpen});

  final Sermon sermon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sermon.thumbnailUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  sermon.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const ColoredBox(
                      color: Colors.black12,
                      child: Center(
                        child: Icon(Icons.play_circle_fill_rounded, size: 58),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            const SizedBox(
              height: 180,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  color: Colors.black12,
                ),
                child: Center(
                  child: Icon(Icons.play_circle_fill_rounded, size: 64),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            sermon.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            sermon.speaker.isEmpty
                ? sermon.scripture
                : '${sermon.speaker}'
                      '${sermon.scripture.isEmpty ? '' : ' • ${sermon.scripture}'}',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Open Sermon'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SermonCard extends StatelessWidget {
  const _SermonCard({
    required this.sermon,
    required this.isSaved,
    required this.onSave,
    required this.onOpen,
  });

  final Sermon sermon;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (sermon.speaker.isNotEmpty) sermon.speaker,
      if (sermon.duration.isNotEmpty) sermon.duration,
      if (sermon.scripture.isNotEmpty) sermon.scripture,
    ].join(' • ');

    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Icon(sermon.icon)),
        title: Text(
          sermon.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: details.isEmpty ? null : Text(details),
        trailing: IconButton(
          tooltip: isSaved ? 'Remove bookmark' : 'Save sermon',
          onPressed: onSave,
          icon: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          ),
        ),
        onTap: onOpen,
      ),
    );
  }
}
