import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/media/models/media_item.dart';
import '../../features/media/providers/media_providers.dart';
import 'media_detail_screen.dart';

class MediaScreen extends ConsumerWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaService = ref.read(mediaServiceProvider);

    return ChurchSnapScreen(
      title: 'Media',
      subtitle: 'Watch, listen, read and grow.',
      children: [
        StreamBuilder<List<MediaItem>>(
          stream: mediaService.watchMedia(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return AppCard(child: Text('Error: ${snapshot.error}'));
            }

            final media = (snapshot.data ?? [])
                .where((item) => item.published)
                .toList();

            if (media.isEmpty) {
              return const AppCard(child: Text('No media available yet.'));
            }

            final featured = media
                .where((item) => item.featured)
                .take(3)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featured.isNotEmpty) ...[
                  const SectionTitle(title: 'Featured'),
                  ...featured.map((item) => _MediaCard(item: item)),
                ],
                const SectionTitle(title: 'Recent'),
                ...media.map((item) => _MediaCard(item: item)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MediaCard extends StatelessWidget {
  final MediaItem item;

  const _MediaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.mediaType.toLowerCase()) {
      'audio' => Icons.podcasts_rounded,
      'pdf' => Icons.picture_as_pdf_rounded,
      'image' => Icons.image_rounded,
      'livestream' => Icons.live_tv_rounded,
      _ => Icons.video_library_rounded,
    };

    return AppCard(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${item.category}${item.speaker.isEmpty ? '' : ' • ${item.speaker}'}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MediaDetailScreen(item: item)),
          );
        },
      ),
    );
  }
}
