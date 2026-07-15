import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/widgets/churchsnap_screen.dart';

class AdminChurchConnectionScreen extends StatefulWidget {
  const AdminChurchConnectionScreen({super.key, required this.churchId});

  final String churchId;

  @override
  State<AdminChurchConnectionScreen> createState() =>
      _AdminChurchConnectionScreenState();
}

class _AdminChurchConnectionScreenState
    extends State<AdminChurchConnectionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _publishSucceeded = false;
  String? _publishFeedback;
  bool _isPublic = true;
  bool _visitorAccessEnabled = true;

  DocumentReference<Map<String, dynamic>> get _churchReference =>
      FirebaseFirestore.instance.collection('churches').doc(widget.churchId);

  String get _qrValue => 'churchsnap://church/${widget.churchId}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final snapshot = await _churchReference.get();
      final data = snapshot.data() ?? const <String, dynamic>{};

      if (!mounted) {
        return;
      }

      _nameController.text = _readString(data, [
        'name',
        'churchName',
        'displayName',
      ], fallback: _titleFromId(widget.churchId));
      _addressController.text = _readString(data, [
        'address',
        'addressLine1',
        'streetAddress',
      ]);
      _cityController.text = _readString(data, ['city']);
      _stateController.text = _readString(data, [
        'stateOrProvince',
        'state',
        'province',
      ]);
      _codeController.text = _readString(data, [
        'inviteCode',
        'connectionCode',
        'churchCode',
      ], fallback: _defaultConnectionCode(widget.churchId)).toUpperCase();
      _isPublic = data['isPublic'] as bool? ?? true;
      _visitorAccessEnabled = data['visitorAccessEnabled'] as bool? ?? true;
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to load church connection settings: $error');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
      _publishSucceeded = false;
      _publishFeedback = null;
    });

    try {
      await _churchReference.set(<String, dynamic>{
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'stateOrProvince': _stateController.text.trim(),
        'inviteCode': _codeController.text.trim().toUpperCase(),
        'isPublic': _isPublic,
        'isActive': true,
        'visitorAccessEnabled': _visitorAccessEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      setState(() {
        _publishSucceeded = true;
        _publishFeedback =
            'Connection settings saved and published successfully.';
      });

      _showMessage('Church connection settings published successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _publishSucceeded = false;
        _publishFeedback =
            'The settings were not saved. Check the connection and try again.';
      });

      _showMessage('Unable to save church settings: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _copyCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showMessage('Enter and save a church connection code first.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: code));

    if (mounted) {
      _showMessage('Connection code copied.');
    }
  }

  Future<void> _copyQrLink() async {
    await Clipboard.setData(ClipboardData(text: _qrValue));

    if (mounted) {
      _showMessage('ChurchSnap QR link copied.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChurchSnapScreen(
      title: 'Church Connection',
      subtitle: 'Publish the church identity visitors use to connect.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Public church name',
                  labelStyle: TextStyle(
                    color: Color(0xFF24364B),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Color(0xFF0B659E),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.church_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the church name.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Street address',
                  labelStyle: TextStyle(
                    color: Color(0xFF24364B),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Color(0xFF0B659E),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        labelStyle: TextStyle(
                          color: Color(0xFF24364B),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF0B659E),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'State / Province',
                        labelStyle: TextStyle(
                          color: Color(0xFF24364B),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF0B659E),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Visitor connection code',
                  labelStyle: const TextStyle(
                    color: Color(0xFF24364B),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Color(0xFF0B659E),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.key_rounded),
                  suffixIcon: IconButton(
                    tooltip: 'Copy code',
                    onPressed: _copyCode,
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ),
                validator: (value) {
                  final code = value?.trim() ?? '';

                  if (code.length < 4) {
                    return 'Use at least 4 letters or numbers.';
                  }

                  if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(code)) {
                    return 'Use letters, numbers, hyphens, or underscores.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                      title: const Text('Show in church search'),
                      subtitle: const Text(
                        'Visitors can discover this church by name and location.',
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _visitorAccessEnabled,
                      onChanged: (value) {
                        setState(() {
                          _visitorAccessEnabled = value;
                        });
                      },
                      title: const Text('Allow visitor connections'),
                      subtitle: const Text(
                        'Enables search, code, and QR visitor onboarding.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _publishSucceeded
                            ? Icons.check_circle_rounded
                            : Icons.publish_rounded,
                      ),
                label: Text(
                  _saving
                      ? 'Publishing...'
                      : _publishSucceeded
                      ? 'Published Successfully'
                      : 'Publish Connection Settings',
                ),
              ),
              if (_publishFeedback != null) ...[
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  label: _publishFeedback,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _publishSucceeded
                          ? const Color(0xFFE7F6EC)
                          : Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _publishSucceeded
                            ? const Color(0xFF2E7D4F)
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _publishSucceeded
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                          size: 18,
                          color: _publishSucceeded
                              ? const Color(0xFF176B3A)
                              : Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _publishFeedback!,
                            style: TextStyle(
                              color: _publishSucceeded
                                  ? const Color(0xFF124F2D)
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionTitle(title: 'ChurchSnap QR Code'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: QrImageView(
                    data: _qrValue,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(_qrValue, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _copyQrLink,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy QR Connection Link'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Place this QR code on welcome signs, printed programs, '
                  'the church website, and social media.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : const Color(0xFF176B3A),
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_rounded : Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return fallback;
  }

  static String _defaultConnectionCode(String churchId) {
    final normalized = churchId.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    if (normalized.isEmpty) {
      return 'CHURCHSNAP';
    }

    return normalized.length <= 12 ? normalized : normalized.substring(0, 12);
  }

  static String _titleFromId(String id) {
    return id
        .split(RegExp(r'[-_\s]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) => part.length == 1
              ? part.toUpperCase()
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
