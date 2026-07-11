import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../models/sermon.dart';

class SermonAudioPlayerScreen extends StatefulWidget {
  const SermonAudioPlayerScreen({super.key, required this.sermon});

  final Sermon sermon;

  @override
  State<SermonAudioPlayerScreen> createState() =>
      _SermonAudioPlayerScreenState();
}

class _SermonAudioPlayerScreenState extends State<SermonAudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();

  bool _isLoading = true;
  String? _errorMessage;

  Sermon get sermon => widget.sermon;

  @override
  void initState() {
    super.initState();
    _loadAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    final uri = Uri.tryParse(sermon.audioUrl);

    if (uri == null || !uri.hasScheme) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'The sermon audio URL is invalid.';
      });
      return;
    }

    try {
      await _player.setUrl(sermon.audioUrl);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load sermon audio: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'Sermon Audio',
      subtitle: sermon.speaker.isEmpty ? sermon.title : sermon.speaker,
      children: [
        AppCard(
          child: Column(
            children: [
              _buildArtwork(),
              const SizedBox(height: 22),
              Text(
                sermon.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (sermon.scripture.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(sermon.scripture, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const AppCard(child: Center(child: CircularProgressIndicator()))
        else if (_errorMessage != null)
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.error_outline_rounded),
              title: const Text('Audio unavailable'),
              subtitle: Text(_errorMessage!),
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  initialData: Duration.zero,
                  builder: (context, positionSnapshot) {
                    return StreamBuilder<Duration?>(
                      stream: _player.durationStream,
                      builder: (context, durationSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;
                        final duration = durationSnapshot.data ?? Duration.zero;

                        final maximum = duration.inMilliseconds > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0;

                        final value = position.inMilliseconds
                            .clamp(0, maximum.toInt())
                            .toDouble();

                        return Column(
                          children: [
                            Slider(
                              min: 0,
                              max: maximum,
                              value: value,
                              onChanged: (newValue) {
                                _player.seek(
                                  Duration(milliseconds: newValue.round()),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(position)),
                                  Text(_formatDuration(duration)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final playing = state?.playing ?? false;
                    final processingState = state?.processingState;

                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return const SizedBox(
                        width: 54,
                        height: 54,
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (processingState == ProcessingState.completed) {
                      return IconButton.filled(
                        tooltip: 'Replay',
                        iconSize: 34,
                        onPressed: () async {
                          await _player.seek(Duration.zero);
                          await _player.play();
                        },
                        icon: const Icon(Icons.replay_rounded),
                      );
                    }

                    return IconButton.filled(
                      tooltip: playing ? 'Pause' : 'Play',
                      iconSize: 38,
                      onPressed: playing ? _player.pause : _player.play,
                      icon: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: 'Back 15 seconds',
                      onPressed: () =>
                          _seekRelative(const Duration(seconds: -15)),
                      icon: const Icon(Icons.replay_10_rounded),
                    ),
                    IconButton(
                      tooltip: 'Forward 15 seconds',
                      onPressed: () =>
                          _seekRelative(const Duration(seconds: 15)),
                      icon: const Icon(Icons.forward_10_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildArtwork() {
    if (sermon.thumbnailUrl.isEmpty) {
      return const SizedBox(
        height: 220,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Center(child: Icon(Icons.headphones_rounded, size: 84)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          sermon.thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(
              color: Colors.black12,
              child: Center(child: Icon(Icons.headphones_rounded, size: 84)),
            );
          },
        ),
      ),
    );
  }

  Future<void> _seekRelative(Duration offset) async {
    final current = _player.position;
    final duration = _player.duration ?? Duration.zero;

    var target = current + offset;

    if (target < Duration.zero) {
      target = Duration.zero;
    }

    if (duration > Duration.zero && target > duration) {
      target = duration;
    }

    await _player.seek(target);
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final minuteText = minutes.toString().padLeft(2, '0');
    final secondText = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minuteText:$secondText';
    }

    return '$minuteText:$secondText';
  }
}
