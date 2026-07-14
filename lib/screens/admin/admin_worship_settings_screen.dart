import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/worship/models/worship_service_entry.dart';
import '../../features/worship/models/worship_settings.dart';
import '../../features/worship/providers/worship_settings_providers.dart';

class AdminWorshipSettingsScreen extends ConsumerStatefulWidget {
  const AdminWorshipSettingsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  ConsumerState<AdminWorshipSettingsScreen> createState() =>
      _AdminWorshipSettingsScreenState();
}

class _AdminWorshipSettingsScreenState
    extends ConsumerState<AdminWorshipSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _sectionTitleController = TextEditingController();
  final _leaderTextController = TextEditingController();
  final _buttonTextController = TextEditingController();

  bool _initialized = false;
  bool _showSection = true;
  bool _saving = false;

  List<WorshipServiceEntry> _services = <WorshipServiceEntry>[];

  @override
  void dispose() {
    _sectionTitleController.dispose();
    _leaderTextController.dispose();
    _buttonTextController.dispose();
    super.dispose();
  }

  void _initialize(WorshipSettings settings) {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _showSection = settings.showSection;
    _services = List<WorshipServiceEntry>.from(settings.services);

    _sectionTitleController.text = settings.sectionTitle;
    _leaderTextController.text = settings.leaderText;
    _buttonTextController.text = settings.buttonText;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final settings = WorshipSettings(
      sectionTitle: _sectionTitleController.text.trim(),
      showSection: _showSection,
      leaderText: _leaderTextController.text.trim(),
      buttonText: _buttonTextController.text.trim(),
      services: List<WorshipServiceEntry>.from(_services),
    );

    try {
      await ref
          .read(worshipSettingsRepositoryProvider(widget.churchId))
          .saveSettings(settings);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worship settings saved successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save worship settings: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _addService() async {
    final result = await _showServiceDialog(
      context,
      WorshipServiceEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        dayLabel: '',
        time: '',
        order: _services.length,
      ),
      isNew: true,
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _services.add(result);
    });
  }

  Future<void> _editService(int index, WorshipServiceEntry service) async {
    final result = await _showServiceDialog(context, service, isNew: false);

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _services[index] = result;
    });
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);

      _services = _services
          .asMap()
          .entries
          .map((entry) => entry.value.copyWith(order: entry.key))
          .toList();
    });
  }

  void _moveService(int oldIndex, int newIndex) {
    setState(() {
      final service = _services.removeAt(oldIndex);
      _services.insert(newIndex, service);

      _services = _services
          .asMap()
          .entries
          .map((entry) => entry.value.copyWith(order: entry.key))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(worshipSettingsProvider(widget.churchId));

    return settingsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Worship Settings')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load worship settings.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (settings) {
        _initialize(settings);

        return Material(
          child: ChurchSnapScreen(
            title: 'Worship Settings',
            subtitle: 'Customize the worship section shown on the Home screen.',
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Show worship section',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: const Text(
                        'Turn off to hide this section from the Home screen.',
                      ),
                      value: _showSection,
                      onChanged: (value) {
                        setState(() {
                          _showSection = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sectionTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Section title',
                        hintText: 'Sabbath & Sunday Worship',
                        prefixIcon: Icon(Icons.church_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a section title.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _leaderTextController,
                      decoration: const InputDecoration(
                        labelText: 'Leader or team text',
                        hintText: 'Pastor and Worship Team',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _buttonTextController,
                      decoration: const InputDecoration(
                        labelText: 'Button text',
                        hintText: 'View Worship Details',
                        prefixIcon: Icon(Icons.touch_app_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: SectionTitle(title: 'Services')),
                  FilledButton.icon(
                    onPressed: _addService,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_services.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No worship services have been added.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _services.length,
                  onReorderItem: _moveService,
                  itemBuilder: (context, index) {
                    final service = _services[index];

                    return Card(
                      key: ValueKey(service.id),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.drag_handle_rounded),
                            title: Text(
                              service.title.trim().isEmpty
                                  ? 'Untitled service'
                                  : service.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(_serviceSummary(service)),
                            trailing: IconButton(
                              tooltip: 'Edit service',
                              onPressed: () => _editService(index, service),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                          ),
                          const Divider(height: 1),
                          Row(
                            children: [
                              Expanded(
                                child: SwitchListTile.adaptive(
                                  title: const Text('Visible'),
                                  value: service.enabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _services[index] = service.copyWith(
                                        enabled: value,
                                      );
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete service',
                                onPressed: () => _removeService(index),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Saving...' : 'Save Worship Settings'),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _serviceSummary(WorshipServiceEntry service) {
    final day = service.dayLabel.trim();
    final time = service.time.trim();
    final location = service.location.trim();

    final scheduleParts = <String>[
      day,
      time,
    ].where((value) => value.isNotEmpty).toList();

    final schedule = scheduleParts.join(' at ');

    if (schedule.isEmpty && location.isEmpty) {
      return 'No schedule information';
    }

    if (schedule.isEmpty) {
      return location;
    }

    if (location.isEmpty) {
      return schedule;
    }

    return '$schedule | $location';
  }
}

Future<WorshipServiceEntry?> _showServiceDialog(
  BuildContext context,
  WorshipServiceEntry service, {
  required bool isNew,
}) {
  return showDialog<WorshipServiceEntry>(
    context: context,
    builder: (_) {
      return _WorshipServiceDialog(service: service, isNew: isNew);
    },
  );
}

class _WorshipServiceDialog extends StatefulWidget {
  const _WorshipServiceDialog({required this.service, required this.isNew});

  final WorshipServiceEntry service;
  final bool isNew;

  @override
  State<_WorshipServiceDialog> createState() => _WorshipServiceDialogState();
}

class _WorshipServiceDialogState extends State<_WorshipServiceDialog> {
  static const List<String> _days = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
    'Custom',
  ];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _customDayController;
  late final TextEditingController _timeController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  late String _selectedDay;

  @override
  void initState() {
    super.initState();

    final existingDay = widget.service.dayLabel.trim();

    _selectedDay = _days.contains(existingDay) ? existingDay : 'Custom';

    _titleController = TextEditingController(text: widget.service.title);

    _customDayController = TextEditingController(
      text: _selectedDay == 'Custom' ? existingDay : '',
    );

    _timeController = TextEditingController(text: widget.service.time);

    _locationController = TextEditingController(text: widget.service.location);

    _descriptionController = TextEditingController(
      text: widget.service.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customDayController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _parseTime(_timeController.text) ?? TimeOfDay.now(),
      helpText: 'Select worship time',
    );

    if (!mounted || selectedTime == null) {
      return;
    }

    setState(() {
      _timeController.text = selectedTime.format(context);
    });
  }

  TimeOfDay? _parseTime(String value) {
    final normalized = value.trim().toUpperCase();

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
    ).firstMatch(normalized);

    if (match == null) {
      return null;
    }

    var hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final period = match.group(3);

    if (hour == null || minute == null || minute < 0 || minute > 59) {
      return null;
    }

    if (period != null) {
      if (hour < 1 || hour > 12) {
        return null;
      }

      if (period == 'AM' && hour == 12) {
        hour = 0;
      } else if (period == 'PM' && hour != 12) {
        hour += 12;
      }
    } else if (hour < 0 || hour > 23) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dayLabel = _selectedDay == 'Custom'
        ? _customDayController.text.trim()
        : _selectedDay;

    Navigator.of(context).pop(
      widget.service.copyWith(
        title: _titleController.text.trim(),
        dayLabel: dayLabel,
        time: _timeController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isNew ? 'Add Worship Service' : 'Edit Worship Service',
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Service name',
                    hintText: 'Sabbath Worship',
                    prefixIcon: Icon(Icons.church_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a service name.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDay,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Day of week',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  items: _days.map((day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedDay = value;
                    });
                  },
                ),
                if (_selectedDay == 'Custom') ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _customDayController,
                    decoration: const InputDecoration(
                      labelText: 'Custom day or schedule',
                      hintText: 'First Friday',
                      prefixIcon: Icon(Icons.edit_calendar_rounded),
                    ),
                    validator: (value) {
                      if (_selectedDay == 'Custom' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Enter the custom schedule.';
                      }

                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: _selectTime,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    hintText: '11:00 AM',
                    prefixIcon: const Icon(Icons.schedule_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'Select time',
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time_rounded),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Select a service time.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Main Sanctuary',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional worship details',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.isNew ? 'Add Service' : 'Save Changes'),
        ),
      ],
    );
  }
}
