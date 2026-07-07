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
    this.sermonDate,
    this.createdAt,
    this.icon = Icons.play_circle_fill_rounded,
  });

  factory Sermon.fromMap(String id, Map<String, dynamic> data) {
    return Sermon(
      id: id,
      title: data['title'] ?? '',
      speaker: data['speaker'] ?? '',
      scripture: data['scripture'] ?? '',
      duration: data['duration'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      notesUrl: data['notesUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      published: data['published'] ?? true,
      sermonDate: (data['sermonDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
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
      'sermonDate': sermonDate == null ? null : Timestamp.fromDate(sermonDate!),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}
