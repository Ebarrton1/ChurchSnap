import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';

class HelpLegalAccountScreen extends StatelessWidget {
  const HelpLegalAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help, Legal & Account')),
      body: ChurchSnapScreen(
        title: 'Help, Legal & Account',
        subtitle:
            'Guidance for using ChurchSnap, privacy, support, and account requests.',
        children: const [
          _CenterIntroduction(),
          SectionTitle(title: 'Using ChurchSnap'),
          _NavigationCard(
            icon: Icons.rocket_launch_rounded,
            title: 'Getting Started',
            subtitle:
                'Learn how to connect, complete your profile, and use the app',
            screen: _InformationScreen(
              title: 'Getting Started',
              subtitle: 'A simple guide to your ChurchSnap account.',
              icon: Icons.rocket_launch_rounded,
              sections: <_InformationSection>[
                _InformationSection(
                  title: 'Connect to your church',
                  body:
                      'Use the church search, connection code, QR code, or '
                      'invitation provided by your church. Confirm the church '
                      'name before continuing.',
                ),
                _InformationSection(
                  title: 'Complete your member profile',
                  body:
                      'Open Profile and choose Complete or Edit My Details. '
                      'Add only accurate information that you are comfortable '
                      'sharing with authorized church administrators.',
                ),
                _InformationSection(
                  title: 'Use the main navigation',
                  body:
                      'Home contains current church information. Sermons, '
                      'Media, Events, Prayer, Giving, Profile, and Resources '
                      'provide access to the main ChurchSnap functions.',
                ),
                _InformationSection(
                  title: 'Keep your account protected',
                  body:
                      'Use a private email account, protect your password, '
                      'sign out on shared devices, and report unexpected '
                      'account activity to your church administrator.',
                ),
              ],
            ),
          ),
          SectionTitle(title: 'Privacy and Terms'),
          _NavigationCard(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            subtitle:
                'Review how ChurchSnap may handle church and member information',
            screen: _InformationScreen(
              title: 'Privacy Policy',
              subtitle:
                  'Launch-readiness privacy information for ChurchSnap users.',
              icon: Icons.privacy_tip_rounded,
              sections: <_InformationSection>[
                _InformationSection(
                  title: 'Information ChurchSnap may handle',
                  body:
                      'ChurchSnap may store account identity, church '
                      'connection, member profile details, attendance, group '
                      'and ministry participation, volunteer schedules, prayer '
                      'requests, giving history, and administrative activity.',
                ),
                _InformationSection(
                  title: 'How information is used',
                  body:
                      'Information is used to provide church communication, '
                      'member services, directory features, attendance, '
                      'ministry coordination, pastoral care, giving records, '
                      'security, and administrative oversight.',
                ),
                _InformationSection(
                  title: 'Access and responsibility',
                  body:
                      'Access is controlled through ChurchSnap account roles. '
                      'The church using ChurchSnap is responsible for assigning '
                      'appropriate staff access and handling congregation data '
                      'carefully.',
                ),
                _InformationSection(
                  title: 'Sensitive information',
                  body:
                      'Private prayer requests, protected member details, '
                      'giving records, and administrative records should only '
                      'be accessed for an authorized church purpose.',
                ),
                _InformationSection(
                  title: 'Your choices',
                  body:
                      'You may ask your church administrator to correct your '
                      'profile, deactivate your access, explain how your '
                      'information is used, or begin an account-data request.',
                ),
                _InformationSection(
                  title: 'Final release review',
                  body:
                      'This launch-readiness policy must be reviewed and '
                      'customized by the ChurchSnap operator before public '
                      'release. It is not a substitute for professional legal '
                      'review.',
                ),
              ],
            ),
          ),
          _NavigationCard(
            icon: Icons.gavel_rounded,
            title: 'Terms of Use',
            subtitle: 'Review responsible and permitted use of ChurchSnap',
            screen: _InformationScreen(
              title: 'Terms of Use',
              subtitle:
                  'Launch-readiness terms for members, visitors, and churches.',
              icon: Icons.gavel_rounded,
              sections: <_InformationSection>[
                _InformationSection(
                  title: 'Responsible use',
                  body:
                      'Use ChurchSnap only for lawful church, membership, '
                      'communication, worship, ministry, and administrative '
                      'purposes. Do not misuse another person\'s account or '
                      'attempt to bypass access controls.',
                ),
                _InformationSection(
                  title: 'Account accuracy',
                  body:
                      'Users should provide accurate account and profile '
                      'information. Churches are responsible for maintaining '
                      'appropriate administrator and staff permissions.',
                ),
                _InformationSection(
                  title: 'Member-provided content',
                  body:
                      'Prayer requests, profile information, RSVP responses, '
                      'group requests, and other submissions must be respectful '
                      'and appropriate for the connected church community.',
                ),
                _InformationSection(
                  title: 'Giving information',
                  body:
                      'ChurchSnap may display giving funds and verified giving '
                      'history. The church remains responsible for financial '
                      'receipts, accounting, tax guidance, and payment-provider '
                      'arrangements.',
                ),
                _InformationSection(
                  title: 'Service availability',
                  body:
                      'ChurchSnap may depend on internet access, Firebase, '
                      'device permissions, and third-party services. Temporary '
                      'interruptions or unavailable features may occur.',
                ),
                _InformationSection(
                  title: 'Final release review',
                  body:
                      'These launch-readiness terms require final operator and '
                      'legal review before publication in an app store.',
                ),
              ],
            ),
          ),
          SectionTitle(title: 'Support and Account'),
          _NavigationCard(
            icon: Icons.support_agent_rounded,
            title: 'Help and Support',
            subtitle:
                'Find the correct help for account or church-content issues',
            screen: _InformationScreen(
              title: 'Help and Support',
              subtitle: 'Steps for resolving common ChurchSnap issues.',
              icon: Icons.support_agent_rounded,
              sections: <_InformationSection>[
                _InformationSection(
                  title: 'Church content or membership',
                  body:
                      'Contact your church administrator when a sermon, event, '
                      'announcement, member record, group, ministry, schedule, '
                      'or giving record needs to be corrected.',
                ),
                _InformationSection(
                  title: 'Sign-in problems',
                  body:
                      'Confirm that you are using the correct email address and '
                      'church. Check your internet connection and complete any '
                      'required email verification.',
                ),
                _InformationSection(
                  title: 'What to include in a report',
                  body:
                      'Provide the screen name, what you expected, what '
                      'happened, your device type, and a screenshot when it is '
                      'safe to do so.',
                ),
                _InformationSection(
                  title: 'Protect sensitive information',
                  body:
                      'Do not send passwords, payment credentials, private '
                      'prayer details, or protected member information through '
                      'an unsecured public message.',
                ),
              ],
            ),
          ),
          _NavigationCard(
            icon: Icons.manage_accounts_rounded,
            title: 'Account & Data Requests',
            subtitle:
                'Learn how to correct, deactivate, or request deletion of data',
            screen: _InformationScreen(
              title: 'Account & Data Requests',
              subtitle:
                  'Guidance for managing your ChurchSnap account information.',
              icon: Icons.manage_accounts_rounded,
              sections: <_InformationSection>[
                _InformationSection(
                  title: 'Correct your information',
                  body:
                      'Use Complete or Edit My Details in Profile for supported '
                      'profile updates. Contact your church administrator when '
                      'a protected or historical record needs correction.',
                ),
                _InformationSection(
                  title: 'Deactivate access',
                  body:
                      'Ask your church administrator to deactivate access when '
                      'you leave the church, transfer membership, or no longer '
                      'need a ChurchSnap account.',
                ),
                _InformationSection(
                  title: 'Request account-data deletion',
                  body:
                      'Contact the administrator of the church connected to '
                      'your account. Identify the account email and clearly '
                      'state that you are requesting deletion of your '
                      'ChurchSnap account data.',
                ),
                _InformationSection(
                  title: 'Current deletion limitation',
                  body:
                      'ChurchSnap currently provides deletion guidance rather '
                      'than an automatic deletion button. A verified in-app '
                      'deletion workflow must be completed before public '
                      'app-store release.',
                ),
              ],
            ),
          ),
          SectionTitle(title: 'About'),
          _NavigationCard(
            icon: Icons.info_rounded,
            title: 'About ChurchSnap',
            subtitle: 'View the app purpose and current build information',
            screen: _InformationScreen(
              title: 'About ChurchSnap',
              subtitle:
                  'One connected place for church life and administration.',
              icon: Icons.church_rounded,
              sections: <_InformationSection>[
                _InformationSection(
                  title: 'ChurchSnap',
                  body:
                      'ChurchSnap is a Flutter and Firebase church application '
                      'for members, visitors, ministry teams, and authorized '
                      'church administrators.',
                ),
                _InformationSection(
                  title: 'Main functions',
                  body:
                      'ChurchSnap includes worship information, sermons, media, '
                      'events, prayer, giving, member profiles, resources, '
                      'groups, ministries, attendance, volunteer scheduling, '
                      'administration, reporting, and protected backups.',
                ),
                _InformationSection(
                  title: 'Current build',
                  body: 'Version 1.0.8, build 10.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterIntroduction extends StatelessWidget {
  const _CenterIntroduction();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            child: Icon(Icons.help_center_rounded, size: 38),
          ),
          SizedBox(height: 14),
          Text(
            'ChurchSnap Support Center',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Use this area to learn about ChurchSnap, review launch-readiness '
            'privacy and terms information, and understand account-data options.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.screen,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.of(
            context,
          ).push<void>(MaterialPageRoute<void>(builder: (_) => screen));
        },
      ),
    );
  }
}

class _InformationScreen extends StatelessWidget {
  const _InformationScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<_InformationSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ChurchSnapScreen(
        title: title,
        subtitle: subtitle,
        children: [
          AppCard(
            child: Center(
              child: CircleAvatar(radius: 34, child: Icon(icon, size: 38)),
            ),
          ),
          ...sections.map(
            (section) => AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    section.body,
                    style: const TextStyle(fontSize: 15, height: 1.45),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationSection {
  const _InformationSection({required this.title, required this.body});

  final String title;
  final String body;
}
