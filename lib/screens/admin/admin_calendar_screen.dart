import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/events/providers/event_providers.dart';
import '../../models/church_event.dart';
import 'admin_events_screen.dart';

import '../../core/utils/churchsnap_date_formatter.dart';

class AdminCalendarScreen extends ConsumerStatefulWidget {
  const AdminCalendarScreen({super.key, required this.churchId});

  final String churchId;

  @override
  ConsumerState<AdminCalendarScreen> createState() =>
      _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends ConsumerState<AdminCalendarScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _focusedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(adminEventsByChurchProvider(widget.churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Church Calendar',
        subtitle: 'View published events and drafts by month.',
        children: [
          _CalendarHeader(
            focusedMonth: _focusedMonth,
            onPrevious: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
            onNext: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
            onToday: () {
              final now = DateTime.now();

              setState(() {
                _focusedMonth = DateTime(now.year, now.month);
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AdminEventsScreen(churchId: widget.churchId),
                  ),
                );
              },
              icon: const Icon(Icons.edit_calendar_rounded),
              label: const Text('Manage Events'),
            ),
          ),
          const SizedBox(height: 18),
          eventsAsync.when(
            loading: () => const AppCard(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => AppCard(
              child: ListTile(
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text('Unable to load calendar'),
                subtitle: Text('$error'),
              ),
            ),
            data: (events) {
              final monthEvents = events.where(_isInFocusedMonth).toList();

              final undatedEvents = events
                  .where((event) => event.startDate == null)
                  .toList();

              final publishedCount = monthEvents
                  .where((event) => event.published)
                  .length;

              final draftCount = monthEvents.length - publishedCount;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.event_rounded, size: 18),
                        label: Text('${monthEvents.length} events'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.visibility_rounded, size: 18),
                        label: Text('$publishedCount published'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.edit_note_rounded, size: 18),
                        label: Text('$draftCount drafts'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (monthEvents.isEmpty)
                    AppCard(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month_rounded),
                        title: Text(
                          'No events in '
                          '${_monthName(_focusedMonth.month)} '
                          '${_focusedMonth.year}',
                        ),
                        subtitle: const Text('Use Manage Events to add one.'),
                      ),
                    )
                  else
                    ...monthEvents.map(
                      (event) => _CalendarEventCard(
                        event: event,
                        onTap: () => _showEventDetails(event),
                      ),
                    ),
                  if (undatedEvents.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const SectionTitle(title: 'Events Without a Date'),
                    ...undatedEvents.map(
                      (event) => _CalendarEventCard(
                        event: event,
                        onTap: () => _showEventDetails(event),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isInFocusedMonth(ChurchEvent event) {
    final startDate = event.startDate;

    if (startDate == null) {
      return false;
    }

    return startDate.year == _focusedMonth.year &&
        startDate.month == _focusedMonth.month;
  }

  Future<void> _showEventDetails(ChurchEvent event) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(event.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                icon: Icons.schedule_rounded,
                text: _eventDateText(event),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.location_on_rounded,
                text: event.location.trim().isEmpty
                    ? 'Location not provided'
                    : event.location,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.people_rounded,
                text: '${event.rsvpCount} people going',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: event.published
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                text: event.published ? 'Published' : 'Draft',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  ChurchSnapNavigation.closeAllWindows(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _eventDateText(ChurchEvent event) {
    return ChurchSnapDateFormatter.eventDateTime(
      context,
      event.startDate,
      fallback: event.when,
    );
  }

  static String _monthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) {
      return 'Unknown month';
    }

    return monthNames[month - 1];
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrevious,
                tooltip: 'Previous month',
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_AdminCalendarScreenState._monthName(focusedMonth.month)} ${focusedMonth.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNext,
                tooltip: 'Next month',
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: onToday,
            icon: const Icon(Icons.today_rounded),
            label: const Text('Current Month'),
          ),
        ],
      ),
    );
  }
}

class _CalendarEventCard extends StatelessWidget {
  const _CalendarEventCard({required this.event, required this.onTap});

  final ChurchEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final startDate = event.startDate;

    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: CircleAvatar(
          child: startDate == null
              ? const Icon(Icons.event_busy_rounded)
              : Text(
                  '${startDate.day}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${ChurchSnapDateFormatter.eventDateTime(context, event.startDate, fallback: event.when)}\n'
          '${event.location.trim().isEmpty ? 'Location not provided' : event.location}',
        ),
        isThreeLine: true,
        trailing: Chip(label: Text(event.published ? 'Published' : 'Draft')),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}
