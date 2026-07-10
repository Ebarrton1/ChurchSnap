import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Sermon {
  final String id;
  final String title;
  final String speaker;
  final String scripture;
  final String duration;
  final String description;
  final String videoUrl;
  final String audioUrl;
  final String notesUrl;
  final String thumbnailUrl;
  final bool published;
  final bool featured;
  final DateTime? sermonDate;
  final DateTime? createdAt;
  final IconData icon;

  const Sermon({
    this.id = '',
    required this.title,
    required this.speaker,
    required this.scripture,
    required this.duration,
    this.description = '',
    this.videoUrl = '',
    this.audioUrl = '',
    this.notesUrl = '',
    this.thumbnailUrl = '',
    this.published = true,
    this.featured = false,
    this.sermonDate,
    this.createdAt,
    this.icon = Icons.play_circle_fill_rounded,
  });

  factory Sermon.fromMap(String id, Map<String, dynamic> data) {
    final sermonDateValue = data['sermonDate'];
    final createdAtValue = data['createdAt'];

    return Sermon(
      id: id,
      title: data['title'] as String? ?? '',
      speaker: data['speaker'] as String? ?? '',
      scripture: data['scripture'] as String? ?? '',
      duration: data['duration'] as String? ?? '',
      description: data['description'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      audioUrl: data['audioUrl'] as String? ?? '',
      notesUrl: data['notesUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      published: data['published'] as bool? ?? true,
      featured: data['featured'] as bool? ?? false,
      sermonDate: sermonDateValue is Timestamp
          ? sermonDateValue.toDate()
          : null,
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'speaker': speaker,
      'scripture': scripture,
      'duration': duration,
      'description': description,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'notesUrl': notesUrl,
      'thumbnailUrl': thumbnailUrl,
      'published': published,
      'featured': featured,
      'sermonDate': sermonDate == null ? null : Timestamp.fromDate(sermonDate!),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  Sermon copyWith({
    String? id,
    String? title,
    String? speaker,
    String? scripture,
    String? duration,
    String? description,
    String? videoUrl,
    String? audioUrl,
    String? notesUrl,
    String? thumbnailUrl,
    bool? published,
    bool? featured,
    DateTime? sermonDate,
    DateTime? createdAt,
    IconData? icon,
  }) {
    return Sermon(
      id: id ?? this.id,
      title: title ?? this.title,
      speaker: speaker ?? this.speaker,
      scripture: scripture ?? this.scripture,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      notesUrl: notesUrl ?? this.notesUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      published: published ?? this.published,
      featured: featured ?? this.featured,
      sermonDate: sermonDate ?? this.sermonDate,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
    );
  }
}
