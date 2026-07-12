import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/church_member.dart';
import '../../features/members/providers/member_providers.dart';

class AdminMemberProfileScreen extends ConsumerStatefulWidget {
  const AdminMemberProfileScreen({
    super.key,
    required this.churchId,
    required this.member,
  });

  final String churchId;
  final ChurchMember member;

  @override
  ConsumerState<AdminMemberProfileScreen> createState() =>
      _AdminMemberProfileScreenState();
}

class _AdminMemberProfileScreenState
    extends ConsumerState<AdminMemberProfileScreen> {
  late ChurchMember _member;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChurchSnapScreen(
        title: _member.displayName,
        subtitle: 'Member profile',
        children: [
          AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  child: Text(
                    _member.displayName.isNotEmpty
                        ? _member.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _member.displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(_member.email),
                const SizedBox(height: 12),
                Chip(label: Text(_member.role)),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _editMember,
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
              subtitle: Text(
                _member.phone.isEmpty ? 'Not added' : _member.phone,
              ),
            ),
          ),
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.verified_user_rounded),
              title: const Text('Status'),
              subtitle: Text(_member.isActive ? 'Active' : 'Inactive'),
            ),
          ),
          const AppCard(
            child: ListTile(
              leading: Icon(Icons.event_available_rounded),
              title: Text('Attendance History'),
              subtitle: Text('Available from the member profile.'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editMember() async {
    final updatedMember = await showDialog<ChurchMember>(
      context: context,
      builder: (_) => _EditMemberDialog(member: _member),
    );

    if (updatedMember == null || !mounted) {
      return;
    }

    try {
      await ref
          .read(memberServiceByChurchProvider(widget.churchId))
          .updateMember(updatedMember);

      if (!mounted) {
        return;
      }

      setState(() {
        _member = updatedMember;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member updated successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update member: $error')),
      );
    }
  }
}

class _EditMemberDialog extends StatefulWidget {
  const _EditMemberDialog({required this.member});

  final ChurchMember member;

  @override
  State<_EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<_EditMemberDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  late String _selectedRole;
  late bool _isActive;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.member.displayName);

    _emailController = TextEditingController(text: widget.member.email);

    _phoneController = TextEditingController(text: widget.member.phone);

    _selectedRole = widget.member.role;
    _isActive = widget.member.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles = <String>[
      'member',
      'volunteer',
      'leader',
      'groupLeader',
      'ministryLeader',
      'pastor',
      'admin',
    ];

    if (!roles.contains(_selectedRole)) {
      roles.insert(0, _selectedRole);
    }

    return AlertDialog(
      title: const Text('Edit Member'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(_roleLabel(role)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active member'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final displayName = _nameController.text.trim();

            if (displayName.isEmpty) {
              return;
            }

            Navigator.of(context).pop(
              ChurchMember(
                id: widget.member.id,
                displayName: displayName,
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
                photoUrl: widget.member.photoUrl,
                role: _selectedRole,
                isActive: _isActive,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
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
