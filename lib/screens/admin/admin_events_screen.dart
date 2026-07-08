import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/admin/providers/admin_providers.dart';
import '../../features/events/repositories/event_repository.dart';
import '../../models/church_event.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = EventRepository();

    return Material(
      child: ChurchSnapScreen(
        title: 'Events',
        subtitle: 'Manage church events.',
        children: [
          FilledButton.icon(
            onPressed: () => _showEventDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Event'),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ChurchEvent>>(
            stream: repository.watchPublishedEvents(),
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
                      subtitle: Text('${event.when}\n${event.location}'),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEventDialog(context, ref, event: event);
                          }
                          if (value == 'delete') {
                            ref
                                .read(adminEventServiceProvider)
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
    WidgetRef ref, {
    ChurchEvent? event,
  }) {
    final titleController = TextEditingController(text: event?.title ?? '');
    DateTime? selectedStartDate = event?.startDate;
    final whenController = TextEditingController(text: event?.when ?? '');
    final locationController = TextEditingController(
      text: event?.location ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(event == null ? 'Add Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: whenController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'When',
                    suffixIcon: Icon(Icons.calendar_month_rounded),
                  ),
                  onTap: () async {
                    final now = DateTime.now();

                    final pickedDate = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedStartDate ?? now,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 5),
                    );

                    if (pickedDate == null) return;

                    final pickedTime = await showTimePicker(
                      context: dialogContext,
                      initialTime: TimeOfDay.fromDateTime(
                        selectedStartDate ?? now,
                      ),
                    );

                    if (pickedTime == null) return;

                    selectedStartDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    whenController.text =
                        '${pickedDate.month}/${pickedDate.day}/${pickedDate.year} • ${pickedTime.format(dialogContext)}';
                  },
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final updated = ChurchEvent(
                  id: event?.id ?? '',
                  title: titleController.text.trim(),
                  when: whenController.text.trim(),
                  location: locationController.text.trim(),
                  published: true,
                  startDate: selectedStartDate,
                );

                if (event == null) {
                  await ref
                      .read(adminEventServiceProvider)
                      .publishEvent(updated);
                } else {
                  await ref
                      .read(adminEventServiceProvider)
                      .updateEvent(event.id, updated);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      whenController.dispose();
      locationController.dispose();
    });
  }
}
