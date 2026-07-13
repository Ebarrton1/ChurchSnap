import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/app_roles.dart';
import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/church_member.dart';
import '../../features/members/providers/member_providers.dart';

class AdminRoleManagementScreen extends ConsumerWidget {
  const AdminRoleManagementScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberService = ref.read(memberServiceByChurchProvider(churchId));

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Material(
      child: ChurchSnapScreen(
        title: 'Role Management',
        subtitle: 'Manage approved ChurchSnap roles and permissions.',
        children: [
          const AppCard(
            child: ListTile(
              leading: Icon(Icons.security_rounded),
              title: Text('Protected role changes'),
              subtitle: Text(
                'Your own administrative role cannot be changed here. '
                'Every other role change requires confirmation.',
              ),
            ),
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<ChurchMember>>(
            stream: memberService.watchMembers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(),
                    ),
                  ),
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

              final activePrivilegedCount = members.where((member) {
                return member.isActive && AppRoles.isPrivileged(member.role);
              }).length;

              return Column(
                children: members.map((member) {
                  final isCurrentUser = member.id == currentUserId;

                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(
                          member.displayName.trim().isEmpty
                              ? '?'
                              : member.displayName.trim()[0].toUpperCase(),
                        ),
                      ),
                      title: Text(
                        member.displayName.trim().isEmpty
                            ? 'Unnamed Member'
                            : member.displayName.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${member.email}\n'
                        '${AppRoles.label(member.role)}'
                        ' • ${member.isActive ? 'Active' : 'Inactive'}',
                      ),
                      isThreeLine: true,
                      trailing: isCurrentUser
                          ? const Chip(
                              avatar: Icon(Icons.lock_rounded, size: 17),
                              label: Text('Current account'),
                            )
                          : PopupMenuButton<String>(
                              tooltip: 'Change role',
                              onSelected: (newRole) {
                                _requestRoleChange(
                                  context,
                                  ref,
                                  member: member,
                                  newRole: newRole,
                                  activePrivilegedCount: activePrivilegedCount,
                                );
                              },
                              itemBuilder: (_) {
                                return AppRoles.assignableRoles.map((role) {
                                  final isSelected = role == member.role;

                                  return PopupMenuItem<String>(
                                    value: role,
                                    enabled: !isSelected,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons.badge_outlined,
                                      ),
                                      title: Text(AppRoles.label(role)),
                                      subtitle: Text(
                                        AppRoles.description(role),
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              icon: const Icon(Icons.manage_accounts_rounded),
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

  Future<void> _requestRoleChange(
    BuildContext context,
    WidgetRef ref, {
    required ChurchMember member,
    required String newRole,
    required int activePrivilegedCount,
  }) async {
    if (!AppRoles.isValid(newRole) || newRole == member.role) {
      return;
    }

    final removesPrivilegedAccess =
        member.isActive &&
        AppRoles.isPrivileged(member.role) &&
        !AppRoles.isPrivileged(newRole);

    if (removesPrivilegedAccess && activePrivilegedCount <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ChurchSnap must retain at least one active pastor or '
            'administrator.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.admin_panel_settings_rounded, size: 40),
          title: const Text('Confirm role change'),
          content: Text(
            'Change ${member.displayName} from '
            '${AppRoles.label(member.role)} to '
            '${AppRoles.label(newRole)}?\n\n'
            '${AppRoles.description(newRole)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Change role'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(memberServiceByChurchProvider(churchId))
          .updateMember(
            ChurchMember(
              id: member.id,
              displayName: member.displayName,
              email: member.email,
              phone: member.phone,
              photoUrl: member.photoUrl,
              role: newRole,
              isActive: member.isActive,
            ),
          );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member.displayName} is now '
            '${AppRoles.label(newRole)}.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update role: $error')));
    }
  }
}
