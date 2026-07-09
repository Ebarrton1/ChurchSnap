import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/app_roles.dart';
import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/church_member.dart';
import '../../features/members/providers/member_providers.dart';

class AdminRoleManagementScreen extends ConsumerWidget {
  const AdminRoleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberService = ref.read(memberServiceProvider);

    return ChurchSnapScreen(
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
                    trailing: DropdownButton<String>(
                      value: member.role,
                      items: const [
                        DropdownMenuItem(
                          value: AppRoles.member,
                          child: Text('Member'),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.volunteer,
                          child: Text('Volunteer'),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.groupLeader,
                          child: Text('Group Leader'),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.ministryLeader,
                          child: Text('Ministry Leader'),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.pastor,
                          child: Text('Pastor'),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.admin,
                          child: Text('Admin'),
                        ),
                      ],
                      onChanged: (role) async {
                        if (role == null) return;

                        await ref
                            .read(memberServiceProvider)
                            .updateMember(
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
                      },
                    ),
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
