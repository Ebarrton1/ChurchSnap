import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/church_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/churchsnap_screen.dart';
import '../../features/announcements/providers/announcement_providers.dart';
import '../../features/sermons/providers/sermon_providers.dart';
import '../../models/sermon.dart';
import '../giving/giving_screen.dart';
import '../prayer/prayer_screen.dart';
import '../sermons/sermon_detail_screen.dart';
import '../sermons/sermons_screen.dart';
import '../../features/auth/state/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = authController.currentUser;
    final rawChurchId = member?.churchId.trim() ?? '';
    final churchId = rawChurchId.isEmpty ? 'demo-church' : rawChurchId;
    final displayName = member?.displayName.trim() ?? '';

    final firstName = displayName.isEmpty
        ? ''
        : displayName.split(RegExp(r'\s+')).first;

    final greeting = _timeBasedGreeting();

    final personalizedTitle = firstName.isEmpty
        ? greeting
        : '$greeting, $firstName';

    return ChurchSnapScreen(
      title: personalizedTitle,
      subtitle: 'Stay connected with your church family.',
      children: [
        const _HeroWorshipCard(),
        const _HomeSectionHeader(
          title: 'Quick Actions',
          subtitle: 'Everything you need, one tap away',
        ),
        _QuickActionsGrid(churchId: churchId),
        const _HomeSectionHeader(
          title: 'Featured Message',
          subtitle: 'Watch or listen to the latest sermon',
        ),
        _FeaturedSermonSection(churchId: churchId),
        const _HomeSectionHeader(
          title: 'This Weekend',
          subtitle: 'Plan your worship experience',
        ),
        const _WeekendScheduleCard(),
        const _HomeSectionHeader(
          title: 'Announcements',
          subtitle: 'The latest news from your church',
        ),
        const _LiveAnnouncements(),
        const SizedBox(height: 16),
      ],
    );
  }
}

String _timeBasedGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return 'Good morning';
  }

  if (hour < 17) {
    return 'Good afternoon';
  }

  return 'Good evening';
}

class _HeroWorshipCard extends StatelessWidget {
  const _HeroWorshipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.church_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFF70E69A), size: 10),
                    SizedBox(width: 7),
                    Text(
                      'ChurchSnap Beta',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            churchConfig.worshipTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            churchConfig.primaryServiceTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  churchConfig.address,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('We look forward to worshiping with you!'),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today_rounded),
              label: const Text(
                'View Service Details',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        title: 'Prayer',
        subtitle: 'Share a request',
        icon: Image.asset(
          'assets/icons/prayer_hands.png',
          width: 30,
          height: 30,
          fit: BoxFit.contain,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PrayerScreen(churchId: churchId)),
          );
        },
      ),
      _QuickAction(
        title: 'Sermons',
        subtitle: 'Watch and listen',
        icon: const Icon(
          Icons.play_circle_fill_rounded,
          color: AppTheme.primary,
          size: 31,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SermonsScreen(churchId: churchId),
            ),
          );
        },
      ),
      _QuickAction(
        title: 'Giving',
        subtitle: 'Support the mission',
        icon: const Icon(
          Icons.volunteer_activism_rounded,
          color: AppTheme.primary,
          size: 31,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GivingScreen()),
          );
        },
      ),
      _QuickAction(
        title: 'Check In',
        subtitle: 'Open your profile QR',
        icon: const Icon(
          Icons.qr_code_2_rounded,
          color: AppTheme.primary,
          size: 31,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Open Profile and select My QR Code to check in.'),
            ),
          );
        },
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: actions.map((action) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: action.onTap,
            child: AppCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: action.icon,
                  ),
                  const Spacer(),
                  Text(
                    action.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;
}

class _FeaturedSermonSection extends ConsumerWidget {
  const _FeaturedSermonSection({required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonsAsync = ref.watch(sermonsByChurchProvider(churchId));
    return sermonsAsync.when(
      loading: () =>
          const AppCard(child: Center(child: CircularProgressIndicator())),
      error: (_, _) => const AppCard(
        child: ListTile(
          leading: Icon(Icons.error_outline_rounded),
          title: Text('Unable to load the featured sermon'),
        ),
      ),
      data: (sermons) {
        final published = sermons.where((sermon) => sermon.published).toList();
        if (published.isEmpty) {
          return const AppCard(
            child: ListTile(
              leading: Icon(Icons.play_circle_outline_rounded),
              title: Text('No featured sermon yet'),
              subtitle: Text('Published sermons will appear here.'),
            ),
          );
        }
        final sermon = published.firstWhere(
          (item) => item.featured,
          orElse: () => published.first,
        );
        return _FeaturedHomeSermonCard(sermon: sermon);
      },
    );
  }
}

class _FeaturedHomeSermonCard extends StatelessWidget {
  const _FeaturedHomeSermonCard({required this.sermon});

  final Sermon sermon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: sermon.thumbnailUrl.isEmpty
                  ? const ColoredBox(
                      color: Color(0xFFE9EAFB),
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppTheme.primary,
                          size: 72,
                        ),
                      ),
                    )
                  : Image.network(
                      sermon.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFE9EAFB),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              color: AppTheme.primary,
                              size: 72,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (sermon.featured)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: Icon(Icons.star_rounded, size: 17),
                    label: Text('Featured'),
                  ),
                ),
              if (sermon.duration.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.schedule_rounded, size: 17),
                  label: Text(sermon.duration),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sermon.title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          if (sermon.speaker.isNotEmpty || sermon.scripture.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              [
                if (sermon.speaker.isNotEmpty) sermon.speaker,
                if (sermon.scripture.isNotEmpty) sermon.scripture,
              ].join(' â€¢ '),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SermonDetailScreen(sermon: sermon),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Open Featured Sermon'),
            ),
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
        children: [
          _ScheduleTile(
            icon: Icons.wb_twilight_rounded,
            title: 'Sabbath Worship',
            day: 'Saturday',
            details: 'Sabbath School 9:45 AM â€¢ Worship 11:00 AM',
          ),
          Divider(height: 28),
          _ScheduleTile(
            icon: Icons.wb_sunny_rounded,
            title: 'Sunday Worship',
            day: 'Sunday',
            details: 'Worship Service 10:00 AM',
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.icon,
    required this.title,
    required this.day,
    required this.details,
  });

  final IconData icon;
  final String title;
  final String day;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(child: Icon(icon)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(
                day,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(details),
            ],
          ),
        ),
      ],
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
      error: (_, _) => const AppCard(
        child: ListTile(
          leading: Icon(Icons.error_outline_rounded),
          title: Text('Unable to load announcements'),
        ),
      ),
      data: (announcements) {
        if (announcements.isEmpty) {
          return const AppCard(
            child: ListTile(
              leading: Icon(Icons.campaign_outlined),
              title: Text('No announcements yet'),
              subtitle: Text('New church updates will appear here.'),
            ),
          );
        }
        final visibleAnnouncements = announcements.take(3);
        return Column(
          children: visibleAnnouncements.map((announcement) {
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(announcement.icon)),
                title: Text(
                  announcement.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  announcement.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
