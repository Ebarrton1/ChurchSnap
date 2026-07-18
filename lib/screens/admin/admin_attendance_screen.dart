import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/check_in/models/check_in_record.dart';
import '../../features/check_in/repositories/check_in_repository.dart';

enum _ClearCheckInScope { today, event, all }

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key, this.churchId = 'demo-church'});

  final String churchId;

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  late final CheckInRepository _repository;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedCheckInIds = <String>{};

  String _searchQuery = '';
  String? _selectedEventId;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _repository = CheckInRepository(churchId: widget.churchId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChurchSnapScreen(
        title: 'Attendance & Check-ins',
        subtitle: 'Review and safely clear event check-ins.',
        children: [
          const AppCard(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.admin_panel_settings_outlined),
              ),
              title: Text(
                'Administrator controls',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                'Clearing check-ins permanently removes the selected attendance '
                'records. Member accounts and directory profiles are not deleted.',
              ),
            ),
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<CheckInRecord>>(
            stream: _repository.watchAllRecentCheckIns(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load check-ins'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final checkIns = snapshot.data ?? <CheckInRecord>[];

              return _buildAttendanceContent(checkIns);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceContent(List<CheckInRecord> checkIns) {
    final eventIds =
        checkIns
            .map((checkIn) => checkIn.eventId.trim())
            .where((eventId) => eventId.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (_selectedEventId != null && !eventIds.contains(_selectedEventId)) {
      _selectedEventId = null;
    }

    final normalizedQuery = _searchQuery.trim().toLowerCase();

    final filtered = checkIns.where((checkIn) {
      if (_selectedEventId != null && checkIn.eventId != _selectedEventId) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      return [
        checkIn.displayName,
        checkIn.userId,
        checkIn.eventId,
        checkIn.checkInMethod,
      ].join(' ').toLowerCase().contains(normalizedQuery);
    }).toList();

    _selectedCheckInIds.removeWhere(
      (id) => !checkIns.any((checkIn) => checkIn.id == id),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search check-ins',
                  hintText: 'Member, event ID, or method',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();

                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _selectedEventId,
                decoration: const InputDecoration(
                  labelText: 'Filter by event',
                  prefixIcon: Icon(Icons.event_available_rounded),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All recent events'),
                  ),
                  ...eventIds.map(
                    (eventId) => DropdownMenuItem<String?>(
                      value: eventId,
                      child: Text(eventId),
                    ),
                  ),
                ],
                onChanged: _isDeleting
                    ? null
                    : (eventId) {
                        setState(() {
                          _selectedEventId = eventId;
                          _selectedCheckInIds.clear();
                        });
                      },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: _isDeleting || _selectedCheckInIds.isEmpty
                        ? null
                        : _confirmClearSelected,
                    icon: const Icon(Icons.delete_sweep_rounded),
                    label: Text(
                      'Clear Selected (${_selectedCheckInIds.length})',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isDeleting || checkIns.isEmpty
                        ? null
                        : () => _showClearOptions(checkIns.length),
                    icon: const Icon(Icons.cleaning_services_rounded),
                    label: const Text('Clear Check-ins'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_isDeleting)
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: LinearProgressIndicator(),
          ),
        if (checkIns.isEmpty)
          const AppCard(
            child: ListTile(
              leading: Icon(Icons.event_available_outlined),
              title: Text('No check-ins yet'),
              subtitle: Text('New QR and manual check-ins will appear here.'),
            ),
          )
        else if (filtered.isEmpty)
          const AppCard(
            child: ListTile(
              leading: Icon(Icons.search_off_rounded),
              title: Text('No matching check-ins'),
              subtitle: Text('Change the search or event filter.'),
            ),
          )
        else ...[
          Row(
            children: [
              Checkbox(
                value: filtered.every(
                  (checkIn) => _selectedCheckInIds.contains(checkIn.id),
                ),
                tristate:
                    filtered.any(
                      (checkIn) => _selectedCheckInIds.contains(checkIn.id),
                    ) &&
                    !filtered.every(
                      (checkIn) => _selectedCheckInIds.contains(checkIn.id),
                    ),
                onChanged: _isDeleting
                    ? null
                    : (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedCheckInIds.addAll(
                              filtered.map((checkIn) => checkIn.id),
                            );
                          } else {
                            _selectedCheckInIds.removeAll(
                              filtered.map((checkIn) => checkIn.id),
                            );
                          }
                        });
                      },
              ),
              Expanded(
                child: Text(
                  '${filtered.length} check-in'
                  '${filtered.length == 1 ? '' : 's'} shown',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...filtered.map(_buildCheckInCard),
        ],
      ],
    );
  }

  Widget _buildCheckInCard(CheckInRecord checkIn) {
    final displayName = checkIn.displayName.trim().isEmpty
        ? 'Unnamed Member'
        : checkIn.displayName.trim();
    final isSelected = _selectedCheckInIds.contains(checkIn.id);
    final dateLabel = checkIn.checkedInAt == null
        ? 'Date unavailable'
        : _formatDateTime(checkIn.checkedInAt!);
    final eventLabel = checkIn.eventId.trim().isEmpty
        ? 'Unspecified event'
        : checkIn.eventId.trim();

    return AppCard(
      child: CheckboxListTile(
        value: isSelected,
        onChanged: _isDeleting
            ? null
            : (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedCheckInIds.add(checkIn.id);
                  } else {
                    _selectedCheckInIds.remove(checkIn.id);
                  }
                });
              },
        controlAffinity: ListTileControlAffinity.leading,
        secondary: IconButton(
          tooltip: 'Remove this check-in',
          onPressed: _isDeleting ? null : () => _confirmDeleteOne(checkIn),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          'Event: $eventLabel\n'
          '$dateLabel â€¢ ${checkIn.checkInMethod.toUpperCase()}',
        ),
        isThreeLine: true,
      ),
    );
  }

  Future<void> _showClearOptions(int totalLoaded) async {
    final selectedScope = await showModalBottomSheet<_ClearCheckInScope>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    'Clear Check-ins',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    'Choose exactly which attendance records to remove.',
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.today_rounded)),
                  title: const Text('Clear Todayâ€™s Check-ins'),
                  subtitle: const Text(
                    'Remove check-ins recorded on the current local date.',
                  ),
                  onTap: () => ChurchSnapNavigation.closeAllWindows(
                    sheetContext,
                    result: _ClearCheckInScope.today,
                  ),
                ),
                if (_selectedEventId != null)
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.event_busy_rounded),
                    ),
                    title: const Text('Clear Current Event'),
                    subtitle: Text(
                      'Remove every check-in for $_selectedEventId.',
                    ),
                    onTap: () => Navigator.of(
                      sheetContext,
                    ).pop(_ClearCheckInScope.event),
                  ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.delete_forever_rounded),
                  ),
                  title: const Text('Clear All Check-ins'),
                  subtitle: Text(
                    'Permanently remove all check-ins. '
                    '$totalLoaded recent records are currently displayed.',
                  ),
                  onTap: () => ChurchSnapNavigation.closeAllWindows(
                    sheetContext,
                    result: _ClearCheckInScope.all,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedScope == null || !mounted) {
      return;
    }

    await _confirmAndClearScope(selectedScope);
  }

  Future<void> _confirmDeleteOne(CheckInRecord checkIn) async {
    final displayName = checkIn.displayName.trim().isEmpty
        ? 'this member'
        : checkIn.displayName.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this check-in?'),
        content: Text(
          'The attendance entry for $displayName will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => ChurchSnapNavigation.closeAllWindows(
              dialogContext,
              result: false,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => ChurchSnapNavigation.closeAllWindows(
              dialogContext,
              result: true,
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _runDelete(
      operation: () => _repository.deleteCheckIn(checkIn.id),
      successLabel: 'check-in removed',
    );
  }

  Future<void> _confirmClearSelected() async {
    final count = _selectedCheckInIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Clear $count selected check-in${count == 1 ? '' : 's'}?'),
        content: const Text(
          'The selected attendance records will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => ChurchSnapNavigation.closeAllWindows(
              dialogContext,
              result: false,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => ChurchSnapNavigation.closeAllWindows(
              dialogContext,
              result: true,
            ),
            icon: const Icon(Icons.delete_sweep_rounded),
            label: const Text('Clear Selected'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final ids = Set<String>.from(_selectedCheckInIds);

    await _runDelete(
      operation: () => _repository.deleteSelectedCheckIns(ids),
      successLabel: 'selected check-ins cleared',
      clearSelection: true,
    );
  }

  Future<void> _confirmAndClearScope(_ClearCheckInScope scope) async {
    if (scope == _ClearCheckInScope.all) {
      await _confirmClearAll();
      return;
    }

    final isToday = scope == _ClearCheckInScope.today;
    final title = isToday
        ? 'Clear todayâ€™s check-ins?'
        : 'Clear current event check-ins?';
    final message = isToday
        ? 'All check-ins recorded today will be permanently removed.'
        : 'Every check-in for $_selectedEventId will be permanently removed.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => ChurchSnapNavigation.closeAllWindows(
              dialogContext,
              result: false,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => ChurchSnapNavigation.closeAllWindows(
              dialogContext,
              result: true,
            ),
            icon: const Icon(Icons.cleaning_services_rounded),
            label: const Text('Clear Check-ins'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    if (isToday) {
      await _runDelete(
        operation: () => _repository.clearCheckInsForDate(DateTime.now()),
        successLabel: 'todayâ€™s check-ins cleared',
        clearSelection: true,
      );
    } else {
      final eventId = _selectedEventId;

      if (eventId == null) {
        return;
      }

      await _runDelete(
        operation: () => _repository.clearCheckInsForEvent(eventId),
        successLabel: 'event check-ins cleared',
        clearSelection: true,
      );
    }
  }

  Future<void> _confirmClearAll() async {
    final confirmationController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var canClear = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Clear every check-in?'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This permanently deletes every attendance check-in for '
                      'this church. This action cannot be undone.',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmationController,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Type CLEAR to continue',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          canClear = value.trim().toUpperCase() == 'CLEAR';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => ChurchSnapNavigation.closeAllWindows(
                    dialogContext,
                    result: false,
                  ),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: canClear
                      ? () => Navigator.of(dialogContext).pop(true)
                      : null,
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Clear Everything'),
                ),
              ],
            );
          },
        );
      },
    );

    confirmationController.dispose();

    if (confirmed != true || !mounted) {
      return;
    }

    await _runDelete(
      operation: _repository.clearAllCheckIns,
      successLabel: 'all check-ins cleared',
      clearSelection: true,
    );
  }

  Future<void> _runDelete({
    required Future<int> Function() operation,
    required String successLabel,
    bool clearSelection = false,
  }) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final deletedCount = await operation();

      if (!mounted) {
        return;
      }

      if (clearSelection) {
        _selectedCheckInIds.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deletedCount == 0
                ? 'No matching check-ins were found.'
                : '$deletedCount $successLabel.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to clear check-ins: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  static String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '${local.year}-$month-$day $hour:$minute';
  }
}
