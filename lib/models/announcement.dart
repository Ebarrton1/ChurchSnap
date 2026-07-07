import 'package:flutter/material.dart';

class Announcement {
  final String id;
  final String title;
  final String message;
  final String tag;
  final IconData icon;
  final bool published;
  final DateTime? createdAt;

  const Announcement({
    this.id = '',
    required this.title,
    required this.message,
    required this.tag,
    this.icon = Icons.campaign_rounded,
    this.published = true,
    this.createdAt,
  });

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? map['body'] as String? ?? '',
      tag: map['tag'] as String? ?? 'General',
      published: map['published'] as bool? ?? true,
      createdAt: map['createdAt'] == null
          ? null
          : map['createdAt'].toDate() as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'tag': tag,
      'published': published,
      'createdAt': createdAt,
    };
  }
}
