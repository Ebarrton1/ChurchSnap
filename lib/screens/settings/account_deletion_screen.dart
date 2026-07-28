import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/services/account_deletion_service.dart';
import '../../features/auth/state/auth_controller.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({
    super.key,
    required this.authController,
    this.deletionService,
  });

  final AuthController authController;
  final AccountDeletionService? deletionService;

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  late final AccountDeletionService _deletionService;

  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _acknowledged = false;
  bool _deleting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _deletionService =
        widget.deletionService ?? FirebaseAccountDeletionService();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    final role = user?.role.trim() ?? '';
    final isGuest = widget.authController.isGuest;
    final isProtectedRole = const <String>{
      'admin',
      'pastor',
      'groupLeader',
      'ministryLeader',
    }.contains(role);

    return Scaffold(
      appBar: AppBar(title: const Text('Delete My Account')),
      body: ChurchSnapScreen(
        title: 'Delete My Account',
        subtitle:
            'Permanently remove your ChurchSnap login and personal account data.',
        children: [
          const _WarningCard(),
          const SectionTitle(title: 'What will be removed'),
          const AppCard(
            child: Column(
              children: [
                _DeletionDetail(
                  icon: Icons.person_remove_rounded,
                  text: 'Your Firebase sign-in account and active sessions',
                ),
                _DeletionDetail(
                  icon: Icons.badge_outlined,
                  text: 'Your member or registered visitor profile',
                ),
                _DeletionDetail(
                  icon: Icons.lock_person_outlined,
                  text: 'Protected private-profile information',
                ),
                _DeletionDetail(
                  icon: Icons.photo_outlined,
                  text: 'Your ChurchSnap profile-picture files',
                ),
                _DeletionDetail(
                  icon: Icons.favorite_border_rounded,
                  text:
                      'Your prayer requests, pending join requests, check-ins, '
                      'bookmarks, and personal schedule assignments',
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Records that may be retained'),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirmed giving records may be retained in anonymized form '
                  'for church accounting. Security and administrator audit '
                  'history, and encrypted backups created before deletion, may '
                  'also remain for legitimate recordkeeping and recovery.',
                ),
                SizedBox(height: 10),
                Text(
                  'Deleting your account does not delete church-owned sermons, '
                  'events, media, ministries, announcements, or administrative '
                  'records.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (isGuest)
            const _UnavailableCard(
              message:
                  'Anonymous visitor mode does not have a registered account. '
                  'Use Leave visitor mode instead.',
            )
          else if (isProtectedRole)
            const _UnavailableCard(
              message:
                  'Transfer administrator, pastor, ministry-leader, or '
                  'small-group-leader responsibility before deleting this '
                  'account. This protects the church from losing essential '
                  'management access.',
            )
          else if (user == null || user.email.trim().isEmpty)
            const _UnavailableCard(
              message:
                  'ChurchSnap could not identify a registered email account.',
            )
          else ...[
            const SectionTitle(title: 'Verify and confirm'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    user.email,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const Key('accountDeletionPassword'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !_deleting,
                    decoration: InputDecoration(
                      labelText: 'Current password',
                      prefixIcon: const Icon(Icons.password_rounded),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: _deleting
                            ? null
                            : () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const Key('accountDeletionConfirmation'),
                    controller: _confirmationController,
                    enabled: !_deleting,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Type DELETE',
                      prefixIcon: Icon(Icons.warning_amber_rounded),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    key: const Key('accountDeletionAcknowledgement'),
                    contentPadding: EdgeInsets.zero,
                    value: _acknowledged,
                    onChanged: _deleting
                        ? null
                        : (value) {
                            setState(() {
                              _acknowledged = value ?? false;
                              _errorMessage = null;
                            });
                          },
                    title: const Text(
                      'I understand this action is permanent.',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'I have reviewed what is removed and what may be retained.',
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      key: const Key('accountDeletionError'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    key: const Key('accountDeletionSubmit'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: _deleting ? null : _requestDeletion,
                    icon: _deleting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Icon(Icons.delete_forever_rounded),
                    label: Text(
                      _deleting ? 'Deleting account...' : 'DELETE MY ACCOUNT',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _requestDeletion() async {
    final password = _passwordController.text.trim();
    final confirmation = _confirmationController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Enter your current password.';
      });
      return;
    }

    if (confirmation != 'DELETE') {
      setState(() {
        _errorMessage = 'Type DELETE exactly as shown.';
      });
      return;
    }

    if (!_acknowledged) {
      setState(() {
        _errorMessage =
            'Confirm that you understand the deletion is permanent.';
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Permanently delete account?'),
          content: const Text(
            'This will remove your ChurchSnap sign-in and personal account '
            'data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('accountDeletionFinalConfirm'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete permanently'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final churchId = widget.authController.currentUser?.churchId.trim() ?? '';

    widget.authController.beginAccountDeletion();

    setState(() {
      _deleting = true;
      _errorMessage = null;
    });

    final result = await _deletionService.deleteAccount(
      password: password,
      churchId: churchId,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      widget.authController.cancelAccountDeletion();

      setState(() {
        _deleting = false;
        _errorMessage =
            result.errorMessage ?? 'Account deletion was not completed.';
      });

      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.authController.completeAccountDeletion();
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded, size: 52, color: colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'Permanent account deletion',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this only when you no longer want a ChurchSnap account. '
            'Signing out or asking an administrator to deactivate access is '
            'different from permanent deletion.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DeletionDetail extends StatelessWidget {
  const _DeletionDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          child: Icon(Icons.admin_panel_settings_rounded),
        ),
        title: const Text(
          'Account deletion is not available yet',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(message),
        ),
      ),
    );
  }
}
