import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/widgets/churchsnap_screen.dart';
import '../../models/sermon.dart';
import 'sermon_audio_player_screen.dart';

class SermonDetailScreen extends StatefulWidget {
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
  State<SermonDetailScreen> createState() => _SermonDetailScreenState();
}

class _SermonDetailScreenState extends State<SermonDetailScreen> {
  late bool _isSaved;

  Sermon get sermon => widget.sermon;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initiallySaved;
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
            onTap: () => _launchUrl(sermon.videoUrl),
          ),
        if (sermon.audioUrl.isNotEmpty)
          _ActionCard(
            icon: Icons.headphones_rounded,
            title: 'Listen to Audio',
            subtitle: 'Open the audio recording',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SermonAudioPlayerScreen(sermon: sermon),
                ),
              );
            },
          ),
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
              leading: Icon(Icons.info_outline_rounded),
              title: Text('Media not available'),
              subtitle: Text('Video, audio, or notes have not been added yet.'),
            ),
          ),
        const SectionTitle(title: 'Actions'),
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
                      ? 'This sermon is saved for this app session.'
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

  Widget _buildThumbnail() {
    if (sermon.thumbnailUrl.isEmpty) {
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
            sermon.thumbnailUrl,
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new_rounded),
        onTap: onTap,
      ),
    );
  }
}
