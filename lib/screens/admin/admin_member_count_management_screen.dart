import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/member_count_summary.dart';
import '../../features/members/repositories/member_count_management_repository.dart';

class AdminMemberCountManagementScreen extends StatefulWidget {
  const AdminMemberCountManagementScreen({super.key, required this.churchId});

  final String churchId;

  @override
  State<AdminMemberCountManagementScreen> createState() =>
      _AdminMemberCountManagementScreenState();
}

class _AdminMemberCountManagementScreenState
    extends State<AdminMemberCountManagementScreen> {
  late final MemberCountManagementRepository _repository;
  late Stream<MemberCountSummary> _summaryStream;

  bool _isWorking = false;
  DateTime? _lastRecalculatedAt;

  @override
  void initState() {
    super.initState();
    _repository = MemberCountManagementRepository(churchId: widget.churchId);
    _summaryStream = _repository.watchSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChurchSnapScreen(
        title: 'Manage Members Count',
        subtitle: 'Control which member records appear in Church Overview.',
        children: [
          const AppCard(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.calculate_outlined)),
              title: Text(
                'Live and protected count',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                'Church Overview counts active, directory-visible congregation '
                'members. Removed members, inactive records, visitors, pastors, '
                'and administrators are excluded automatically.',
              ),
            ),
          ),
          const SizedBox(height: 14),
          StreamBuilder<MemberCountSummary>(
            stream: _summaryStream,
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
                    title: const Text('Unable to load member counts'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final summary =
                  snapshot.data ??
                  const MemberCountSummary(
                    totalRecords: 0,
                    overviewCount: 0,
                    removedCount: 0,
                    inactiveCount: 0,
                    protectedCount: 0,
                    visitorCount: 0,
                    explicitDemoCount: 0,
                  );

              return _buildManagementControls(summary);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManagementControls(MemberCountSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _CountCard(
              label: 'Overview Members',
              value: summary.overviewCount,
              icon: Icons.people_alt_rounded,
            ),
            _CountCard(
              label: 'Removed',
              value: summary.removedCount,
              icon: Icons.person_off_rounded,
            ),
            _CountCard(
              label: 'Inactive',
              value: summary.inactiveCount,
              icon: Icons.pause_circle_outline_rounded,
            ),
            _CountCard(
              label: 'Protected Staff',
              value: summary.protectedCount,
              icon: Icons.shield_outlined,
            ),
            _CountCard(
              label: 'Visitors',
              value: summary.visitorCount,
              icon: Icons.person_pin_circle_outlined,
            ),
            _CountCard(
              label: 'All Records',
              value: summary.totalRecords,
              icon: Icons.storage_rounded,
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Count maintenance',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _isWorking ? null : _recalculateNow,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Recalculate Count'),
              ),
              if (_lastRecalculatedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last checked: ${_formatDateTime(_lastRecalculatedAt!)}',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _isWorking || summary.explicitDemoCount == 0
                    ? null
                    : () => _confirmClearDemoMembers(summary.explicitDemoCount),
                icon: const Icon(Icons.science_outlined),
                label: Text(
                  'Clear Demo Members (${summary.explicitDemoCount})',
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _isWorking || summary.overviewCount == 0
                    ? null
                    : () => _confirmClearOverview(summary.overviewCount),
                icon: const Icon(Icons.person_remove_alt_1_rounded),
                label: Text('Clear Members Count (${summary.overviewCount})'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const AppCard(
          child: ListTile(
            leading: Icon(Icons.restore_rounded),
            title: Text(
              'Records are preserved',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              'Clearing the count hides qualifying members from the directory; '
              'it does not delete accounts, profiles, giving, attendance, RSVP, '
              'or prayer history. Restore members from Church Member Directory.',
            ),
          ),
        ),
        if (_isWorking) ...[
          const SizedBox(height: 14),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Future<void> _recalculateNow() async {
    setState(() {
      _isWorking = true;
    });

    try {
      final summary = await _repository.getSummary();

      if (!mounted) {
        return;
      }

      setState(() {
        _lastRecalculatedAt = DateTime.now();
        _summaryStream = _repository.watchSummary();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Church Overview member count: ${summary.overviewCount}.',
          ),
        ),
      );
    } catch (error) {
      _showError('Unable to recalculate the count: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  Future<void> _confirmClearDemoMembers(int count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Clear $count demo member${count == 1 ? '' : 's'}?'),
        content: const Text(
          'Only member records explicitly marked as demo or sample data will '
          'be removed from the directory. Protected administrator and pastor '
          'records will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.science_outlined),
            label: const Text('Clear Demo Members'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _runBulkAction(
      operation: _repository.clearExplicitDemoMembers,
      completedLabel: 'demo members cleared from the overview',
    );
  }

  Future<void> _confirmClearOverview(int count) async {
    final confirmationController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var canClear = false;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Clear the members count of $count?'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All active, visible congregation members will be hidden '
                    'from Church Overview and the directory. Administrator, '
                    'pastor, visitor, inactive, and already removed records '
                    'will not be changed.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmationController,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Type CLEAR MEMBERS to continue',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        canClear =
                            value.trim().toUpperCase() == 'CLEAR MEMBERS';
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: canClear
                    ? () => Navigator.of(dialogContext).pop(true)
                    : null,
                icon: const Icon(Icons.person_remove_alt_1_rounded),
                label: const Text('Clear Members Count'),
              ),
            ],
          ),
        );
      },
    );

    confirmationController.dispose();

    if (confirmed != true || !mounted) {
      return;
    }

    await _runBulkAction(
      operation: _repository.clearOverviewMemberCount,
      completedLabel: 'members removed from the overview count',
    );
  }

  Future<void> _runBulkAction({
    required Future<int> Function() operation,
    required String completedLabel,
  }) async {
    setState(() {
      _isWorking = true;
    });

    try {
      final changedCount = await operation();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            changedCount == 0
                ? 'No matching member records were found.'
                : '$changedCount $completedLabel.',
          ),
        ),
      );
    } catch (error) {
      _showError('Unable to update the members count: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: AppCard(
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
