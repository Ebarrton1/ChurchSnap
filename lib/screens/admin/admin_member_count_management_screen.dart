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

  bool _isRecalculating = false;
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
        title: 'Members Count',
        subtitle: 'Removed members are excluded automatically.',
        children: [
          const AppCard(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.people_alt_outlined)),
              title: Text(
                'Only removed members leave the count',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                'A member remains in Church Overview until an administrator '
                'uses Remove from Directory. No additional members are hidden '
                'or deleted by this screen.',
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
                  );

              return _buildSummary(summary);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(MemberCountSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _CountCard(
              label: 'Current Members Count',
              value: summary.overviewCount,
              icon: Icons.people_alt_rounded,
            ),
            _CountCard(
              label: 'Removed from Count',
              value: summary.removedCount,
              icon: Icons.person_off_rounded,
            ),
            _CountCard(
              label: 'Stored Member Records',
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
              FilledButton.icon(
                onPressed: _isRecalculating ? null : _recalculate,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Recalculate Members Count'),
              ),
              if (_lastRecalculatedAt != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Last recalculated: '
                  '${_formatDateTime(_lastRecalculatedAt!)}',
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const AppCard(
          child: ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text(
              'How to reduce the count',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              'Open Church Member Directory and choose Remove from Directory '
              'for the specific member. The overview count will decrease '
              'automatically. Restore the member to add the person back.',
            ),
          ),
        ),
        if (_isRecalculating) ...[
          const SizedBox(height: 14),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Future<void> _recalculate() async {
    setState(() {
      _isRecalculating = true;
    });

    try {
      final summary = await _repository.recalculate();

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
            'Members count recalculated: ${summary.overviewCount}. '
            '${summary.removedCount} removed member'
            '${summary.removedCount == 1 ? '' : 's'} excluded.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to recalculate members count: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRecalculating = false;
        });
      }
    }
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
      width: 175,
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
