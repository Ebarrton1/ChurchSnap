import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/app_roles.dart';
import '../models/web_admin_report_snapshot.dart';
import '../services/web_admin_report_builder.dart';

class WebAdminOperationsReports extends StatefulWidget {
  const WebAdminOperationsReports({super.key, required this.churchId});

  final String churchId;

  @override
  State<WebAdminOperationsReports> createState() =>
      _WebAdminOperationsReportsState();
}

class _WebAdminOperationsReportsState extends State<WebAdminOperationsReports> {
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _subscriptions = [];

  List<WebAdminReportSource> _members = const [];
  List<WebAdminReportSource> _prayerRequests = const [];
  List<WebAdminReportSource> _events = const [];
  List<WebAdminReportSource> _donations = const [];

  bool _membersLoaded = false;
  bool _prayerLoaded = false;
  bool _eventsLoaded = false;
  bool _donationsLoaded = false;
  Object? _error;
  WebAdminReportPeriod _period = WebAdminReportPeriod.thirtyDays;

  bool get _allLoaded =>
      _membersLoaded && _prayerLoaded && _eventsLoaded && _donationsLoaded;

  @override
  void initState() {
    super.initState();

    final church = FirebaseFirestore.instance
        .collection('churches')
        .doc(widget.churchId);

    _subscriptions
      ..add(
        church
            .collection('members')
            .snapshots()
            .listen(
              (snapshot) => _updateSource(
                snapshot: snapshot,
                assign: (items) => _members = items,
                markLoaded: () => _membersLoaded = true,
              ),
              onError: _handleError,
            ),
      )
      ..add(
        church
            .collection('prayer_requests')
            .snapshots()
            .listen(
              (snapshot) => _updateSource(
                snapshot: snapshot,
                assign: (items) => _prayerRequests = items,
                markLoaded: () => _prayerLoaded = true,
              ),
              onError: _handleError,
            ),
      )
      ..add(
        church
            .collection('events')
            .snapshots()
            .listen(
              (snapshot) => _updateSource(
                snapshot: snapshot,
                assign: (items) => _events = items,
                markLoaded: () => _eventsLoaded = true,
              ),
              onError: _handleError,
            ),
      )
      ..add(
        church
            .collection('donations')
            .snapshots()
            .listen(
              (snapshot) => _updateSource(
                snapshot: snapshot,
                assign: (items) => _donations = items,
                markLoaded: () => _donationsLoaded = true,
              ),
              onError: _handleError,
            ),
      );
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }

    super.dispose();
  }

  void _updateSource({
    required QuerySnapshot<Map<String, dynamic>> snapshot,
    required void Function(List<WebAdminReportSource> items) assign,
    required VoidCallback markLoaded,
  }) {
    if (!mounted) {
      return;
    }

    final items = snapshot.docs
        .map(
          (document) =>
              WebAdminReportSource(id: document.id, data: document.data()),
        )
        .toList(growable: false);

    setState(() {
      assign(items);
      markLoaded();
      _error = null;
    });
  }

  void _handleError(Object error, [StackTrace? stackTrace]) {
    if (!mounted) {
      return;
    }

    setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    if (!_allLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final report = WebAdminReportBuilder.build(
      members: _members,
      prayerRequests: _prayerRequests,
      events: _events,
      donations: _donations,
      period: _period,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operations Reports',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Read-only ministry, membership, giving, prayer, and '
                    'event indicators from current ChurchSnap records.',
                  ),
                ],
              );
              final period = SizedBox(
                width: 230,
                child: DropdownButtonFormField<WebAdminReportPeriod>(
                  initialValue: _period,
                  decoration: const InputDecoration(
                    labelText: 'Giving period',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: WebAdminReportPeriod.thirtyDays,
                      child: Text('Last 30 days'),
                    ),
                    DropdownMenuItem(
                      value: WebAdminReportPeriod.ninetyDays,
                      child: Text('Last 90 days'),
                    ),
                    DropdownMenuItem(
                      value: WebAdminReportPeriod.oneYear,
                      child: Text('Last 12 months'),
                    ),
                    DropdownMenuItem(
                      value: WebAdminReportPeriod.allTime,
                      child: Text('All recorded time'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _period = value);
                    }
                  },
                ),
              );

              if (constraints.maxWidth < 720) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [title, const SizedBox(height: 18), period],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 24),
                  period,
                ],
              );
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text(
                  'Some reporting records could not be loaded',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('$_error'),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ReportSummaryCard(
                label: 'Directory members',
                value: '${report.totalMembers}',
                detail: '${report.activeMembers} active',
                icon: Icons.people_alt_rounded,
              ),
              _ReportSummaryCard(
                label: 'Member follow-up',
                value: '${report.memberFollowUp}',
                detail: 'Profiles needing attention',
                icon: Icons.person_search_rounded,
              ),
              _ReportSummaryCard(
                label: 'Open prayer care',
                value: '${report.openPrayerRequests}',
                detail: '${report.resolvedPrayerRequests} resolved',
                icon: Icons.volunteer_activism_rounded,
              ),
              _ReportSummaryCard(
                label: 'Upcoming events',
                value: '${report.upcomingEvents.length}',
                detail: 'Next 30 days',
                icon: Icons.event_rounded,
              ),
              _ReportSummaryCard(
                label: 'Recorded gifts',
                value: '${report.recordedDonationCount}',
                detail: _givingSummary(report.givingByCurrency),
                icon: Icons.payments_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ReportSection(
            title: 'Giving by currency',
            subtitle: _periodLabel(_period),
            child: _MoneyBreakdown(values: report.givingByCurrency),
          ),
          const SizedBox(height: 16),
          _ReportSection(
            title: 'Giving by fund',
            subtitle: 'Currency and fund are kept separate',
            child: _MoneyBreakdown(values: report.givingByFund),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final roleSection = _ReportSection(
                title: 'Member roles',
                subtitle: 'Current directory role distribution',
                child: _CountBreakdown(
                  values: report.membersByRole,
                  labelBuilder: AppRoles.label,
                ),
              );
              final prayerSection = _ReportSection(
                title: 'Prayer statuses',
                subtitle: 'Current prayer-care workload',
                child: _CountBreakdown(
                  values: report.prayerByStatus,
                  labelBuilder: _titleCase,
                ),
              );

              if (constraints.maxWidth < 900) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    roleSection,
                    const SizedBox(height: 16),
                    prayerSection,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: roleSection),
                  const SizedBox(width: 16),
                  Expanded(child: prayerSection),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _ReportSection(
            title: 'Upcoming events',
            subtitle: 'Scheduled during the next 30 days',
            child: _UpcomingEvents(events: report.upcomingEvents),
          ),
        ],
      ),
    );
  }

  static String _periodLabel(WebAdminReportPeriod period) {
    return switch (period) {
      WebAdminReportPeriod.thirtyDays => 'Recorded during the last 30 days',
      WebAdminReportPeriod.ninetyDays => 'Recorded during the last 90 days',
      WebAdminReportPeriod.oneYear => 'Recorded during the last 12 months',
      WebAdminReportPeriod.allTime => 'All recorded giving',
    };
  }

  static String _givingSummary(Map<String, double> values) {
    if (values.isEmpty) {
      return 'No qualifying records';
    }

    if (values.length == 1) {
      final entry = values.entries.single;
      return '${entry.key} ${_formatAmount(entry.value)}';
    }

    return '${values.length} currencies';
  }

  static String _formatAmount(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final digits = parts.first;
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      final remaining = digits.length - index;

      if (index > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[index]);
    }

    return '${buffer.toString()}.${parts.last}';
  }

  static String _titleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 225,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(detail, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _MoneyBreakdown extends StatelessWidget {
  const _MoneyBreakdown({required this.values});

  final Map<String, double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const _EmptyBreakdown(message: 'No qualifying giving records.');
    }

    final maximum = values.values.reduce(
      (left, right) => left > right ? left : right,
    );

    return Column(
      children: values.entries
          .map((entry) {
            final currency = entry.key.split(' - ').first;
            final valueLabel =
                '$currency ${_WebAdminReportFormatting.amount(entry.value)}';
            final progress = maximum <= 0 ? 0.0 : entry.value / maximum;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(valueLabel),
                    ],
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _CountBreakdown extends StatelessWidget {
  const _CountBreakdown({required this.values, required this.labelBuilder});

  final Map<String, int> values;
  final String Function(String value) labelBuilder;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const _EmptyBreakdown(message: 'No records available.');
    }

    final maximum = values.values.reduce(
      (left, right) => left > right ? left : right,
    );

    return Column(
      children: values.entries
          .map((entry) {
            final progress = maximum <= 0 ? 0.0 : entry.value / maximum;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          labelBuilder(entry.key),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text('${entry.value}'),
                    ],
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _UpcomingEvents extends StatelessWidget {
  const _UpcomingEvents({required this.events});

  final List<WebAdminReportEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const _EmptyBreakdown(
        message: 'No upcoming events during the next 30 days.',
      );
    }

    return Column(
      children: events
          .take(10)
          .map((event) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.event_rounded)),
              title: Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(event.location),
              trailing: Text(_WebAdminReportFormatting.date(event.startsAt)),
            );
          })
          .toList(growable: false),
    );
  }
}

class _EmptyBreakdown extends StatelessWidget {
  const _EmptyBreakdown({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _WebAdminReportFormatting {
  const _WebAdminReportFormatting._();

  static String amount(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final digits = parts.first;
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      final remaining = digits.length - index;

      if (index > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[index]);
    }

    return '${buffer.toString()}.${parts.last}';
  }

  static String date(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');

    return '${local.year}-$month-$day';
  }
}
