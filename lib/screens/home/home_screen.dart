import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/announcements/providers/announcement_providers.dart';
import 'package:flutter/material.dart';

import '../../core/constants/church_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/churchsnap_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChurchSnapScreen(
      title: churchConfig.welcomeGreeting,
      subtitle: 'Stay connected with your church family.',
      children: [
        _HeroWorshipCard(),
        SectionTitle(title: 'This Weekend'),
        _WeekendScheduleCard(),
        SectionTitle(title: 'Quick Actions'),
        _QuickActionsGrid(),
        SectionTitle(title: 'Announcements'),
        const _LiveAnnouncements(),
      ],
    );
  }
}

class _HeroWorshipCard extends StatelessWidget {
  const _HeroWorshipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.church_rounded, color: Colors.white, size: 44),
          const SizedBox(height: 18),
          Text(
            churchConfig.worshipTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${churchConfig.primaryServiceTime}\n${churchConfig.address}',
            style: const TextStyle(color: Colors.white70, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _WeekendScheduleCard extends StatelessWidget {
  const _WeekendScheduleCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Icon(Icons.wb_twilight_rounded)),
            title: Text('Sabbath Worship'),
            subtitle: Text(
              'Saturday • Sabbath School 9:45 AM • Worship 11:00 AM',
            ),
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Icon(Icons.wb_sunny_rounded)),
            title: Text('Sunday Worship'),
            subtitle: Text('Sunday • Worship Service 10:00 AM'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = const [
      (Icons.favorite_rounded, 'Prayer'),
      (Icons.event_available_rounded, 'RSVP'),
      (Icons.menu_book_rounded, 'Devotional'),
      (Icons.volunteer_activism_rounded, 'Serve'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.35,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: actions.map((item) {
        return AppCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(item.$1, color: AppTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.$2,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LiveAnnouncements extends ConsumerWidget {
  const _LiveAnnouncements();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return announcementsAsync.when(
      loading: () =>
          const AppCard(child: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const AppCard(child: Text('Unable to load announcements.')),
      data: (announcements) {
        if (announcements.isEmpty) {
          return const AppCard(child: Text('No announcements yet.'));
        }

        return Column(
          children: announcements.map((announcement) {
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(announcement.icon)),
                title: Text(announcement.title),
                subtitle: Text(announcement.message),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
