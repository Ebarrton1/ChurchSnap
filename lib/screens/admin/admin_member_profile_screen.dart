import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/church_member.dart';
import '../../features/members/models/member_profile_details.dart';
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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
  }

  @override
  Widget build(BuildContext context) {
    final memberService = ref.read(
      memberServiceByChurchProvider(widget.churchId),
    );

    return Material(
      child: ChurchSnapScreen(
        title: _member.displayName.isEmpty
            ? 'Member Profile'
            : _member.displayName,
        subtitle: 'Private member record',
        children: [
          _MemberIdentityCard(member: _member),
          const SizedBox(height: 14),
          StreamBuilder<MemberProfileDetails>(
            stream: memberService.watchPrivateProfile(_member.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
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
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load personal details'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final details = snapshot.data ?? const MemberProfileDetails();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PersonalDetailsCard(details: details),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _saving ? null : () => _editMember(details),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit_rounded),
                    label: Text(_saving ? 'Saving...' : 'Edit Member Profile'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          const AppCard(
            child: ListTile(
              leading: Icon(Icons.lock_rounded),
              title: Text('Private information'),
              subtitle: Text(
                'Date of birth, marital status, and gender are stored '
                'separately from the church directory and are available '
                'only to the member and authorized administrators.',
              ),
            ),
          ),
          const SizedBox(height: 14),
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

  Future<void> _editMember(MemberProfileDetails details) async {
    final result = await showDialog<_MemberEditResult>(
      context: context,
      builder: (dialogContext) {
        return _EditMemberDialog(member: _member, details: details);
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref
          .read(memberServiceByChurchProvider(widget.churchId))
          .updateMemberWithPrivateProfile(
            member: result.member,
            details: result.details,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _member = result.member;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Member profile updated.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update member profile: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}

class _MemberIdentityCard extends StatelessWidget {
  const _MemberIdentityCard({required this.member});

  final ChurchMember member;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundImage: member.photoUrl.trim().isEmpty
                ? null
                : NetworkImage(member.photoUrl),
            child: member.photoUrl.trim().isEmpty
                ? Text(
                    member.displayName.trim().isEmpty
                        ? '?'
                        : member.displayName.trim()[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            member.displayName.trim().isEmpty
                ? 'Unnamed Member'
                : member.displayName.trim(),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _ProfileRow(
            icon: Icons.email_rounded,
            label: 'Email',
            value: member.email.trim().isEmpty
                ? 'Not provided'
                : member.email.trim(),
          ),
          _ProfileRow(
            icon: Icons.phone_rounded,
            label: 'Phone',
            value: member.phone.trim().isEmpty
                ? 'Not provided'
                : member.phone.trim(),
          ),
          _ProfileRow(
            icon: Icons.badge_rounded,
            label: 'Role',
            value: _roleLabel(member.role),
          ),
          _ProfileRow(
            icon: Icons.verified_user_rounded,
            label: 'Status',
            value: member.isActive ? 'Active' : 'Inactive',
          ),
        ],
      ),
    );
  }
}

class _PersonalDetailsCard extends StatelessWidget {
  const _PersonalDetailsCard({required this.details});

  final MemberProfileDetails details;

  @override
  Widget build(BuildContext context) {
    final dateOfBirth = details.dateOfBirth;
    final formattedDate = dateOfBirth == null
        ? 'Not provided'
        : MaterialLocalizations.of(context).formatMediumDate(dateOfBirth);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Personal Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _ProfileRow(
            icon: Icons.cake_rounded,
            label: 'Date of birth',
            value: formattedDate,
          ),
          _ProfileRow(
            icon: Icons.favorite_rounded,
            label: 'Marital status',
            value: _maritalStatusLabel(details.maritalStatus),
          ),
          _ProfileRow(
            icon: Icons.person_outline_rounded,
            label: 'Gender',
            value: _genderLabel(details.gender),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class _EditMemberDialog extends StatefulWidget {
  const _EditMemberDialog({required this.member, required this.details});

  final ChurchMember member;
  final MemberProfileDetails details;

  @override
  State<_EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<_EditMemberDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  late String _selectedRole;
  late bool _isActive;
  late DateTime? _dateOfBirth;
  late String _maritalStatus;
  late String _gender;

  String? _errorMessage;

  static const _roles = <String>[
    'member',
    'visitor',
    'volunteer',
    'groupLeader',
    'ministryLeader',
    'admin',
    'pastor',
  ];

  static const _maritalStatuses = <String>[
    '',
    'single',
    'married',
    'separated',
    'divorced',
    'widowed',
    'preferNotToSay',
  ];

  static const _genders = <String>[
    '',
    'male',
    'female',
    'nonBinary',
    'preferNotToSay',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.member.displayName);

    _emailController = TextEditingController(text: widget.member.email);

    _phoneController = TextEditingController(text: widget.member.phone);

    _selectedRole = _roles.contains(widget.member.role)
        ? widget.member.role
        : 'member';

    _isActive = widget.member.isActive;
    _dateOfBirth = widget.details.dateOfBirth;

    _maritalStatus = _maritalStatuses.contains(widget.details.maritalStatus)
        ? widget.details.maritalStatus
        : '';

    _gender = _genders.contains(widget.details.gender)
        ? widget.details.gender
        : '';
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
    final dateLabel = _dateOfBirth == null
        ? 'Choose date of birth'
        : MaterialLocalizations.of(context).formatMediumDate(_dateOfBirth!);

    return AlertDialog(
      title: const Text('Edit Member Profile'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake_rounded),
                title: const Text('Date of birth'),
                subtitle: Text(dateLabel),
                trailing: _dateOfBirth == null
                    ? const Icon(Icons.calendar_month_rounded)
                    : IconButton(
                        tooltip: 'Clear date',
                        onPressed: () {
                          setState(() {
                            _dateOfBirth = null;
                          });
                        },
                        icon: const Icon(Icons.clear_rounded),
                      ),
                onTap: _chooseDateOfBirth,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _maritalStatus,
                decoration: const InputDecoration(
                  labelText: 'Marital status',
                  prefixIcon: Icon(Icons.favorite_rounded),
                ),
                items: _maritalStatuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(_maritalStatusLabel(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _maritalStatus = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                items: _genders.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(_genderLabel(gender)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(_roleLabel(role)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value ?? 'member';
                  });
                },
              ),
              const SizedBox(height: 4),
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
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  Future<void> _chooseDateOfBirth() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final defaultDate = DateTime(today.year - 30, today.month, today.day);

    var initialDate = _dateOfBirth ?? defaultDate;

    if (initialDate.isAfter(today)) {
      initialDate = today;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'Select date of birth',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _dateOfBirth = DateUtils.dateOnly(picked);
    });
  }

  void _submit() {
    final displayName = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (displayName.isEmpty) {
      setState(() {
        _errorMessage = 'Enter the member name.';
      });
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Enter a valid email address.';
      });
      return;
    }

    Navigator.of(context).pop(
      _MemberEditResult(
        member: ChurchMember(
          id: widget.member.id,
          displayName: displayName,
          email: email,
          phone: _phoneController.text.trim(),
          photoUrl: widget.member.photoUrl,
          role: _selectedRole,
          isActive: _isActive,
        ),
        details: MemberProfileDetails(
          dateOfBirth: _dateOfBirth,
          maritalStatus: _maritalStatus,
          gender: _gender,
        ),
      ),
    );
  }
}

class _MemberEditResult {
  const _MemberEditResult({required this.member, required this.details});

  final ChurchMember member;
  final MemberProfileDetails details;
}

String _roleLabel(String role) {
  switch (role) {
    case 'groupLeader':
      return 'Group Leader';
    case 'ministryLeader':
      return 'Ministry Leader';
    case 'admin':
      return 'Administrator';
    case 'pastor':
      return 'Pastor';
    case 'volunteer':
      return 'Volunteer';
    case 'visitor':
      return 'Visitor';
    case 'member':
    default:
      return 'Member';
  }
}

String _maritalStatusLabel(String status) {
  switch (status) {
    case 'single':
      return 'Single';
    case 'married':
      return 'Married';
    case 'separated':
      return 'Separated';
    case 'divorced':
      return 'Divorced';
    case 'widowed':
      return 'Widowed';
    case 'preferNotToSay':
      return 'Prefer not to say';
    default:
      return 'Not specified';
  }
}

String _genderLabel(String gender) {
  switch (gender) {
    case 'male':
      return 'Male';
    case 'female':
      return 'Female';
    case 'nonBinary':
      return 'Non-binary';
    case 'preferNotToSay':
      return 'Prefer not to say';
    default:
      return 'Not specified';
  }
}
