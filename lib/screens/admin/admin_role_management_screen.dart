import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/church_member.dart';
import '../../features/members/providers/member_providers.dart';

class AdminRoleManagementScreen extends ConsumerWidget {
  const AdminRoleManagementScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberService = ref.read(memberServiceByChurchProvider(churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Role Management',
        subtitle: 'Manage user access and permissions.',
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
                  child: Text('Unable to load roles: ${snapshot.error}'),
                );
              }

              final members = snapshot.data ?? <ChurchMember>[];

              if (members.isEmpty) {
                return const AppCard(child: Text('No members found.'));
              }

              return Column(
                children: members.map((member) {
                  final roles = <String>[
                    'member',
                    'volunteer',
                    'leader',
                    'groupLeader',
                    'ministryLeader',
                    'pastor',
                    'admin',
                  ];

                  if (!roles.contains(member.role)) {
                    roles.insert(0, member.role);
                  }

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
                      title: Text(member.displayName),
                      subtitle: Text(member.email),
                      trailing: DropdownButton<String>(
                        value: member.role,
                        items: roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(_roleLabel(role)),
                          );
                        }).toList(),
                        onChanged: (role) async {
                          if (role == null || role == member.role) {
                            return;
                          }

                          try {
                            await memberService.updateMember(
                              ChurchMember(
                                id: member.id,
                                displayName: member.displayName,
                                email: member.email,
                                phone: member.phone,
                                photoUrl: member.photoUrl,
                                role: role,
                                isActive: member.isActive,
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Unable to update role: '
                                  '$error',
                                ),
                              ),
                            );
                          }
                        },
                      ),
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

  String _roleLabel(String role) {
    return switch (role) {
      'groupLeader' => 'Group Leader',
      'ministryLeader' => 'Ministry Leader',
      'pastor' => 'Pastor',
      'admin' => 'Admin',
      'volunteer' => 'Volunteer',
      'leader' => 'Leader',
      _ => 'Member',
    };
  }
}
