import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:churchsnap/core/widgets/churchsnap_screen.dart';
import 'package:churchsnap/features/members/models/member_baptism_record.dart';
import 'package:churchsnap/features/members/providers/member_baptism_providers.dart';

class AdminRecentBaptismsScreen extends ConsumerWidget {
  const AdminRecentBaptismsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(memberBaptismRecordsProvider(churchId));

    return Material(
      child: recordsAsync.when(
        loading: () => const ChurchSnapScreen(
          title: 'Recent Baptisms',
          subtitle: 'Members baptized during the last 30 days',
          children: [
            AppCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => ChurchSnapScreen(
          title: 'Recent Baptisms',
          subtitle: 'Members baptized during the last 30 days',
          children: [
            AppCard(
              child: ListTile(
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text('Unable to load baptism records'),
                subtitle: Text('$error'),
              ),
            ),
          ],
        ),
        data: (records) {
          final recent = MemberBaptismCalculator.recent(records: records);

          return ChurchSnapScreen(
            title: 'Recent Baptisms',
            subtitle: 'Members baptized during the last 30 days',
            children: [
              AppCard(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.water_drop_rounded),
                  ),
                  title: Text(
                    '${recent.length}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: const Text('Recently baptized members'),
                ),
              ),
              const SectionTitle(title: 'Recently Baptized'),
              if (recent.isEmpty)
                const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.water_drop_outlined),
                    title: Text('No baptisms recorded in the last 30 days'),
                    subtitle: Text(
                      'Use Manage Baptism Dates below to record '
                      "a member's baptism.",
                    ),
                  ),
                )
              else
                ...recent.map((record) => _RecentBaptismCard(record: record)),
              const SectionTitle(title: 'Manage Baptism Dates'),
              const AppCard(
                child: ListTile(
                  leading: Icon(Icons.lock_rounded),
                  title: Text(
                    'Private member information',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    'Baptism dates are stored in the protected '
                    'private member profile and are available only '
                    'to authorized leaders.',
                  ),
                ),
              ),
              if (records.isEmpty)
                const AppCard(child: Text('No active members are available.'))
              else
                ...records.map(
                  (record) => _ManageBaptismCard(
                    record: record,
                    onChooseDate: () =>
                        _chooseDate(context: context, ref: ref, record: record),
                    onClearDate: record.baptismDate == null
                        ? null
                        : () => _clearDate(
                            context: context,
                            ref: ref,
                            record: record,
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _chooseDate({
    required BuildContext context,
    required WidgetRef ref,
    required MemberBaptismRecord record,
  }) async {
    final today = DateUtils.dateOnly(DateTime.now());
    var initialDate = record.baptismDate == null
        ? today
        : DateUtils.dateOnly(record.baptismDate!);

    if (initialDate.isAfter(today)) {
      initialDate = today;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'Select baptism date',
    );

    if (picked == null || !context.mounted) {
      return;
    }

    await _saveDate(
      context: context,
      ref: ref,
      record: record,
      baptismDate: DateUtils.dateOnly(picked),
    );
  }

  Future<void> _clearDate({
    required BuildContext context,
    required WidgetRef ref,
    required MemberBaptismRecord record,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear baptism date?'),
          content: Text(
            'Remove the baptism date for '
            '${record.memberName.isEmpty ? 'this member' : record.memberName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Clear Date'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await _saveDate(
      context: context,
      ref: ref,
      record: record,
      baptismDate: null,
    );
  }

  Future<void> _saveDate({
    required BuildContext context,
    required WidgetRef ref,
    required MemberBaptismRecord record,
    required DateTime? baptismDate,
  }) async {
    try {
      await ref
          .read(memberBaptismRepositoryProvider(churchId))
          .saveBaptismDate(memberId: record.memberId, baptismDate: baptismDate);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            baptismDate == null
                ? 'Baptism date cleared.'
                : 'Baptism date saved.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save baptism date: $error')),
      );
    }
  }
}

class _RecentBaptismCard extends StatelessWidget {
  const _RecentBaptismCard({required this.record});

  final MemberBaptismRecord record;

  @override
  Widget build(BuildContext context) {
    final baptismDate = record.baptismDate!;
    final formattedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(baptismDate);
    final daysAgo = MemberBaptismCalculator.daysSinceBaptism(
      baptismDate: baptismDate,
    );
    final timing = switch (daysAgo) {
      0 => 'Today',
      1 => 'Yesterday',
      final days => '$days days ago',
    };

    return AppCard(
      child: ListTile(
        leading: _MemberAvatar(record: record),
        title: Text(
          record.memberName.isEmpty ? 'Unnamed Member' : record.memberName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('Baptized $formattedDate'),
        trailing: Chip(label: Text(timing)),
      ),
    );
  }
}

class _ManageBaptismCard extends StatelessWidget {
  const _ManageBaptismCard({
    required this.record,
    required this.onChooseDate,
    required this.onClearDate,
  });

  final MemberBaptismRecord record;
  final VoidCallback onChooseDate;
  final VoidCallback? onClearDate;

  @override
  Widget build(BuildContext context) {
    final date = record.baptismDate;
    final formattedDate = date == null
        ? 'Not recorded'
        : MaterialLocalizations.of(context).formatMediumDate(date);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _MemberAvatar(record: record),
            title: Text(
              record.memberName.isEmpty ? 'Unnamed Member' : record.memberName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text('Baptism date: $formattedDate'),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onChooseDate,
                icon: const Icon(Icons.edit_calendar_rounded),
                label: Text(
                  date == null ? 'Set Baptism Date' : 'Change Baptism Date',
                ),
              ),
              if (onClearDate != null)
                TextButton.icon(
                  onPressed: onClearDate,
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Clear Date'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.record});

  final MemberBaptismRecord record;

  @override
  Widget build(BuildContext context) {
    final photoUrl = record.photoUrl.trim();
    final displayName = record.memberName.trim();

    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(photoUrl),
        onBackgroundImageError: (error, stackTrace) {},
      );
    }

    return CircleAvatar(
      child: Text(
        displayName.isEmpty ? '?' : displayName.substring(0, 1).toUpperCase(),
      ),
    );
  }
}
