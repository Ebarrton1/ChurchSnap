import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/media/models/media_item.dart';

class MediaDetailScreen extends StatelessWidget {
  final MediaItem item;

  const MediaDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.mediaType.toLowerCase()) {
      'audio' => Icons.podcasts_rounded,
      'pdf' => Icons.picture_as_pdf_rounded,
      'image' => Icons.image_rounded,
      'livestream' => Icons.live_tv_rounded,
      _ => Icons.video_library_rounded,
    };

    return ChurchSnapScreen(
      title: item.title,
      subtitle: item.category,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(radius: 42, child: Icon(icon, size: 38)),
              ),
              const SizedBox(height: 18),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              if (item.speaker.isNotEmpty) Text(item.speaker),
              if (item.duration.isNotEmpty) Text(item.duration),
              const SizedBox(height: 14),
              Text(
                item.description.isEmpty
                    ? 'No description available.'
                    : item.description,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: item.mediaUrl.isEmpty
                      ? null
                      : () async {
                          final uri = Uri.parse(item.mediaUrl);

                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Unable to open media.'),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    item.mediaType.toLowerCase() == 'pdf'
                        ? 'Open Document'
                        : 'Play Media',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
