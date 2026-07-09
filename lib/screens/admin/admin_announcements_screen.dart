import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/admin/providers/admin_providers.dart';

class AdminAnnouncementsScreen extends ConsumerStatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  ConsumerState<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState
    extends ConsumerState<AdminAnnouncementsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _tag = 'General';
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'Admin',
      subtitle: 'Publish announcements',
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _messageController,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Message'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _tag,
          decoration: const InputDecoration(labelText: 'Category'),
          items: const [
            DropdownMenuItem(value: 'General', child: Text('General')),
            DropdownMenuItem(value: 'Events', child: Text('Events')),
            DropdownMenuItem(value: 'Youth', child: Text('Youth')),
            DropdownMenuItem(value: 'Prayer', child: Text('Prayer')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _tag = value);
            }
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saving ? null : _publishAnnouncement,
            icon: const Icon(Icons.publish_rounded),
            label: Text(_saving ? 'Publishing...' : 'Publish'),
          ),
        ),
      ],
    );
  }

  Future<void> _publishAnnouncement() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) return;

    setState(() => _saving = true);

    try {
      await ref
          .read(adminAnnouncementServiceProvider)
          .publishAnnouncement(title: title, message: message, tag: _tag);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement published successfully.')),
      );

      _titleController.clear();
      _messageController.clear();
      setState(() => _tag = 'General');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
