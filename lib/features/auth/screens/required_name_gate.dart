import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import '../services/required_name_service.dart';
import '../services/required_name_validator.dart';

class RequiredNameGate extends StatefulWidget {
  const RequiredNameGate({
    super.key,
    required this.churchId,
    required this.userId,
    required this.existingDisplayName,
    required this.authController,
    required this.child,
  });

  final String churchId;
  final String userId;
  final String existingDisplayName;
  final AuthController authController;
  final Widget child;

  @override
  State<RequiredNameGate> createState() => _RequiredNameGateState();
}

class _RequiredNameGateState extends State<RequiredNameGate> {
  late final RequiredNameService _service;
  late final Stream<RequiredNameStatus> _statusStream;

  @override
  void initState() {
    super.initState();

    _service = RequiredNameService(
      churchId: widget.churchId,
      userId: widget.userId,
    );
    _statusStream = _service.watchStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId == 'guest') {
      return widget.child;
    }

    return StreamBuilder<RequiredNameStatus>(
      stream: _statusStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _RequiredNameLoadError(
            error: snapshot.error,
            onSignOut: widget.authController.signOut,
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data!.isComplete) {
          return widget.child;
        }

        return RequiredNameScreen(
          service: _service,
          existingDisplayName: widget.existingDisplayName,
          onSignOut: widget.authController.signOut,
        );
      },
    );
  }
}

class RequiredNameScreen extends StatefulWidget {
  const RequiredNameScreen({
    super.key,
    required this.service,
    required this.existingDisplayName,
    required this.onSignOut,
  });

  final RequiredNameService service;
  final String existingDisplayName;
  final Future<void> Function() onSignOut;

  @override
  State<RequiredNameScreen> createState() => _RequiredNameScreenState();
}

class _RequiredNameScreenState extends State<RequiredNameScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final FocusNode _lastNameFocusNode = FocusNode();

  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();

    final prefill = RequiredNameValidator.splitDisplayName(
      widget.existingDisplayName,
    );

    _firstNameController = TextEditingController(text: prefill.firstName);
    _lastNameController = TextEditingController(text: prefill.lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _lastNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Complete Your Name'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : widget.onSignOut,
            child: const Text('Sign Out'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.badge_outlined,
                              size: 36,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'First and last name required',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Before entering ChurchSnap, please provide the '
                            'first and last name you want shown to your church. '
                            'This is required for every authenticated account.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: _firstNameController,
                            enabled: !_isSaving,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.givenName],
                            decoration: const InputDecoration(
                              labelText: 'First name *',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              return RequiredNameValidator.validatePart(
                                value ?? '',
                                label: 'First name',
                              );
                            },
                            onFieldSubmitted: (_) {
                              _lastNameFocusNode.requestFocus();
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _lastNameController,
                            focusNode: _lastNameFocusNode,
                            enabled: !_isSaving,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.familyName],
                            decoration: const InputDecoration(
                              labelText: 'Last name *',
                              prefixIcon: Icon(Icons.people_outline_rounded),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              return RequiredNameValidator.validatePart(
                                value ?? '',
                                label: 'Last name',
                              );
                            },
                            onFieldSubmitted: (_) => _save(),
                          ),
                          if (_saveError != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              _saveError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: _isSaving ? null : _save,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_rounded),
                            label: Text(
                              _isSaving
                                  ? 'Saving Name...'
                                  : 'Save and Enter ChurchSnap',
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Your name is stored with your church member '
                            'record and may be visible in authorized member '
                            'and leadership areas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    final fullNameError = RequiredNameValidator.validateFullName(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    if (fullNameError != null) {
      setState(() {
        _saveError = fullNameError;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await widget.service.saveRequiredName(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _saveError = _friendlyError(error);
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

    return 'Unable to save your name. Check your connection and try again.';
  }
}

class _RequiredNameLoadError extends StatelessWidget {
  const _RequiredNameLoadError({required this.error, required this.onSignOut});

  final Object? error;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Complete Your Name'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to check your member profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('$error', textAlign: TextAlign.center),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: onSignOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign Out and Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
