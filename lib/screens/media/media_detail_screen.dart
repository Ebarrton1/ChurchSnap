import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/media/models/media_item.dart';

class MediaDetailScreen extends StatelessWidget {
  final MediaItem item;

  const MediaDetailScreen({super.key, required this.item});

  Future<void> _openMedia(BuildContext context) async {
    final rawUrl = item.mediaUrl.trim();

    if (rawUrl.isEmpty) {
      _showMessage(context, 'No media URL was saved for this item.');
      return;
    }

    if (rawUrl.toLowerCase().startsWith('gs://')) {
      _showMessage(
        context,
        'This media uses a Firebase Storage gs:// address. '
        'Replace it with an HTTPS download URL.',
      );
      return;
    }

    var normalizedUrl = rawUrl;

    final initialUri = Uri.tryParse(normalizedUrl);

    if (initialUri == null) {
      _showMessage(context, 'The saved media URL is invalid.');
      return;
    }

    if (!initialUri.hasScheme) {
      normalizedUrl = 'https://$normalizedUrl';
    }

    final uri = Uri.tryParse(normalizedUrl);
    final scheme = uri?.scheme.toLowerCase();

    if (uri == null || (scheme != 'https' && scheme != 'http')) {
      _showMessage(context, 'The media URL must begin with https://');
      return;
    }

    try {
      var launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      if (!launched && context.mounted) {
        _showMessage(context, 'ChurchSnap could not open this media URL.');
      }
    } catch (error) {
      debugPrint('Media launch failed: $error');

      if (context.mounted) {
        _showMessage(context, 'Unable to open media: $error');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);

    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

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
                  onPressed: () => _openMedia(context),
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
