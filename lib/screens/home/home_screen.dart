import '../../features/worship/providers/worship_settings_providers.dart';
import '../../features/worship/models/worship_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/church_config.dart';
import '../../features/announcements/providers/announcement_providers.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/events/providers/event_providers.dart';
import '../../features/home/providers/home_appearance_provider.dart';
import '../../features/home/providers/pastor_appearance_provider.dart';
import '../../features/sermons/providers/sermon_providers.dart';
import '../../models/announcement.dart';
import '../../models/church_event.dart';
import '../../models/sermon.dart';
import '../sermons/sermon_detail_screen.dart';

import '../../core/utils/churchsnap_date_formatter.dart';

const Color _homeNavy = Color(0xFF062640);
const Color _homeAccent = Color(0xFF35B8FF);
const Color _homeCardText = Color(0xFF071A34);
const Color _homeMuted = Color(0xFF617086);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.authController,
    required this.onSelectTab,
  });

  final AuthController authController;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = authController.currentUser;
    final rawChurchId = member?.churchId.trim() ?? '';
    final churchId = rawChurchId.isEmpty ? 'demo-church' : rawChurchId;

    final displayName = member?.displayName.trim() ?? '';

    final firstName = displayName.isEmpty
        ? ''
        : displayName.split(RegExp(r'\s+')).first;

    final announcementsAsync = ref.watch(
      announcementsByChurchProvider(churchId),
    );

    final announcementCount = announcementsAsync.maybeWhen(
      data: (announcements) => announcements.length,
      orElse: () => 0,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF164D75), Color(0xFF0C3555), Color(0xFF08243D)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _HomeHeader(
              announcementCount: announcementCount,
              onNotifications: () {
                _showAnnouncements(context, churchId);
              },
            ),
            const SizedBox(height: 12),
            _WelcomeHero(
              churchId: churchId,
              firstName: firstName,
              onJoinUs: () => onSelectTab(3),
            ),
            const SizedBox(height: 12),
            _TodayServiceCard(churchId: churchId, onOpen: () => onSelectTab(3)),
            const SizedBox(height: 12),
            _QuickActions(
              onSermons: () => onSelectTab(1),
              onPrayer: () => onSelectTab(4),
              onEvents: () => onSelectTab(3),
              onGiving: () => onSelectTab(5),
            ),
            const SizedBox(height: 22),
            _UpcomingEventsSection(
              churchId: churchId,
              onViewAll: () => onSelectTab(3),
            ),
            const SizedBox(height: 22),
            _FeaturedMessageSection(churchId: churchId),
            const SizedBox(height: 22),
            _ChurchUpdateSection(
              churchId: churchId,
              onViewAll: () {
                _showAnnouncements(context, churchId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncements(BuildContext context, String churchId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _AnnouncementsSheet(churchId: churchId);
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.announcementCount,
    required this.onNotifications,
  });

  final int announcementCount;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'ChurchSnap',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: onNotifications,
                  iconSize: 30,
                  color: Colors.white,
                  tooltip: 'Church updates',
                  icon: const Icon(Icons.notifications_rounded),
                ),
                if (announcementCount > 0)
                  Positioned(
                    right: 3,
                    top: 3,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 17,
                        minHeight: 17,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE83E4D),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _homeNavy, width: 2),
                      ),
                      child: Text(
                        announcementCount > 9 ? '9+' : '$announcementCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHero extends ConsumerWidget {
  const _WelcomeHero({
    required this.churchId,
    required this.firstName,
    required this.onJoinUs,
  });

  final String churchId;
  final String firstName;
  final VoidCallback onJoinUs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worshipSettings = ref
        .watch(worshipSettingsProvider(churchId))
        .maybeWhen(
          data: (settings) => settings,
          orElse: () => const WorshipSettings(),
        );

    final homeAppearance = ref
        .watch(homeAppearanceProvider(churchId))
        .maybeWhen(
          data: (settings) => settings,
          orElse: () => const HomeAppearanceSettings(),
        );

    final visibleServices = worshipSettings.visibleServices;

    final mainService = visibleServices.isEmpty ? null : visibleServices.first;

    final configuredDay = mainService?.dayLabel.trim() ?? '';
    final normalizedDay = configuredDay.toLowerCase();

    final String mainWorshipDay;

    if (normalizedDay.contains('saturday') ||
        normalizedDay.contains('sabbath')) {
      mainWorshipDay = 'Saturday';
    } else if (normalizedDay.contains('sunday')) {
      mainWorshipDay = 'Sunday';
    } else if (configuredDay.isNotEmpty) {
      mainWorshipDay = configuredDay;
    } else {
      mainWorshipDay = 'Sunday';
    }

    final joinButtonText = 'Join Us This $mainWorshipDay For Main Worship';
    final welcomeText = firstName.isEmpty
        ? 'We\u2019re glad\nyou\u2019re here!'
        : 'We\u2019re glad you\u2019re\nhere, $firstName!';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onJoinUs,
        child: SizedBox(
          height: 270,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: _WelcomeHeroImage(
                  imageUrl: homeAppearance.backgroundImageUrl,
                ),
              ),

              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(19, 25, 19, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WELCOME',
                      style: TextStyle(
                        color: Color(0xFFBDEAFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      welcomeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        height: 1.04,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.9,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(
                      width: 205,
                      child: Text(
                        'Growing together in faith, love, and purpose.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: onJoinUs,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0879E6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        joinButtonText,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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

class _WelcomeHeroImage extends StatelessWidget {
  const _WelcomeHeroImage({required this.imageUrl});

  final String imageUrl;

  Widget _fallbackImage() {
    return Image.asset(
      'assets/home/home_hero_church.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = imageUrl.trim();

    if (normalizedUrl.isEmpty) {
      return _fallbackImage();
    }

    return Image.network(
      normalizedUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return _fallbackImage();
      },
      errorBuilder: (_, _, _) => _fallbackImage(),
    );
  }
}

class _TodayServiceCard extends ConsumerWidget {
  const _TodayServiceCard({required this.churchId, required this.onOpen});

  final String churchId;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref
        .watch(worshipSettingsProvider(churchId))
        .maybeWhen(
          data: (value) => value,
          orElse: () => const WorshipSettings(),
        );

    final pastorAppearance = ref
        .watch(pastorAppearanceProvider(churchId))
        .maybeWhen(
          data: (value) => value,
          orElse: () => const PastorAppearanceSettings(),
        );

    if (!settings.showSection) {
      return const SizedBox.shrink();
    }

    final configuredTitle = settings.sectionTitle.trim();
    final configuredSchedule = settings.scheduleSummary.trim();
    final configuredLeader = settings.leaderText.trim();

    final title = configuredTitle.isEmpty
        ? churchConfig.worshipTitle
        : configuredTitle;

    final schedule = configuredSchedule.isEmpty
        ? churchConfig.primaryServiceTime
        : configuredSchedule;

    final leader = configuredLeader.isEmpty
        ? 'Pastor and Worship Team'
        : configuredLeader;

    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: SizedBox(
          height: 180,
          child: Row(
            children: [
              Expanded(
                flex: 12,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 17, 5, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\u2019s Service',
                        style: TextStyle(
                          color: Color(0xFF193B78),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _homeCardText,
                          fontSize: 20,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      _ServiceInfoLine(
                        icon: Icons.schedule_rounded,
                        text: schedule,
                      ),
                      const SizedBox(height: 7),
                      _ServiceInfoLine(
                        icon: Icons.person_rounded,
                        text: leader,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: SizedBox.expand(
                  child: _PastorServiceImage(
                    imageUrl: pastorAppearance.imageUrl,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastorServiceImage extends StatelessWidget {
  const _PastorServiceImage({required this.imageUrl});

  final String imageUrl;

  Widget _fallbackImage() {
    return Image.asset(
      'assets/home/home_service_pastor.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = imageUrl.trim();

    if (normalizedUrl.isEmpty) {
      return _fallbackImage();
    }

    return Image.network(
      normalizedUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return _fallbackImage();
      },
      errorBuilder: (_, _, _) => _fallbackImage(),
    );
  }
}

class _ServiceInfoLine extends StatelessWidget {
  const _ServiceInfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: _homeCardText),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _homeCardText,
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onSermons,
    required this.onPrayer,
    required this.onEvents,
    required this.onGiving,
  });

  final VoidCallback onSermons;
  final VoidCallback onPrayer;
  final VoidCallback onEvents;
  final VoidCallback onGiving;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _HomeAction(label: 'Sermons', assetName: 'sermons', onTap: onSermons),
      _HomeAction(label: 'Prayer', assetName: 'prayer_hands', onTap: onPrayer),
      _HomeAction(label: 'Events', assetName: 'events', onTap: onEvents),
      _HomeAction(label: 'Giving', assetName: 'giving', onTap: onGiving),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
        childAspectRatio: 0.71,
      ),
      itemBuilder: (context, index) {
        return _QuickActionTile(action: actions[index]);
      },
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.label,
    required this.assetName,
    required this.onTap,
  });

  final String label;
  final String assetName;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final _HomeAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 5, 2, 7),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/icons/${action.assetName}.png',
                    width: 74,
                    height: 74,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, _, _) {
                      return const Icon(
                        Icons.apps_rounded,
                        color: _homeCardText,
                        size: 48,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                action.label,
                maxLines: 1,
                style: const TextStyle(
                  color: _homeCardText,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingEventsSection extends ConsumerWidget {
  const _UpcomingEventsSection({
    required this.churchId,
    required this.onViewAll,
  });

  final String churchId;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(publishedEventsByChurchProvider(churchId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DarkSectionHeader(
          title: 'Upcoming Events',
          action: 'View All',
          onAction: onViewAll,
        ),
        const SizedBox(height: 10),
        eventsAsync.when(
          loading: () => const _DarkLoadingCard(),
          error: (error, _) => _DarkMessageCard(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load events',
            subtitle: '$error',
          ),
          data: (events) {
            final beginningOfToday = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );

            final upcoming = events
                .where((event) {
                  final startDate = event.startDate;

                  return startDate == null ||
                      !startDate.isBefore(beginningOfToday);
                })
                .take(3)
                .toList();

            if (upcoming.isEmpty) {
              return const _DarkMessageCard(
                icon: Icons.event_available_rounded,
                title: 'No upcoming events',
                subtitle: 'New church events will appear here.',
              );
            }

            return Column(
              children: upcoming.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _UpcomingEventCard(event: event, onTap: onViewAll),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _UpcomingEventCard extends StatelessWidget {
  const _UpcomingEventCard({required this.event, required this.onTap});

  final ChurchEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _WhiteHomeCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _EventDateBadge(date: event.startDate),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _homeCardText,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  ChurchSnapDateFormatter.eventDateTime(
                    context,
                    event.startDate,
                    fallback: event.when,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _homeCardText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (event.location.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    event.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _homeMuted, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _homeMuted),
        ],
      ),
    );
  }
}

class _EventDateBadge extends StatelessWidget {
  const _EventDateBadge({required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final month = date == null ? 'TBA' : _monthAbbreviation(date!.month);

    final day = date == null ? '--' : '${date!.day}';

    return Container(
      width: 50,
      height: 58,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD7DCE4)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFD22F32),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              month,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  color: _homeCardText,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedMessageSection extends ConsumerWidget {
  const _FeaturedMessageSection({required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonsAsync = ref.watch(sermonsByChurchProvider(churchId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DarkSectionHeader(title: 'Featured Message'),
        const SizedBox(height: 10),
        sermonsAsync.when(
          loading: () => const _DarkLoadingCard(),
          error: (error, _) => _DarkMessageCard(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load sermons',
            subtitle: '$error',
          ),
          data: (sermons) {
            if (sermons.isEmpty) {
              return const _DarkMessageCard(
                icon: Icons.play_circle_outline_rounded,
                title: 'No featured message yet',
                subtitle: 'Published sermons will appear here.',
              );
            }

            final sermon = sermons.firstWhere(
              (item) => item.featured,
              orElse: () => sermons.first,
            );

            return _FeaturedMessageCard(sermon: sermon);
          },
        ),
      ],
    );
  }
}

class _FeaturedMessageCard extends StatelessWidget {
  const _FeaturedMessageCard({required this.sermon});

  final Sermon sermon;

  @override
  Widget build(BuildContext context) {
    final sermonDate = sermon.sermonDate ?? sermon.createdAt;
    final thumbnailUrl = _resolveSermonThumbnailUrl(sermon);

    final sermonDateText = sermonDate == null
        ? ''
        : MaterialLocalizations.of(
            context,
          ).formatFullDate(sermonDate.toLocal());

    final details = <String>[
      if (sermon.speaker.trim().isNotEmpty) sermon.speaker.trim(),
      if (sermonDateText.isNotEmpty) sermonDateText,
      if (sermon.scripture.trim().isNotEmpty) sermon.scripture.trim(),
    ].join(' | ');
    return _WhiteHomeCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SermonDetailScreen(sermon: sermon),
          ),
        );
      },
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 7.5,
            child: thumbnailUrl.isEmpty
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF153B67), Color(0xFF06182D)],
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/sermons.png',
                        width: 88,
                        height: 88,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: 70,
                          );
                        },
                      ),
                    ),
                  )
                : Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE6EEF8),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: _homeCardText,
                            size: 68,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sermon.featured)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 7),
                    child: Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Color(0xFF116FC8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                Text(
                  sermon.title,
                  style: const TextStyle(
                    color: _homeCardText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    details,
                    style: const TextStyle(color: _homeMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _resolveSermonThumbnailUrl(Sermon sermon) {
  final manualThumbnail = sermon.thumbnailUrl.trim();

  if (manualThumbnail.isNotEmpty) {
    return manualThumbnail;
  }

  final videoId = _extractYouTubeVideoId(sermon.videoUrl);

  if (videoId == null) {
    return '';
  }

  return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}

String? _extractYouTubeVideoId(String rawUrl) {
  final value = rawUrl.trim();

  if (value.isEmpty) {
    return null;
  }

  final normalizedUrl = value.contains('://') ? value : 'https://$value';

  final uri = Uri.tryParse(normalizedUrl);

  if (uri == null) {
    return null;
  }

  final host = uri.host.toLowerCase();
  String? videoId;

  if (host == 'youtu.be' || host.endsWith('.youtu.be')) {
    if (uri.pathSegments.isNotEmpty) {
      videoId = uri.pathSegments.first;
    }
  } else if (host == 'youtube.com' || host.endsWith('.youtube.com')) {
    if (uri.pathSegments.isEmpty) {
      videoId = uri.queryParameters['v'];
    } else {
      final firstSegment = uri.pathSegments.first.toLowerCase();

      if (firstSegment == 'watch') {
        videoId = uri.queryParameters['v'];
      } else if (<String>{'embed', 'shorts', 'live'}.contains(firstSegment)) {
        if (uri.pathSegments.length > 1) {
          videoId = uri.pathSegments[1];
        }
      } else {
        videoId = uri.queryParameters['v'];
      }
    }
  }

  final cleanedVideoId = videoId?.trim();

  if (cleanedVideoId == null ||
      !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(cleanedVideoId)) {
    return null;
  }

  return cleanedVideoId;
}

class _ChurchUpdateSection extends ConsumerWidget {
  const _ChurchUpdateSection({required this.churchId, required this.onViewAll});

  final String churchId;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(
      announcementsByChurchProvider(churchId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DarkSectionHeader(
          title: 'Church Updates',
          action: 'View All',
          onAction: onViewAll,
        ),
        const SizedBox(height: 10),
        announcementsAsync.when(
          loading: () => const _DarkLoadingCard(),
          error: (error, _) => _DarkMessageCard(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load updates',
            subtitle: '$error',
          ),
          data: (announcements) {
            if (announcements.isEmpty) {
              return const _DarkMessageCard(
                icon: Icons.campaign_outlined,
                title: 'No church updates',
                subtitle: 'New announcements will appear here.',
              );
            }

            return _WhiteHomeCard(
              onTap: onViewAll,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F3FF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.asset(
                      'assets/icons/notifications.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) {
                        return const Icon(
                          Icons.campaign_rounded,
                          color: _homeCardText,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcements.first.title,
                          style: const TextStyle(
                            color: _homeCardText,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          announcements.first.message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _homeMuted,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: _homeMuted),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DarkSectionHeader extends StatelessWidget {
  const _DarkSectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: _homeAccent,
              padding: const EdgeInsets.symmetric(horizontal: 5),
            ),
            child: Text(
              action!,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
}

class _WhiteHomeCard extends StatelessWidget {
  const _WhiteHomeCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(15),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(17);

    return Material(
      color: const Color(0xFFF8FAFC),
      clipBehavior: Clip.antiAlias,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _DarkLoadingCard extends StatelessWidget {
  const _DarkLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: const CircularProgressIndicator(color: _homeAccent),
    );
  }
}

class _DarkMessageCard extends StatelessWidget {
  const _DarkMessageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _homeAccent, size: 28),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFB7C6D7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsSheet extends ConsumerWidget {
  const _AnnouncementsSheet({required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(
      announcementsByChurchProvider(churchId),
    );

    return FractionallySizedBox(
      heightFactor: 0.74,
      child: Material(
        color: const Color(0xFFF5F7FB),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 11),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFC4CBD4),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 17, 12, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Church Updates',
                        style: TextStyle(
                          color: _homeCardText,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: announcementsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Unable to load church updates: $error',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  data: (announcements) {
                    if (announcements.isEmpty) {
                      return const Center(
                        child: Text('No church updates yet.'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: announcements.length,
                      separatorBuilder: (_, _) {
                        return const SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        return _AnnouncementSheetCard(
                          announcement: announcements[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementSheetCard extends StatelessWidget {
  const _AnnouncementSheetCard({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE6F3FF),
              child: Icon(announcement.icon, color: const Color(0xFF116FC8)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      color: _homeCardText,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    announcement.message,
                    style: const TextStyle(color: _homeMuted, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _monthAbbreviation(int month) {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  if (month < 1 || month > 12) {
    return 'TBA';
  }

  return months[month - 1];
}
