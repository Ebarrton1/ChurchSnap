import 'package:cloud_firestore/cloud_firestore.dart';

class MediaItem {
  final String id;
  final String title;
  final String description;
  final String mediaType;
  final String category;
  final String speaker;
  final String thumbnailUrl;
  final String mediaUrl;
  final String duration;
  final bool published;
  final bool featured;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MediaItem({
    this.id = '',
    required this.title,
    this.description = '',
    this.mediaType = 'video',
    this.category = 'General',
    this.speaker = '',
    this.thumbnailUrl = '',
    this.mediaUrl = '',
    this.duration = '',
    this.published = true,
    this.featured = false,
    this.createdAt,
    this.updatedAt,
  });

  factory MediaItem.fromMap(String id, Map<String, dynamic> map) {
    return MediaItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      mediaType: map['mediaType'] ?? 'video',
      category: map['category'] ?? 'General',
      speaker: map['speaker'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      duration: map['duration'] ?? '',
      published: map['published'] ?? true,
      featured: map['featured'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'mediaType': mediaType,
      'category': category,
      'speaker': speaker,
      'thumbnailUrl': thumbnailUrl,
      'mediaUrl': mediaUrl,
      'duration': duration,
      'published': published,
      'featured': featured,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
