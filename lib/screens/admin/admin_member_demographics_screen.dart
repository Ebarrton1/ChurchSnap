import 'package:flutter/material.dart';

import 'package:churchsnap/core/widgets/churchsnap_screen.dart';
import 'package:churchsnap/features/members/models/member_demographics_summary.dart';
import 'package:churchsnap/features/members/repositories/member_demographics_repository.dart';

class AdminMemberDemographicsScreen extends StatelessWidget {
  const AdminMemberDemographicsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    final repository = MemberDemographicsRepository(churchId: churchId);

    return Material(
      child: StreamBuilder<MemberDemographicsSummary>(
        stream: repository.watchSummary(),
        initialData: MemberDemographicsSummary.empty,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ChurchSnapScreen(
              title: 'Member Demographics',
              subtitle: 'Aggregate member insights',
              children: [
                AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load demographics'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                ),
              ],
            );
          }

          final summary = snapshot.data ?? MemberDemographicsSummary.empty;

          return ChurchSnapScreen(
            title: 'Member Demographics',
            subtitle: 'Aggregate member insights',
            children: [
              const AppCard(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.privacy_tip_rounded)),
                  title: Text(
                    'Private aggregate reporting',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    'This dashboard shows totals only. Visitors and inactive '
                    'records are excluded from member demographic counts.',
                  ),
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: LinearProgressIndicator(),
                ),
              const SectionTitle(title: 'Membership Snapshot'),
              _MetricGrid(
                items: [
                  _MetricData(
                    label: 'Active Members',
                    value: summary.totalMembers,
                    icon: Icons.groups_rounded,
                  ),
                  _MetricData(
                    label: 'Adults',
                    value: summary.adults,
                    icon: Icons.person_rounded,
                  ),
                  _MetricData(
                    label: 'Children & Youth',
                    value: summary.childrenAndYouth,
                    icon: Icons.child_care_rounded,
                  ),
                  _MetricData(
                    label: 'Complete Profiles',
                    value: summary.completeProfiles,
                    icon: Icons.verified_user_rounded,
                  ),
                ],
              ),
              const SectionTitle(title: 'Gender'),
              _BreakdownCard(
                total: summary.totalMembers,
                rows: summary.genderBreakdown,
              ),
              const SectionTitle(title: 'Marital Status'),
              _BreakdownCard(
                total: summary.totalMembers,
                rows: summary.maritalStatusBreakdown,
              ),
              const SectionTitle(title: 'Age Groups'),
              _BreakdownCard(
                total: summary.totalMembers,
                rows: summary.ageGroupBreakdown,
              ),
              const SectionTitle(title: 'Data Quality'),
              AppCard(
                child: Column(
                  children: [
                    _QualityRow(
                      label: 'Complete demographic profiles',
                      value: summary.completeProfiles,
                      total: summary.totalMembers,
                    ),
                    const Divider(height: 24),
                    _CountRow(
                      label: 'Missing any demographic information',
                      value: summary.missingAnyDemographic,
                    ),
                    _CountRow(
                      label: 'Missing date of birth',
                      value: summary.missingDateOfBirth,
                    ),
                    _CountRow(
                      label: 'Missing gender',
                      value: summary.missingGender,
                    ),
                    _CountRow(
                      label: 'Missing marital status',
                      value: summary.missingMaritalStatus,
                    ),
                    _CountRow(
                      label: 'Age not available',
                      value: summary.unknownAge,
                    ),
                  ],
                ),
              ),
              const SectionTitle(title: 'Excluded Records'),
              AppCard(
                child: Column(
                  children: [
                    _CountRow(
                      label: 'Visitors excluded',
                      value: summary.excludedVisitors,
                    ),
                    _CountRow(
                      label: 'Inactive records excluded',
                      value: summary.inactiveRecords,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.items});

  final List<_MetricData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth >= 700
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: AppCard(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(item.icon)),
                      title: Text(
                        '${item.value}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(item.label),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.total, required this.rows});

  final int total;
  final List<DemographicCount> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: rows
            .map((row) => _BreakdownRow(row: row, total: total))
            .toList(),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.row, required this.total});

  final DemographicCount row;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : row.count / total;
    final percentage = total == 0 ? '0%' : '${(fraction * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${row.count}  ($percentage)',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0).toDouble(),
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
          ),
        ],
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  const _QualityRow({
    required this.label,
    required this.value,
    required this.total,
  });

  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '$value of $total',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: fraction.clamp(0.0, 1.0).toDouble(),
          minHeight: 9,
          borderRadius: BorderRadius.circular(99),
        ),
      ],
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        '$value',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
      ),
    );
  }
}
