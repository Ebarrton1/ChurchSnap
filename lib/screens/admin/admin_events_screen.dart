import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/admin/providers/admin_providers.dart';
import '../../features/events/repositories/event_repository.dart';
import '../../models/church_event.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = EventRepository(churchId: churchId);

    return Material(
      child: ChurchSnapScreen(
        title: 'Events',
        subtitle: 'Create and manage church events.',
        children: [
          FilledButton.icon(
            onPressed: () => _showEventDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Event'),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ChurchEvent>>(
            stream: repository.watchAllEvents(),
            builder: (context, snapshot) {
              final events = snapshot.data ?? <ChurchEvent>[];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (events.isEmpty) {
                return const AppCard(child: Text('No events yet.'));
              }

              return Column(
                children: events.map((event) {
                  return AppCard(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(event.icon)),
                      title: Text(event.title),
                      subtitle: Text(
                        '${event.when}\n'
                        '${event.location}\n'
                        '${event.published ? 'Published' : 'Draft'}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEventDialog(context, ref, event: event);
                          }
                          if (value == 'delete') {
                            ref
                                .read(
                                  adminEventServiceByChurchProvider(churchId),
                                )
                                .deleteEvent(event.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEventDialog(
    BuildContext context,
    WidgetRef _, {
    ChurchEvent? event,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => _EventDialog(event: event, churchId: churchId),
    );
  }
}

class _EventDialog extends ConsumerStatefulWidget {
  const _EventDialog({this.event, required this.churchId});

  final ChurchEvent? event;
  final String churchId;

  @override
  ConsumerState<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends ConsumerState<_EventDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _published = false;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final existingStartDate = widget.event?.startDate;

    _published = widget.event?.published ?? false;

    _titleController = TextEditingController(text: widget.event?.title ?? '');

    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );

    if (existingStartDate != null) {
      _selectedDate = DateTime(
        existingStartDate.year,
        existingStartDate.month,
        existingStartDate.day,
      );

      _selectedTime = TimeOfDay.fromDateTime(existingStartDate);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return AlertDialog(
      title: Text(event == null ? 'Add Event' : 'Edit Event'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Event title',
                  prefixIcon: Icon(Icons.event_rounded),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _selectDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : _formatDate(_selectedDate!),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _selectTime,
                icon: const Icon(Icons.schedule_rounded),
                label: Text(
                  _selectedTime == null
                      ? 'Select time'
                      : _selectedTime!.format(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'EVENT VISIBILITY',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _published,
                title: Text(
                  _published ? 'Published' : 'Draft',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  _published
                      ? 'Church members can see this event.'
                      : 'Only administrators can see this event.',
                ),
                secondary: Icon(
                  _published
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _published = value;
                          _errorMessage = null;
                        });
                      },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _saveEvent,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      helpText: 'Select event date',
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
      _errorMessage = null;
    });
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Select event time',
    );

    if (!mounted || pickedTime == null) {
      return;
    }

    setState(() {
      _selectedTime = pickedTime;
      _errorMessage = null;
    });
  }

  Future<void> _saveEvent() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Enter an event title.';
      });
      return;
    }

    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Select an event date.';
      });
      return;
    }

    if (_selectedTime == null) {
      setState(() {
        _errorMessage = 'Select an event time.';
      });
      return;
    }

    final startDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final existingEvent = widget.event;

    final updatedEvent = ChurchEvent(
      id: existingEvent?.id ?? '',
      title: title,
      when:
          '${_formatDate(startDate)} ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ ${_selectedTime!.format(context)}',
      location: location,
      published: _published,
      startDate: startDate,
      endDate: existingEvent?.endDate,
      rsvpCount: existingEvent?.rsvpCount ?? 0,
      attendeeIds: existingEvent?.attendeeIds ?? const [],
    );

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(
        adminEventServiceByChurchProvider(widget.churchId),
      );

      if (existingEvent == null) {
        await service.publishEvent(updatedEvent);
      } else {
        await service.updateEvent(existingEvent.id, updatedEvent);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = 'Unable to save event: $error';
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
