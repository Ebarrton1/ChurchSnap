import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/providers/member_providers.dart';
import 'admin_member_profile_screen.dart';

class AdminMembersScreen extends ConsumerWidget {
  const AdminMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberService = ref.read(memberServiceProvider);

    return ChurchSnapScreen(
      title: 'Members',
      subtitle: 'Church member directory',
      children: [
        StreamBuilder(
          stream: memberService.watchMembers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return AppCard(child: Text('Error: ${snapshot.error}'));
            }

            final members = snapshot.data ?? [];

            if (members.isEmpty) {
              return const AppCard(child: Text('No members found.'));
            }

            return Column(
              children: members.map((member) {
                return AppCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        member.displayName.isNotEmpty
                            ? member.displayName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(member.displayName),
                    subtitle: Text(member.email),
                    trailing: Chip(label: Text(member.role)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminMemberProfileScreen(member: member),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
