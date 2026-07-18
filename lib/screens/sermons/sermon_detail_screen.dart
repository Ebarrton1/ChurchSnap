import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/sermons/providers/sermon_providers.dart';
import '../../models/sermon.dart';
import 'sermon_audio_player_screen.dart';
import 'sermon_video_player_screen.dart';

class SermonDetailScreen extends ConsumerStatefulWidget {
  const SermonDetailScreen({
    super.key,
    required this.sermon,
    this.initiallySaved = false,
    this.onSavedChanged,
  });

  final Sermon sermon;
  final bool initiallySaved;
  final ValueChanged<bool>? onSavedChanged;

  @override
  ConsumerState<SermonDetailScreen> createState() => _SermonDetailScreenState();
}

class _SermonDetailScreenState extends ConsumerState<SermonDetailScreen> {
  late bool _isSaved;

  bool _isDownloaded = false;
  bool _isCheckingDownload = true;
  bool _isDownloading = false;
  bool _isDeletingDownload = false;

  Sermon get sermon => widget.sermon;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initiallySaved;
    _loadDownloadState();
  }

  Future<void> _loadDownloadState() async {
    try {
      final repository = ref.read(sermonDownloadRepositoryProvider);
      final downloaded = await repository.isDownloaded(sermon.id);

      if (!mounted) return;

      setState(() {
        _isDownloaded = downloaded;
        _isCheckingDownload = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDownloaded = false;
        _isCheckingDownload = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'Sermon',
      subtitle: sermon.scripture.isEmpty
          ? 'Watch, listen, and grow in faith.'
          : sermon.scripture,
      children: [
        _buildThumbnail(),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sermon.title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (sermon.speaker.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sermon.speaker,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
              if (sermon.duration.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(sermon.duration),
                  ],
                ),
              ],
              if (sermon.sermonDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(_formatDate(sermon.sermonDate!)),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (sermon.description.isNotEmpty) ...[
          const SectionTitle(title: 'About This Message'),
          AppCard(
            child: Text(
              sermon.description,
              style: const TextStyle(height: 1.55, fontSize: 15),
            ),
          ),
        ],
        const SectionTitle(title: 'Watch & Listen'),
        if (sermon.videoUrl.isNotEmpty)
          _ActionCard(
            icon: Icons.play_circle_fill_rounded,
            title: 'Watch Sermon',
            subtitle: 'Open the sermon video',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SermonVideoPlayerScreen(sermon: sermon),
                ),
              );
            },
          ),
        if (sermon.audioUrl.isNotEmpty)
          _ActionCard(
            icon: _isDownloaded
                ? Icons.offline_pin_rounded
                : Icons.headphones_rounded,
            title: _isDownloaded ? 'Listen Offline' : 'Listen to Audio',
            subtitle: _isDownloaded
                ? 'Play the downloaded audio from this device'
                : 'Stream the sermon audio recording',
            onTap: _openAudioPlayer,
          ),
        if (sermon.audioUrl.isNotEmpty) _buildDownloadCard(),
        if (sermon.notesUrl.isNotEmpty)
          _ActionCard(
            icon: Icons.description_rounded,
            title: 'Sermon Notes',
            subtitle: 'Open notes or study material',
            onTap: () => _launchUrl(sermon.notesUrl),
          ),
        if (sermon.videoUrl.isEmpty &&
            sermon.audioUrl.isEmpty &&
            sermon.notesUrl.isEmpty)
          const AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline_rounded),
              title: Text('Media not available'),
              subtitle: Text('Video, audio, or notes have not been added yet.'),
            ),
          ),
        const Text(
          'Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        AppCard(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Icon(
                    _isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                ),
                title: Text(
                  _isSaved ? 'Saved Sermon' : 'Save Sermon',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  _isSaved
                      ? 'This sermon has been added to your saved messages.'
                      : 'Add this sermon to your saved messages.',
                ),
                trailing: Switch(value: _isSaved, onChanged: _setSaved),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.share_rounded)),
                title: const Text(
                  'Share Sermon',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Copy the sermon link to your clipboard.'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _copyShareLink,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadCard() {
    if (_isCheckingDownload) {
      return const AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          title: Text(
            'Checking Offline Audio',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text('Checking this device for a downloaded copy.'),
        ),
      );
    }

    if (_isDownloading) {
      return const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.download_rounded)),
              title: Text(
                'Downloading Audio',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                'Keep ChurchSnap open until the download is complete.',
              ),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(),
          ],
        ),
      );
    }

    if (_isDeletingDownload) {
      return const AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          title: Text(
            'Removing Download',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text('Deleting the offline audio from this device.'),
        ),
      );
    }

    if (_isDownloaded) {
      return _ActionCard(
        icon: Icons.delete_outline_rounded,
        title: 'Remove Download',
        subtitle: 'Delete the offline audio from this device',
        trailing: const Icon(Icons.delete_outline_rounded),
        onTap: _confirmDeleteDownload,
      );
    }

    return _ActionCard(
      icon: Icons.download_for_offline_outlined,
      title: 'Download Audio',
      subtitle: 'Save this sermon for listening without internet',
      trailing: const Icon(Icons.download_rounded),
      onTap: _downloadAudio,
    );
  }

  Widget _buildThumbnail() {
    if (sermon.displayThumbnailUrl.isEmpty) {
      return const AppCard(
        child: SizedBox(
          width: double.infinity,
          height: 220,
          child: Center(child: Icon(Icons.play_circle_fill_rounded, size: 84)),
        ),
      );
    }

    return AppCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            sermon.displayThumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(
                color: Colors.black12,
                child: Center(
                  child: Icon(Icons.play_circle_fill_rounded, size: 84),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void openVideoPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SermonVideoPlayerScreen(sermon: sermon),
      ),
    );
  }

  Future<void> _openAudioPlayer() async {
    Sermon playableSermon = sermon;

    try {
      final repository = ref.read(sermonDownloadRepositoryProvider);
      final downloadedFile = await repository.getDownloadedFile(sermon.id);

      if (downloadedFile != null && await downloadedFile.exists()) {
        playableSermon = sermon.copyWith(
          audioUrl: Uri.file(downloadedFile.path).toString(),
        );
      } else if (_isDownloaded && mounted) {
        setState(() {
          _isDownloaded = false;
        });
      }
    } catch (_) {
      playableSermon = sermon;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SermonAudioPlayerScreen(sermon: playableSermon),
      ),
    );
  }

  Future<void> _downloadAudio() async {
    if (sermon.audioUrl.isEmpty || _isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final repository = ref.read(sermonDownloadRepositoryProvider);

      await repository.downloadAudio(
        sermonId: sermon.id,
        audioUrl: sermon.audioUrl,
      );

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
      });

      _showMessage('Sermon audio downloaded for offline listening.');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      _showMessage('Unable to download this sermon audio.');
    }
  }

  Future<void> _confirmDeleteDownload() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Download?'),
          content: const Text(
            'The sermon will remain available for streaming when you have an internet connection.',
          ),
          actions: [
            TextButton(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: true,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await _deleteDownload();
  }

  Future<void> _deleteDownload() async {
    setState(() {
      _isDeletingDownload = true;
    });

    try {
      final repository = ref.read(sermonDownloadRepositoryProvider);
      await repository.deleteDownload(sermon.id);

      if (!mounted) return;

      setState(() {
        _isDeletingDownload = false;
        _isDownloaded = false;
      });

      _showMessage('Offline sermon audio removed.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDeletingDownload = false;
      });

      _showMessage('Unable to remove the downloaded audio.');
    }
  }

  void _setSaved(bool value) {
    setState(() {
      _isSaved = value;
    });

    widget.onSavedChanged?.call(value);
  }

  Future<void> _launchUrl(String value) async {
    final uri = Uri.tryParse(value);

    if (uri == null || !uri.hasScheme) {
      _showMessage('This sermon link is invalid.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      _showMessage('Unable to open this sermon link.');
    }
  }

  Future<void> _copyShareLink() async {
    final shareLink = _preferredShareLink();

    if (shareLink.isEmpty) {
      _showMessage('No shareable sermon link is available.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: shareLink));

    if (!mounted) return;

    _showMessage('Sermon link copied.');
  }

  String _preferredShareLink() {
    if (sermon.videoUrl.isNotEmpty) return sermon.videoUrl;
    if (sermon.audioUrl.isNotEmpty) return sermon.audioUrl;
    if (sermon.notesUrl.isNotEmpty) return sermon.notesUrl;

    return '';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF123A63),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.76),
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                trailing ??
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension _SermonDisplayThumbnail on Sermon {
  String get displayThumbnailUrl {
    final manualThumbnail = thumbnailUrl.trim();

    if (manualThumbnail.isNotEmpty) {
      return manualThumbnail;
    }

    final videoId = _youtubeVideoId(videoUrl);

    if (videoId == null) {
      return '';
    }

    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }
}

String? _youtubeVideoId(String rawUrl) {
  final value = rawUrl.trim();

  if (value.isEmpty) {
    return null;
  }

  final normalizedUrl = value.contains('://') ? value : 'https://$value';

  final uri = Uri.tryParse(normalizedUrl);

  if (uri == null) {
    return null;
  }

  final host = uri.host.toLowerCase();
  String? videoId;

  if (host == 'youtu.be' || host.endsWith('.youtu.be')) {
    if (uri.pathSegments.isNotEmpty) {
      videoId = uri.pathSegments.first;
    }
  } else if (host == 'youtube.com' || host.endsWith('.youtube.com')) {
    final firstSegment = uri.pathSegments.isEmpty
        ? ''
        : uri.pathSegments.first.toLowerCase();

    if (firstSegment == 'embed' ||
        firstSegment == 'shorts' ||
        firstSegment == 'live') {
      if (uri.pathSegments.length > 1) {
        videoId = uri.pathSegments[1];
      }
    } else {
      videoId = uri.queryParameters['v'];
    }
  }

  final cleanedVideoId = videoId?.trim();

  if (cleanedVideoId == null ||
      !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(cleanedVideoId)) {
    return null;
  }

  return cleanedVideoId;
}
