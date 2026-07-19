import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/web_admin_action_item.dart';
import '../services/web_admin_action_center_builder.dart';

class WebAdminActionCenter extends StatefulWidget {
  const WebAdminActionCenter({
    super.key,
    required this.churchId,
    required this.onOpenMembers,
    required this.onOpenEvents,
    required this.onOpenPrayer,
    required this.onOpenGiving,
  });

  final String churchId;
  final VoidCallback onOpenMembers;
  final VoidCallback onOpenEvents;
  final VoidCallback onOpenPrayer;
  final VoidCallback onOpenGiving;

  @override
  State<WebAdminActionCenter> createState() => _WebAdminActionCenterState();
}

class _WebAdminActionCenterState extends State<WebAdminActionCenter> {
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _subscriptions = [];

  List<WebAdminActionSource> _prayerRequests = const [];
  List<WebAdminActionSource> _events = const [];
  List<WebAdminActionSource> _members = const [];
  List<WebAdminActionSource> _donations = const [];

  bool _prayerLoaded = false;
  bool _eventsLoaded = false;
  bool _membersLoaded = false;
  bool _donationsLoaded = false;
  Object? _error;
  String _search = '';
  WebAdminActionKind? _selectedKind;

  bool get _allLoaded =>
      _prayerLoaded && _eventsLoaded && _membersLoaded && _donationsLoaded;

  @override
  void initState() {
    super.initState();

    final church = FirebaseFirestore.instance
        .collection('churches')
        .doc(widget.churchId);

    _subscriptions
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
    required void Function(List<WebAdminActionSource> items) assign,
    required VoidCallback markLoaded,
  }) {
    if (!mounted) {
      return;
    }

    final items = snapshot.docs
        .map(
          (document) =>
              WebAdminActionSource(id: document.id, data: document.data()),
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

    setState(() {
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = WebAdminActionCenterBuilder.build(
      prayerRequests: _prayerRequests,
      events: _events,
      members: _members,
      donations: _donations,
    );
    final query = _search.trim().toLowerCase();
    final visibleItems = items
        .where((item) {
          final kindMatches =
              _selectedKind == null || item.kind == _selectedKind;
          final searchMatches =
              query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.detail.toLowerCase().contains(query);

          return kindMatches && searchMatches;
        })
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Action Center',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'One live queue for pastoral care, upcoming events, member '
                'follow-up, and giving exceptions.',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryCard(
                label: 'All actions',
                count: items.length,
                icon: Icons.task_alt_rounded,
                selected: _selectedKind == null,
                onTap: () => setState(() => _selectedKind = null),
              ),
              _SummaryCard(
                label: 'Prayer care',
                count: _count(items, WebAdminActionKind.prayer),
                icon: Icons.volunteer_activism_rounded,
                selected: _selectedKind == WebAdminActionKind.prayer,
                onTap: () =>
                    setState(() => _selectedKind = WebAdminActionKind.prayer),
              ),
              _SummaryCard(
                label: 'Events',
                count: _count(items, WebAdminActionKind.event),
                icon: Icons.event_rounded,
                selected: _selectedKind == WebAdminActionKind.event,
                onTap: () =>
                    setState(() => _selectedKind = WebAdminActionKind.event),
              ),
              _SummaryCard(
                label: 'Member follow-up',
                count: _count(items, WebAdminActionKind.member),
                icon: Icons.people_rounded,
                selected: _selectedKind == WebAdminActionKind.member,
                onTap: () =>
                    setState(() => _selectedKind = WebAdminActionKind.member),
              ),
              _SummaryCard(
                label: 'Giving',
                count: _count(items, WebAdminActionKind.giving),
                icon: Icons.payments_rounded,
                selected: _selectedKind == WebAdminActionKind.giving,
                onTap: () =>
                    setState(() => _selectedKind = WebAdminActionKind.giving),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
          child: TextField(
            onChanged: (value) => setState(() => _search = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              labelText: 'Search the action queue',
              hintText: 'Search names, requests, events, funds, or statuses',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text(
                  'Some Action Center records could not be loaded',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('$_error'),
              ),
            ),
          ),
        Expanded(
          child: !_allLoaded
              ? const Center(child: CircularProgressIndicator())
              : visibleItems.isEmpty
              ? const _EmptyActionCenter()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  itemCount: visibleItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = visibleItems[index];

                    return _ActionCard(
                      item: item,
                      onOpen: _openCallback(item.kind),
                    );
                  },
                ),
        ),
      ],
    );
  }

  int _count(List<WebAdminActionItem> items, WebAdminActionKind kind) {
    return items.where((item) => item.kind == kind).length;
  }

  VoidCallback _openCallback(WebAdminActionKind kind) {
    return switch (kind) {
      WebAdminActionKind.prayer => widget.onOpenPrayer,
      WebAdminActionKind.event => widget.onOpenEvents,
      WebAdminActionKind.member => widget.onOpenMembers,
      WebAdminActionKind.giving => widget.onOpenGiving,
    };
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 190,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: selected ? 3 : null,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(child: Icon(icon)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item, required this.onOpen});

  final WebAdminActionItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.kind) {
      WebAdminActionKind.prayer => Icons.volunteer_activism_rounded,
      WebAdminActionKind.event => Icons.event_rounded,
      WebAdminActionKind.member => Icons.person_search_rounded,
      WebAdminActionKind.giving => Icons.payments_rounded,
    };
    final section = switch (item.kind) {
      WebAdminActionKind.prayer => 'Prayer',
      WebAdminActionKind.event => 'Events',
      WebAdminActionKind.member => 'Members',
      WebAdminActionKind.giving => 'Giving',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final details = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(child: Icon(icon)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          _PriorityBadge(priority: item.priority),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(item.detail),
                      if (item.dueAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(item.dueAt!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );

            if (constraints.maxWidth < 680) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  details,
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text('Open $section'),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: details),
                const SizedBox(width: 18),
                FilledButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text('Open $section'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final WebAdminActionPriority priority;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (priority) {
      WebAdminActionPriority.urgent => (
        'Urgent',
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
      WebAdminActionPriority.normal => (
        'Follow up',
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
      WebAdminActionPriority.low => (
        'Upcoming',
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EmptyActionCenter extends StatelessWidget {
  const _EmptyActionCenter();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: const Card(
          margin: EdgeInsets.all(24),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.task_alt_rounded, size: 58),
                SizedBox(height: 14),
                Text(
                  'No matching actions',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'The live queue is clear, or the current search and filter '
                  'do not match any records.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
