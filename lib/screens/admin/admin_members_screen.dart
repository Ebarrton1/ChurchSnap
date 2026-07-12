import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/church_member.dart';
import '../../features/members/providers/member_providers.dart';
import 'admin_member_profile_screen.dart';

class AdminMembersScreen extends ConsumerWidget {
  const AdminMembersScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberService = ref.read(memberServiceByChurchProvider(churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Members',
        subtitle: 'Church member directory',
        children: [
          StreamBuilder<List<ChurchMember>>(
            stream: memberService.watchMembers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load members'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final members = snapshot.data ?? <ChurchMember>[];

              if (members.isEmpty) {
                return const AppCard(child: Text('No members found.'));
              }

              return Column(
                children: members.map((member) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(
                          member.displayName.isNotEmpty
                              ? member.displayName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(
                        member.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(member.email),
                      trailing: Chip(label: Text(member.role)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AdminMemberProfileScreen(
                              churchId: churchId,
                              member: member,
                            ),
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
      ),
    );
  }
}
