import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/church_member.dart';
import '../../features/members/providers/member_providers.dart';

class AdminMemberProfileScreen extends ConsumerWidget {
  final ChurchMember member;

  const AdminMemberProfileScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChurchSnapScreen(
      title: member.displayName,
      subtitle: 'Member profile',
      children: [
        AppCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                child: Text(
                  member.displayName.isNotEmpty
                      ? member.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                member.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(member.email),
              const SizedBox(height: 12),
              Chip(label: Text(member.role)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showEditMemberDialog(context, ref),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit Member'),
                ),
              ),
            ],
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.phone_rounded),
            title: const Text('Phone'),
            subtitle: Text(member.phone.isEmpty ? 'Not added' : member.phone),
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.verified_user_rounded),
            title: const Text('Status'),
            subtitle: Text(member.isActive ? 'Active' : 'Inactive'),
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.event_available_rounded),
            title: const Text('Attendance History'),
            subtitle: const Text('Coming soon'),
          ),
        ),
      ],
    );
  }

  void _showEditMemberDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: member.displayName);
    final emailController = TextEditingController(text: member.email);
    final phoneController = TextEditingController(text: member.phone);

    var selectedRole = member.role;
    var isActive = member.isActive;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Member'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(
                          value: 'member',
                          child: Text('Member'),
                        ),
                        DropdownMenuItem(
                          value: 'leader',
                          child: Text('Leader'),
                        ),
                        DropdownMenuItem(
                          value: 'pastor',
                          child: Text('Pastor'),
                        ),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedRole = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active member'),
                      value: isActive,
                      onChanged: (value) {
                        setDialogState(() => isActive = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final updatedMember = ChurchMember(
                      id: member.id,
                      displayName: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      photoUrl: member.photoUrl,
                      role: selectedRole,
                      isActive: isActive,
                    );

                    await ref
                        .read(memberServiceProvider)
                        .updateMember(updatedMember);

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    });
  }
}
