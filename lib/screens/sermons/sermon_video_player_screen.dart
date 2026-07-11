import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../models/sermon.dart';

class SermonVideoPlayerScreen extends StatefulWidget {
  const SermonVideoPlayerScreen({super.key, required this.sermon});

  final Sermon sermon;

  @override
  State<SermonVideoPlayerScreen> createState() =>
      _SermonVideoPlayerScreenState();
}

class _SermonVideoPlayerScreenState extends State<SermonVideoPlayerScreen> {
  YoutubePlayerController? _controller;
  String? _errorMessage;

  Sermon get sermon => widget.sermon;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _initializePlayer() {
    final videoId = _extractYoutubeVideoId(sermon.videoUrl);

    if (videoId == null) {
      _errorMessage = 'This video is not a recognized YouTube link.';
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        playsInline: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return ChurchSnapScreen(
      title: 'Sermon Video',
      subtitle: sermon.speaker.isEmpty ? sermon.title : sermon.speaker,
      children: [
        if (controller == null)
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.error_outline_rounded),
              title: const Text('Video unavailable'),
              subtitle: Text(_errorMessage ?? 'Unable to load this video.'),
            ),
          )
        else
          AppCard(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: YoutubePlayer(controller: controller, aspectRatio: 16 / 9),
            ),
          ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sermon.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (sermon.speaker.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(sermon.speaker)),
                  ],
                ),
              ],
              if (sermon.scripture.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(sermon.scripture)),
                  ],
                ),
              ],
              if (sermon.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(sermon.description, style: const TextStyle(height: 1.5)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String? _extractYoutubeVideoId(String value) {
    final uri = Uri.tryParse(value.trim());

    if (uri == null) {
      return null;
    }

    final host = uri.host.toLowerCase();

    if (host == 'youtu.be' || host == 'www.youtu.be') {
      return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    }

    if (host.contains('youtube.com')) {
      final queryId = uri.queryParameters['v'];

      if (queryId != null && queryId.isNotEmpty) {
        return queryId;
      }

      final segments = uri.pathSegments;

      if (segments.length >= 2 &&
          (segments.first == 'embed' ||
              segments.first == 'shorts' ||
              segments.first == 'live')) {
        return segments[1];
      }
    }

    return null;
  }
}
