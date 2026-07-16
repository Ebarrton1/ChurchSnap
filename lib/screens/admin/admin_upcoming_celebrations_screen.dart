import 'package:flutter/material.dart';

import 'package:churchsnap/core/widgets/churchsnap_screen.dart';
import 'package:churchsnap/features/members/models/upcoming_celebration.dart';
import 'package:churchsnap/features/members/repositories/member_celebration_repository.dart';

class AdminUpcomingCelebrationsScreen extends StatefulWidget {
  const AdminUpcomingCelebrationsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  State<AdminUpcomingCelebrationsScreen> createState() =>
      _AdminUpcomingCelebrationsScreenState();
}

class _AdminUpcomingCelebrationsScreenState
    extends State<AdminUpcomingCelebrationsScreen> {
  late final MemberCelebrationRepository _repository;

  CelebrationFilter _filter = CelebrationFilter.all;
  CelebrationDateOrder _dateOrder = CelebrationDateOrder.soonestFirst;

  @override
  void initState() {
    super.initState();
    _repository = MemberCelebrationRepository(churchId: widget.churchId);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder<List<MemberCelebrationProfile>>(
        stream: _repository.watchProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ChurchSnapScreen(
              title: 'Upcoming Celebrations',
              subtitle: 'Birthdays and wedding anniversaries',
              children: [
                AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load upcoming celebrations'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                ),
              ],
            );
          }

          final profiles = snapshot.data ?? const <MemberCelebrationProfile>[];
          final celebrationsThisWeek = UpcomingCelebrationCalculator.calculate(
            profiles: profiles,
          );
          final fullCalendar = UpcomingCelebrationCalculator.sortAndFilter(
            celebrations: UpcomingCelebrationCalculator.annualCalendar(
              profiles: profiles,
            ),
            filter: _filter,
            order: _dateOrder,
          );
          final birthdayCount = celebrationsThisWeek
              .where((item) => item.type == CelebrationType.birthday)
              .length;
          final anniversaryCount = celebrationsThisWeek
              .where((item) => item.type == CelebrationType.weddingAnniversary)
              .length;

          return ChurchSnapScreen(
            title: 'Upcoming Celebrations',
            subtitle: 'Birthdays and wedding anniversaries',
            children: [
              const AppCard(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.privacy_tip_rounded)),
                  title: Text(
                    'Private administrator reminders',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    'Push alerts contain totals only. Names and dates '
                    'remain inside this administrator screen.',
                  ),
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: LinearProgressIndicator(),
                ),
              const SectionTitle(title: 'Next 7 Days'),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth >= 700
                      ? (constraints.maxWidth - 14) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _SummaryCard(
                          icon: Icons.cake_rounded,
                          value: birthdayCount,
                          label: 'Birthdays',
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _SummaryCard(
                          icon: Icons.favorite_rounded,
                          value: anniversaryCount,
                          label: 'Wedding Anniversaries',
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (celebrationsThisWeek.isEmpty)
                const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.event_available_rounded),
                    title: Text('No celebrations in the next 7 days'),
                    subtitle: Text(
                      'Upcoming birthdays and anniversaries will '
                      'appear here automatically.',
                    ),
                  ),
                )
              else
                ...celebrationsThisWeek.map(
                  (celebration) => _CelebrationCard(celebration: celebration),
                ),
              const SectionTitle(title: 'Celebration Calendar'),
              _CalendarControls(
                filter: _filter,
                dateOrder: _dateOrder,
                onFilterChanged: (value) {
                  setState(() {
                    _filter = value;
                  });
                },
                onDateOrderChanged: (value) {
                  setState(() {
                    _dateOrder = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (fullCalendar.isEmpty)
                const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.calendar_month_rounded),
                    title: Text('No matching celebration dates'),
                    subtitle: Text(
                      'Change the filter or add birthday and '
                      'anniversary dates for members.',
                    ),
                  ),
                )
              else
                ...fullCalendar.map(
                  (celebration) => _CelebrationCard(celebration: celebration),
                ),
              const SectionTitle(title: 'Manage Member Reminders'),
              if (profiles.isEmpty)
                const AppCard(child: Text('No active members are available.'))
              else
                ...profiles.map(
                  (profile) => _MemberReminderCard(
                    profile: profile,
                    onManage: () => _manageProfile(profile),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _manageProfile(MemberCelebrationProfile profile) async {
    final settings = await showDialog<MemberCelebrationSettings>(
      context: context,
      builder: (_) => _CelebrationSettingsDialog(profile: profile),
    );

    if (settings == null || !mounted) {
      return;
    }

    try {
      await _repository.saveSettings(settings);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Celebration reminder settings saved.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save celebration settings: $error')),
      );
    }
  }
}

class _CalendarControls extends StatelessWidget {
  const _CalendarControls({
    required this.filter,
    required this.dateOrder,
    required this.onFilterChanged,
    required this.onDateOrderChanged,
  });

  final CelebrationFilter filter;
  final CelebrationDateOrder dateOrder;
  final ValueChanged<CelebrationFilter> onFilterChanged;
  final ValueChanged<CelebrationDateOrder> onDateOrderChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filter',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          SegmentedButton<CelebrationFilter>(
            segments: const [
              ButtonSegment<CelebrationFilter>(
                value: CelebrationFilter.all,
                label: Text('All'),
                icon: Icon(Icons.celebration_rounded),
              ),
              ButtonSegment<CelebrationFilter>(
                value: CelebrationFilter.birthdays,
                label: Text('Birthdays'),
                icon: Icon(Icons.cake_rounded),
              ),
              ButtonSegment<CelebrationFilter>(
                value: CelebrationFilter.anniversaries,
                label: Text('Anniversaries'),
                icon: Icon(Icons.favorite_rounded),
              ),
            ],
            selected: <CelebrationFilter>{filter},
            onSelectionChanged: (selection) {
              onFilterChanged(selection.single);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<CelebrationDateOrder>(
            initialValue: dateOrder,
            decoration: const InputDecoration(
              labelText: 'Date order',
              prefixIcon: Icon(Icons.sort_rounded),
            ),
            items: const [
              DropdownMenuItem<CelebrationDateOrder>(
                value: CelebrationDateOrder.soonestFirst,
                child: Text('Soonest first'),
              ),
              DropdownMenuItem<CelebrationDateOrder>(
                value: CelebrationDateOrder.latestFirst,
                child: Text('Latest first'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onDateOrderChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          '$value',
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
        subtitle: Text(label),
      ),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({required this.celebration});

  final UpcomingCelebration celebration;

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(celebration.nextOccurrence);

    final timing = switch (celebration.daysUntil) {
      0 => 'Today',
      1 => 'Tomorrow',
      final days => 'In $days days',
    };

    final icon = celebration.type == CelebrationType.birthday
        ? Icons.cake_rounded
        : Icons.favorite_rounded;

    return AppCard(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          celebration.memberName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${celebration.typeLabel}\n$date'),
        isThreeLine: true,
        trailing: Chip(label: Text(timing)),
      ),
    );
  }
}

class _MemberReminderCard extends StatelessWidget {
  const _MemberReminderCard({required this.profile, required this.onManage});

  final MemberCelebrationProfile profile;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final birthday = _formatDate(context, profile.dateOfBirth);
    final anniversary = _formatDate(context, profile.weddingAnniversaryDate);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Text(
                profile.memberName.isEmpty
                    ? '?'
                    : profile.memberName[0].toUpperCase(),
              ),
            ),
            title: Text(
              profile.memberName.isEmpty
                  ? 'Unnamed Member'
                  : profile.memberName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              'Birthday: $birthday\n'
              'Anniversary: $anniversary',
            ),
            isThreeLine: true,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.cake_rounded, size: 18),
                label: Text(
                  profile.birthdayReminderEnabled
                      ? 'Birthday alert on'
                      : 'Birthday alert off',
                ),
              ),
              Chip(
                avatar: const Icon(Icons.favorite_rounded, size: 18),
                label: Text(
                  profile.anniversaryReminderEnabled
                      ? 'Anniversary alert on'
                      : 'Anniversary alert off',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onManage,
            icon: const Icon(Icons.edit_calendar_rounded),
            label: const Text('Manage Reminders'),
          ),
        ],
      ),
    );
  }

  static String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return 'Not provided';
    }

    return MaterialLocalizations.of(context).formatMediumDate(date);
  }
}

class _CelebrationSettingsDialog extends StatefulWidget {
  const _CelebrationSettingsDialog({required this.profile});

  final MemberCelebrationProfile profile;

  @override
  State<_CelebrationSettingsDialog> createState() =>
      _CelebrationSettingsDialogState();
}

class _CelebrationSettingsDialogState
    extends State<_CelebrationSettingsDialog> {
  late DateTime? _anniversaryDate;
  late bool _birthdayReminderEnabled;
  late bool _anniversaryReminderEnabled;

  @override
  void initState() {
    super.initState();
    _anniversaryDate = widget.profile.weddingAnniversaryDate;
    _birthdayReminderEnabled = widget.profile.birthdayReminderEnabled;
    _anniversaryReminderEnabled = widget.profile.anniversaryReminderEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final anniversaryLabel = _anniversaryDate == null
        ? 'Choose wedding anniversary'
        : MaterialLocalizations.of(context).formatMediumDate(_anniversaryDate!);

    return AlertDialog(
      title: Text(
        widget.profile.memberName.isEmpty
            ? 'Celebration Settings'
            : widget.profile.memberName,
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake_rounded),
                title: const Text('Date of birth'),
                subtitle: Text(
                  widget.profile.dateOfBirth == null
                      ? 'Not provided in the private member profile'
                      : MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(widget.profile.dateOfBirth!),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Birthday reminders'),
                subtitle: const Text(
                  'Notify administrators when the birthday '
                  'is within 7 days.',
                ),
                value: _birthdayReminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _birthdayReminderEnabled = value;
                  });
                },
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.celebration_rounded),
                title: const Text('Wedding anniversary'),
                subtitle: Text(anniversaryLabel),
                trailing: _anniversaryDate == null
                    ? const Icon(Icons.calendar_month_rounded)
                    : IconButton(
                        tooltip: 'Clear anniversary',
                        onPressed: () {
                          setState(() {
                            _anniversaryDate = null;
                          });
                        },
                        icon: const Icon(Icons.clear_rounded),
                      ),
                onTap: _chooseAnniversaryDate,
              ),
              if (!widget.profile.isMarried)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Anniversary alerts are sent only when the '
                    'private marital status is Married.',
                  ),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Anniversary reminders'),
                subtitle: const Text(
                  'Notify administrators when the anniversary '
                  'is within 7 days.',
                ),
                value: _anniversaryReminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _anniversaryReminderEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              MemberCelebrationSettings(
                memberId: widget.profile.memberId,
                weddingAnniversaryDate: _anniversaryDate,
                birthdayReminderEnabled: _birthdayReminderEnabled,
                anniversaryReminderEnabled: _anniversaryReminderEnabled,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _chooseAnniversaryDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final defaultDate = DateTime(today.year - 10, today.month, today.day);

    var initialDate = _anniversaryDate ?? defaultDate;

    if (initialDate.isAfter(today)) {
      initialDate = today;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'Select wedding anniversary',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _anniversaryDate = DateUtils.dateOnly(picked);
    });
  }
}
