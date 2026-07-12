import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/admin/providers/admin_providers.dart';
import 'admin_announcements_list_screen.dart';

class AdminAnnouncementsScreen extends ConsumerStatefulWidget {
  const AdminAnnouncementsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  ConsumerState<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState
    extends ConsumerState<AdminAnnouncementsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _tag = 'General';
  bool _saving = false;
  String? _feedbackMessage;
  bool _feedbackIsError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChurchSnapScreen(
        title: 'Announcements',
        subtitle: 'Publish announcements for ${widget.churchId}.',
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  enabled: !_saving,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.message_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _tag,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.label_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(value: 'Events', child: Text('Events')),
                    DropdownMenuItem(value: 'Youth', child: Text('Youth')),
                    DropdownMenuItem(value: 'Prayer', child: Text('Prayer')),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _tag = value;
                            _feedbackMessage = null;
                          });
                        },
                ),
                if (_feedbackMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _feedbackMessage!,
                    style: TextStyle(
                      color: _feedbackIsError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _publishAnnouncement,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.campaign_rounded),
                  label: Text(
                    _saving ? 'Publishing...' : 'Publish Announcement',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _saving
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AdminAnnouncementsListScreen(
                          churchId: widget.churchId,
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.list_alt_rounded),
            label: const Text('Manage Existing Announcements'),
          ),
        ],
      ),
    );
  }

  Future<void> _publishAnnouncement() async {
    FocusScope.of(context).unfocus();

    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      setState(() {
        _feedbackIsError = true;
        _feedbackMessage = 'Enter both a title and a message.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _feedbackMessage = null;
    });

    try {
      final service = ref.read(
        adminAnnouncementServiceByChurchProvider(widget.churchId),
      );

      await service.publishAnnouncement(
        title: title,
        message: message,
        tag: _tag,
      );

      if (!mounted) {
        return;
      }

      _titleController.clear();
      _messageController.clear();

      setState(() {
        _saving = false;
        _tag = 'General';
        _feedbackIsError = false;
        _feedbackMessage = 'Announcement published successfully.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement published successfully.')),
      );
    } catch (error, stackTrace) {
      debugPrint('Announcement publishing failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _feedbackIsError = true;
        _feedbackMessage = 'Unable to publish announcement: $error';
      });
    }
  }
}
