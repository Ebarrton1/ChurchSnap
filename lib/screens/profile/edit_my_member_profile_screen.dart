import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/services/required_name_validator.dart';
import '../../features/members/models/member_self_profile.dart';
import '../../features/members/repositories/member_self_profile_repository.dart';

class EditMyMemberProfileScreen extends StatefulWidget {
  const EditMyMemberProfileScreen({
    super.key,
    required this.churchId,
    required this.userId,
    required this.accountEmail,
  });

  final String churchId;
  final String userId;
  final String accountEmail;

  @override
  State<EditMyMemberProfileScreen> createState() =>
      _EditMyMemberProfileScreenState();
}

class _EditMyMemberProfileScreenState extends State<EditMyMemberProfileScreen> {
  late final MemberSelfProfileRepository _repository;
  late final Future<MemberSelfProfileSnapshot> _profileFuture;

  @override
  void initState() {
    super.initState();

    _repository = MemberSelfProfileRepository(
      churchId: widget.churchId,
      userId: widget.userId,
    );
    _profileFuture = _repository.load();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChurchSnapScreen(
        title: 'Complete My Member Profile',
        subtitle: 'Save your own details to the Church Member Directory.',
        children: [
          FutureBuilder<MemberSelfProfileSnapshot>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const AppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load your member profile'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              return _MemberSelfProfileForm(
                repository: _repository,
                snapshot: snapshot.data!,
                fallbackEmail: widget.accountEmail,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MemberSelfProfileForm extends StatefulWidget {
  const _MemberSelfProfileForm({
    required this.repository,
    required this.snapshot,
    required this.fallbackEmail,
  });

  final MemberSelfProfileRepository repository;
  final MemberSelfProfileSnapshot snapshot;
  final String fallbackEmail;

  @override
  State<_MemberSelfProfileForm> createState() => _MemberSelfProfileFormState();
}

class _MemberSelfProfileFormState extends State<_MemberSelfProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;

  late bool _directoryEmailVisible;
  late bool _directoryPhoneVisible;
  late DateTime? _marriageDate;
  late DateTime? _dateOfBirth;
  late String _maritalStatus;
  late String _gender;

  Uint8List? _selectedPhotoBytes;
  String? _selectedPhotoContentType;
  bool _saving = false;
  String? _errorMessage;

  static const List<String> _maritalStatuses = <String>[
    '',
    'single',
    'married',
    'separated',
    'divorced',
    'widowed',
    'preferNotToSay',
  ];

  static const List<String> _genders = <String>[
    '',
    'male',
    'female',
    'nonBinary',
    'preferNotToSay',
  ];

  @override
  void initState() {
    super.initState();

    final details = widget.snapshot.details;

    _firstNameController = TextEditingController(text: details.firstName);
    _middleNameController = TextEditingController(text: details.middleName);
    _lastNameController = TextEditingController(text: details.lastName);
    _phoneController = TextEditingController(text: widget.snapshot.phone);
    _addressLine1Controller = TextEditingController(text: details.addressLine1);
    _addressLine2Controller = TextEditingController(text: details.addressLine2);
    _cityController = TextEditingController(text: details.city);
    _stateController = TextEditingController(text: details.stateOrProvince);
    _postalCodeController = TextEditingController(text: details.postalCode);
    _countryController = TextEditingController(text: details.country);

    _directoryEmailVisible = widget.snapshot.directoryEmailVisible;
    _directoryPhoneVisible = widget.snapshot.directoryPhoneVisible;
    _marriageDate = details.marriageDate;
    _dateOfBirth = details.dateOfBirth;
    _maritalStatus = _maritalStatuses.contains(details.maritalStatus)
        ? details.maritalStatus
        : '';
    _gender = _genders.contains(details.gender) ? details.gender : '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
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
    final email = widget.snapshot.email.trim().isEmpty
        ? widget.fallbackEmail.trim()
        : widget.snapshot.email.trim();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.snapshot.directoryVisible) ...[
            const AppCard(
              child: ListTile(
                leading: Icon(Icons.person_off_rounded),
                title: Text(
                  'Currently removed from the directory',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  'You may update your profile, but it will remain hidden '
                  'until an administrator restores it.',
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _FormSectionTitle(
                  title: 'Directory Profile',
                  subtitle:
                      'These approved details update the member directory automatically.',
                ),
                _ProfilePhotoEditor(
                  existingPhotoUrl: widget.snapshot.photoUrl,
                  selectedPhotoBytes: _selectedPhotoBytes,
                  onSelectPhoto: _saving ? null : _choosePhoto,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _firstNameController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const <String>[AutofillHints.givenName],
                  decoration: const InputDecoration(
                    labelText: 'First name *',
                    prefixIcon: Icon(Icons.person_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    return RequiredNameValidator.validatePart(
                      value ?? '',
                      label: 'First name',
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _middleNameController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Middle name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().length > 60) {
                      return 'Middle name must be 60 characters or fewer.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const <String>[AutofillHints.familyName],
                  decoration: const InputDecoration(
                    labelText: 'Last name *',
                    prefixIcon: Icon(Icons.people_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    return RequiredNameValidator.validatePart(
                      value ?? '',
                      label: 'Last name',
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: email,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Account email',
                    prefixIcon: Icon(Icons.email_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  enabled: !_saving,
                  keyboardType: TextInputType.phone,
                  autofillHints: const <String>[AutofillHints.telephoneNumber],
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().length > 40) {
                      return 'Phone number must be 40 characters or fewer.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _directoryEmailVisible,
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _directoryEmailVisible = value;
                          });
                        },
                  title: const Text('Show my email in the directory'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _directoryPhoneVisible,
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _directoryPhoneVisible = value;
                          });
                        },
                  title: const Text('Show my phone in the directory'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _FormSectionTitle(
                  title: 'Private Member Details',
                  subtitle:
                      'These details are stored separately and do not appear in the directory.',
                ),
                TextFormField(
                  controller: _addressLine1Controller,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Street address',
                    prefixIcon: Icon(Icons.home_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressLine2Controller,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Apartment, suite, or unit',
                    prefixIcon: Icon(Icons.apartment_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stateController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'State or province',
                    prefixIcon: Icon(Icons.map_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _postalCodeController,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Postal or ZIP code',
                    prefixIcon: Icon(Icons.markunread_mailbox_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _countryController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.public_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                _DateSelectionTile(
                  icon: Icons.cake_rounded,
                  title: 'Date of birth',
                  value: _dateOfBirth,
                  enabled: !_saving,
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
                _DateSelectionTile(
                  icon: Icons.favorite_rounded,
                  title: 'Marriage date',
                  value: _marriageDate,
                  enabled: !_saving,
                  onTap: () => _chooseDate(
                    currentValue: _marriageDate,
                    helpText: 'Select marriage date',
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
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _maritalStatus,
                  decoration: const InputDecoration(
                    labelText: 'Marital status',
                    prefixIcon: Icon(Icons.favorite_border_rounded),
                    border: OutlineInputBorder(),
                  ),
                  items: _maritalStatuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(_maritalStatusLabel(status)),
                    );
                  }).toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
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
                    border: OutlineInputBorder(),
                  ),
                  items: _genders.map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(_genderLabel(gender)),
                    );
                  }).toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _gender = value ?? '';
                          });
                        },
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_saving ? 'Saving Profile...' : 'Save My Profile'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Church role, active status, membership date, baptism records, '
            'and directory removal or restoration remain administrator-controlled.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _choosePhoto() async {
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

      final bytes = await photo.readAsBytes();

      if (bytes.isEmpty) {
        throw StateError('The selected profile picture is empty.');
      }

      if (bytes.length > MemberSelfProfileRepository.maximumPhotoBytes) {
        throw StateError('The profile picture must be smaller than 5 MB.');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedPhotoBytes = bytes;
        _selectedPhotoContentType = photo.mimeType;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _friendlyError(error);
      });
    }
  }

  Future<void> _chooseDate({
    required DateTime? currentValue,
    required String helpText,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final today = DateUtils.dateOnly(DateTime.now());
    var initialDate = currentValue ?? DateTime(today.year - 30);

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

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    final draft = MemberSelfProfileDraft(
      firstName: _firstNameController.text,
      middleName: _middleNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      directoryEmailVisible: _directoryEmailVisible,
      directoryPhoneVisible: _directoryPhoneVisible,
      addressLine1: _addressLine1Controller.text,
      addressLine2: _addressLine2Controller.text,
      city: _cityController.text,
      stateOrProvince: _stateController.text,
      postalCode: _postalCodeController.text,
      country: _countryController.text,
      marriageDate: _marriageDate,
      dateOfBirth: _dateOfBirth,
      maritalStatus: _maritalStatus,
      gender: _gender,
    );

    final validationError = draft.validate();

    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await widget.repository.save(
        draft: draft,
        existingPhotoUrl: widget.snapshot.photoUrl,
        photoBytes: _selectedPhotoBytes,
        photoContentType: _selectedPhotoContentType,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  static String _friendlyError(Object error) {
    final text = error.toString();

    if (text.startsWith('Invalid argument(s): ')) {
      return text.substring('Invalid argument(s): '.length);
    }

    if (text.startsWith('Bad state: ')) {
      return text.substring('Bad state: '.length);
    }

    return 'Unable to save your member profile. Check your connection and try again.';
  }
}

class _ProfilePhotoEditor extends StatelessWidget {
  const _ProfilePhotoEditor({
    required this.existingPhotoUrl,
    required this.selectedPhotoBytes,
    required this.onSelectPhoto,
  });

  final String existingPhotoUrl;
  final Uint8List? selectedPhotoBytes;
  final VoidCallback? onSelectPhoto;

  @override
  Widget build(BuildContext context) {
    Widget photo;

    if (selectedPhotoBytes != null) {
      photo = Image.memory(
        selectedPhotoBytes!,
        width: 160,
        height: 160,
        fit: BoxFit.cover,
      );
    } else if (existingPhotoUrl.trim().isNotEmpty) {
      photo = Image.network(
        existingPhotoUrl.trim(),
        width: 160,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.person_rounded, size: 64));
        },
      );
    } else {
      photo = const Center(child: Icon(Icons.person_rounded, size: 64));
    }

    return Column(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: photo,
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onSelectPhoto,
          icon: const Icon(Icons.add_a_photo_rounded),
          label: Text(
            existingPhotoUrl.trim().isEmpty && selectedPhotoBytes == null
                ? 'Add Profile Picture'
                : 'Change Profile Picture',
          ),
        ),
      ],
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _DateSelectionTile extends StatelessWidget {
  const _DateSelectionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.enabled,
    required this.onTap,
    required this.onClear,
  });

  final IconData icon;
  final String title;
  final DateTime? value;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(_formatDate(context, value)),
      trailing: onClear == null
          ? const Icon(Icons.calendar_month_rounded)
          : IconButton(
              tooltip: 'Clear date',
              onPressed: enabled ? onClear : null,
              icon: const Icon(Icons.clear_rounded),
            ),
      onTap: enabled ? onTap : null,
    );
  }
}

String _formatDate(BuildContext context, DateTime? value) {
  if (value == null) {
    return 'Not provided';
  }

  return MaterialLocalizations.of(context).formatMediumDate(value.toLocal());
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
