import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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

  final ImagePicker _imagePicker = ImagePicker();

  bool _saving = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _member = widget.member;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recoverLostPhoto();
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberService = ref.read(
      memberServiceByChurchProvider(widget.churchId),
    );

    return Material(
      child: ChurchSnapScreen(
        title: _member.displayName.trim().isEmpty
            ? 'Member Profile'
            : _member.displayName.trim(),
        subtitle: 'Private member record',
        children: [
          _MemberIdentityCard(
            member: _member,
            uploadingPhoto: _uploadingPhoto,
            onChangePhoto: _uploadingPhoto ? null : _chooseProfilePhoto,
          ),
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
                'Legal name, home address, membership dates, birth date, '
                'marital information, and gender are stored separately from '
                'the public church directory and are available only to the '
                'member and authorized administrators.',
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Private member record updated.')),
      );
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

  Future<void> _chooseProfilePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 88,
        requestFullMetadata: false,
      );

      if (photo == null) {
        return;
      }

      await _uploadProfilePhoto(photo);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select profile picture: $error')),
      );
    }
  }

  Future<void> _recoverLostPhoto() async {
    try {
      final response = await _imagePicker.retrieveLostData();

      if (response.isEmpty || response.files == null) {
        return;
      }

      final files = response.files!;

      if (files.isNotEmpty) {
        await _uploadProfilePhoto(files.first);
      }
    } catch (_) {
      // A lost image is optional. The member can select it again.
    }
  }

  Future<void> _uploadProfilePhoto(XFile photo) async {
    if (_uploadingPhoto) {
      return;
    }

    setState(() {
      _uploadingPhoto = true;
    });

    try {
      final bytes = await photo.readAsBytes();

      const maximumBytes = 5 * 1024 * 1024;

      if (bytes.isEmpty) {
        throw StateError('The selected image is empty.');
      }

      if (bytes.length > maximumBytes) {
        throw StateError('The profile picture must be smaller than 5 MB.');
      }

      final contentType = _safeImageContentType(photo.mimeType);
      final extension = _fileExtensionForContentType(contentType);

      final storageReference = FirebaseStorage.instance
          .ref()
          .child('churches')
          .child(widget.churchId)
          .child('member_profile_photos')
          .child(_member.id)
          .child('profile.$extension');

      await storageReference.putData(
        bytes,
        SettableMetadata(
          contentType: contentType,
          cacheControl: 'public,max-age=3600',
          customMetadata: {'churchId': widget.churchId, 'memberId': _member.id},
        ),
      );

      final photoUrl = await storageReference.getDownloadURL();

      final updatedMember = ChurchMember(
        id: _member.id,
        displayName: _member.displayName,
        email: _member.email,
        phone: _member.phone,
        photoUrl: photoUrl,
        role: _member.role,
        isActive: _member.isActive,
      );

      await ref
          .read(memberServiceByChurchProvider(widget.churchId))
          .updateMember(updatedMember);

      if (!mounted) {
        return;
      }

      setState(() {
        _member = updatedMember;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to upload profile picture: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingPhoto = false;
        });
      }
    }
  }
}

class _MemberIdentityCard extends StatelessWidget {
  const _MemberIdentityCard({
    required this.member,
    required this.uploadingPhoto,
    required this.onChangePhoto,
  });

  final ChurchMember member;
  final bool uploadingPhoto;
  final VoidCallback? onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final photoUrl = member.photoUrl.trim();
    final displayName = member.displayName.trim().isEmpty
        ? 'Unnamed Member'
        : member.displayName.trim();

    return AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
            child: photoUrl.isEmpty
                ? Text(
                    displayName.isEmpty
                        ? '?'
                        : displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onChangePhoto,
            icon: uploadingPhoto
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_a_photo_rounded),
            label: Text(
              uploadingPhoto
                  ? 'Uploading picture...'
                  : photoUrl.isEmpty
                  ? 'Add Profile Picture'
                  : 'Change Profile Picture',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Private Member Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          _ProfileRow(
            icon: Icons.account_box_rounded,
            label: 'Full legal name',
            value: _valueOrNotProvided(details.fullName),
          ),
          _ProfileRow(
            icon: Icons.home_rounded,
            label: 'Home address',
            value: _valueOrNotProvided(details.formattedAddress),
          ),
          _ProfileRow(
            icon: Icons.card_membership_rounded,
            label: 'Membership date',
            value: _formatDate(context, details.membershipDate),
          ),
          _ProfileRow(
            icon: Icons.favorite_rounded,
            label: 'Marriage date',
            value: _formatDate(context, details.marriageDate),
          ),
          _ProfileRow(
            icon: Icons.cake_rounded,
            label: 'Date of birth',
            value: _formatDate(context, details.dateOfBirth),
          ),
          _ProfileRow(
            icon: Icons.favorite_border_rounded,
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
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
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
  late final TextEditingController _displayNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;

  late String _selectedRole;
  late bool _isActive;
  late DateTime? _membershipDate;
  late DateTime? _marriageDate;
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

    final existingNameParts = widget.member.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    final fallbackFirstName = existingNameParts.isEmpty
        ? ''
        : existingNameParts.first;

    final fallbackLastName = existingNameParts.length < 2
        ? ''
        : existingNameParts.last;

    final fallbackMiddleName = existingNameParts.length < 3
        ? ''
        : existingNameParts.sublist(1, existingNameParts.length - 1).join(' ');

    _displayNameController = TextEditingController(
      text: widget.member.displayName,
    );

    _firstNameController = TextEditingController(
      text: widget.details.firstName.trim().isEmpty
          ? fallbackFirstName
          : widget.details.firstName,
    );

    _middleNameController = TextEditingController(
      text: widget.details.middleName.trim().isEmpty
          ? fallbackMiddleName
          : widget.details.middleName,
    );

    _lastNameController = TextEditingController(
      text: widget.details.lastName.trim().isEmpty
          ? fallbackLastName
          : widget.details.lastName,
    );

    _emailController = TextEditingController(text: widget.member.email);

    _phoneController = TextEditingController(text: widget.member.phone);

    _addressLine1Controller = TextEditingController(
      text: widget.details.addressLine1,
    );

    _addressLine2Controller = TextEditingController(
      text: widget.details.addressLine2,
    );

    _cityController = TextEditingController(text: widget.details.city);

    _stateController = TextEditingController(
      text: widget.details.stateOrProvince,
    );

    _postalCodeController = TextEditingController(
      text: widget.details.postalCode,
    );

    _countryController = TextEditingController(text: widget.details.country);

    _selectedRole = _roles.contains(widget.member.role)
        ? widget.member.role
        : 'member';

    _isActive = widget.member.isActive;
    _membershipDate = widget.details.membershipDate;
    _marriageDate = widget.details.marriageDate;
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
    _displayNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Private Member Record'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _DialogSectionTitle(title: 'Member Identity'),
              TextField(
                controller: _displayNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Directory display name',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'First name',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _middleNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Middle name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Last name',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 18),
              const _DialogSectionTitle(title: 'Contact Information'),
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
              const SizedBox(height: 18),
              const _DialogSectionTitle(title: 'Home Address'),
              TextField(
                controller: _addressLine1Controller,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Street address',
                  prefixIcon: Icon(Icons.home_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressLine2Controller,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Apartment, suite, or unit',
                  prefixIcon: Icon(Icons.apartment_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stateController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'State or province',
                  prefixIcon: Icon(Icons.map_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _postalCodeController,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(
                  labelText: 'Postal or ZIP code',
                  prefixIcon: Icon(Icons.markunread_mailbox_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _countryController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  prefixIcon: Icon(Icons.public_rounded),
                ),
              ),
              const SizedBox(height: 18),
              const _DialogSectionTitle(title: 'Important Dates'),
              _DateSelectionTile(
                icon: Icons.card_membership_rounded,
                title: 'Membership date',
                value: _membershipDate,
                onTap: () => _chooseDate(
                  currentValue: _membershipDate,
                  helpText: 'Select membership date',
                  onSelected: (date) {
                    setState(() {
                      _membershipDate = date;
                    });
                  },
                ),
                onClear: _membershipDate == null
                    ? null
                    : () {
                        setState(() {
                          _membershipDate = null;
                        });
                      },
              ),
              _DateSelectionTile(
                icon: Icons.favorite_rounded,
                title: 'Date of marriage',
                value: _marriageDate,
                onTap: () => _chooseDate(
                  currentValue: _marriageDate,
                  helpText: 'Select date of marriage',
                  onSelected: (date) {
                    setState(() {
                      _marriageDate = date;
                    });
                  },
                ),
                onClear: _marriageDate == null
                    ? null
                    : () {
                        setState(() {
                          _marriageDate = null;
                        });
                      },
              ),
              _DateSelectionTile(
                icon: Icons.cake_rounded,
                title: 'Date of birth',
                value: _dateOfBirth,
                onTap: () => _chooseDate(
                  currentValue: _dateOfBirth,
                  helpText: 'Select date of birth',
                  onSelected: (date) {
                    setState(() {
                      _dateOfBirth = date;
                    });
                  },
                ),
                onClear: _dateOfBirth == null
                    ? null
                    : () {
                        setState(() {
                          _dateOfBirth = null;
                        });
                      },
              ),
              const SizedBox(height: 18),
              const _DialogSectionTitle(title: 'Member Classification'),
              DropdownButtonFormField<String>(
                initialValue: _maritalStatus,
                decoration: const InputDecoration(
                  labelText: 'Marital status',
                  prefixIcon: Icon(Icons.favorite_border_rounded),
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
                  prefixIcon: Icon(Icons.admin_panel_settings_rounded),
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
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

  Future<void> _chooseDate({
    required DateTime? currentValue,
    required String helpText,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final today = DateUtils.dateOnly(DateTime.now());

    var initialDate = currentValue ?? today;

    if (initialDate.isAfter(today)) {
      initialDate = today;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: helpText,
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    onSelected(DateUtils.dateOnly(selectedDate));
  }

  void _submit() {
    final firstName = _firstNameController.text.trim();
    final middleName = _middleNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();

    if (firstName.isEmpty) {
      setState(() {
        _errorMessage = 'Enter the member first name.';
      });
      return;
    }

    if (lastName.isEmpty) {
      setState(() {
        _errorMessage = 'Enter the member last name.';
      });
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Enter a valid email address.';
      });
      return;
    }

    final fullLegalName = [
      firstName,
      middleName,
      lastName,
    ].where((part) => part.isNotEmpty).join(' ');

    final requestedDisplayName = _displayNameController.text.trim();
    final displayName = requestedDisplayName.isEmpty
        ? fullLegalName
        : requestedDisplayName;

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
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          stateOrProvince: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          country: _countryController.text.trim(),
          membershipDate: _membershipDate,
          marriageDate: _marriageDate,
          dateOfBirth: _dateOfBirth,
          maritalStatus: _maritalStatus,
          gender: _gender,
        ),
      ),
    );
  }
}

class _DialogSectionTitle extends StatelessWidget {
  const _DialogSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _DateSelectionTile extends StatelessWidget {
  const _DateSelectionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final IconData icon;
  final String title;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(_formatDate(context, value)),
      trailing: onClear == null
          ? const Icon(Icons.calendar_month_rounded)
          : IconButton(
              tooltip: 'Clear date',
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded),
            ),
      onTap: onTap,
    );
  }
}

class _MemberEditResult {
  const _MemberEditResult({required this.member, required this.details});

  final ChurchMember member;
  final MemberProfileDetails details;
}

String _valueOrNotProvided(String value) {
  final cleanedValue = value.trim();
  return cleanedValue.isEmpty ? 'Not provided' : cleanedValue;
}

String _formatDate(BuildContext context, DateTime? value) {
  if (value == null) {
    return 'Not provided';
  }

  return MaterialLocalizations.of(context).formatMediumDate(value.toLocal());
}

String _safeImageContentType(String? contentType) {
  switch (contentType?.toLowerCase()) {
    case 'image/png':
      return 'image/png';
    case 'image/webp':
      return 'image/webp';
    case 'image/heic':
      return 'image/heic';
    case 'image/heif':
      return 'image/heif';
    case 'image/jpeg':
    case 'image/jpg':
    default:
      return 'image/jpeg';
  }
}

String _fileExtensionForContentType(String contentType) {
  switch (contentType) {
    case 'image/png':
      return 'png';
    case 'image/webp':
      return 'webp';
    case 'image/heic':
      return 'heic';
    case 'image/heif':
      return 'heif';
    case 'image/jpeg':
    default:
      return 'jpg';
  }
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
