import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../settings/help_legal_account_screen.dart';

class AdminLaunchReadinessScreen extends StatelessWidget {
  const AdminLaunchReadinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Launch Readiness')),
      body: ChurchSnapScreen(
        title: 'Launch Readiness',
        subtitle:
            'Review the remaining requirements before public promotion and store release.',
        children: [
          const AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  child: Icon(Icons.verified_rounded, size: 38),
                ),
                SizedBox(height: 14),
                Text(
                  'ChurchSnap Release Checklist',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete and validate every item before publishing a public '
                  'Android release or beginning full-scale promotion.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Required Review'),
          const _ReadinessItem(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy and Terms',
            description:
                'Draft screens are available. Complete operator and legal review '
                'and replace draft wording before public release.',
            complete: false,
          ),
          const _ReadinessItem(
            icon: Icons.delete_forever_rounded,
            title: 'Verified Account Deletion',
            description:
                'Build and test a secure deletion workflow covering Firebase '
                'authentication and applicable church data.',
            complete: false,
          ),
          const _ReadinessItem(
            icon: Icons.support_agent_rounded,
            title: 'Published Support Contact',
            description:
                'Choose and publish an official ChurchSnap support email or '
                'support webpage.',
            complete: false,
          ),
          const _ReadinessItem(
            icon: Icons.church_rounded,
            title: 'Production Church Content',
            description:
                'Confirm church identity, connection settings, worship times, '
                'home images, sermons, events, resources, and administrator roles.',
            complete: false,
          ),
          const _ReadinessItem(
            icon: Icons.backup_rounded,
            title: 'Backup and Recovery',
            description:
                'Create an encrypted production backup and verify that the '
                'documented recovery procedure is available to administrators.',
            complete: true,
          ),
          const _ReadinessItem(
            icon: Icons.security_rounded,
            title: 'Security and Authorization',
            description:
                'Run Flutter analysis, Flutter tests, Firebase authorization '
                'tests, and review protected role assignments.',
            complete: false,
          ),
          const _ReadinessItem(
            icon: Icons.storefront_rounded,
            title: 'Play Store Materials',
            description:
                'Prepare the app description, screenshots, feature graphic, '
                'privacy-policy URL, content rating, and data-safety answers.',
            complete: false,
          ),
          const _ReadinessItem(
            icon: Icons.phone_android_rounded,
            title: 'Final Release Candidate',
            description:
                'Increase the version and build number, create the signed Android '
                'release, install it, and complete the final device smoke test.',
            complete: false,
          ),
          const SectionTitle(title: 'User-Facing Information'),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.help_center_rounded),
              ),
              title: const Text(
                'Review Help, Legal & Account',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Open the same launch-readiness information available in Profile',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const HelpLegalAccountScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessItem extends StatelessWidget {
  const _ReadinessItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.complete,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          child: Icon(complete ? Icons.check_rounded : icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(description),
        ),
        trailing: Tooltip(
          message: complete ? 'Completed' : 'Review required',
          child: Icon(
            complete
                ? Icons.check_circle_rounded
                : Icons.pending_actions_rounded,
            color: complete
                ? Colors.green.shade700
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
