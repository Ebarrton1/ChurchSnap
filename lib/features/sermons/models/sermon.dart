import 'package:cloud_firestore/cloud_firestore.dart';

class Sermon {
  const Sermon({
    this.id = '',
    required this.title,
    required this.description,
    required this.speaker,
    required this.scripture,
    required this.series,
    required this.mediaUrl,
    this.thumbnailUrl = '',
    this.audioUrl = '',
    this.duration = '',
    this.publishedAt,
    this.published = true,
    this.featured = false,
  });

  final String id;
  final String title;
  final String description;
  final String speaker;
  final String scripture;
  final String series;
  final String mediaUrl;
  final String thumbnailUrl;
  final String audioUrl;
  final String duration;
  final DateTime? publishedAt;
  final bool published;
  final bool featured;

  factory Sermon.fromMap(String id, Map<String, dynamic> map) {
    final publishedAtValue = map['publishedAt'];

    return Sermon(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      speaker: map['speaker'] as String? ?? '',
      scripture: map['scripture'] as String? ?? '',
      series: map['series'] as String? ?? '',
      mediaUrl: map['mediaUrl'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      audioUrl: map['audioUrl'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      publishedAt: publishedAtValue is Timestamp
          ? publishedAtValue.toDate()
          : null,
      published: map['published'] as bool? ?? true,
      featured: map['featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'speaker': speaker,
      'scripture': scripture,
      'series': series,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'audioUrl': audioUrl,
      'duration': duration,
      'publishedAt': publishedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(publishedAt!),
      'published': published,
      'featured': featured,
    };
  }

  Sermon copyWith({
    String? id,
    String? title,
    String? description,
    String? speaker,
    String? scripture,
    String? series,
    String? mediaUrl,
    String? thumbnailUrl,
    String? audioUrl,
    String? duration,
    DateTime? publishedAt,
    bool? published,
    bool? featured,
  }) {
    return Sermon(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      speaker: speaker ?? this.speaker,
      scripture: scripture ?? this.scripture,
      series: series ?? this.series,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      publishedAt: publishedAt ?? this.publishedAt,
      published: published ?? this.published,
      featured: featured ?? this.featured,
    );
  }
}
