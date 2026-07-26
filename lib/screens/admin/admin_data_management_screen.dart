import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/local_backup/services/churchsnap_local_backup_service.dart';

class AdminDataManagementScreen extends StatefulWidget {
  const AdminDataManagementScreen({super.key, required this.churchId});

  final String churchId;

  @override
  State<AdminDataManagementScreen> createState() =>
      _AdminDataManagementScreenState();
}

class _AdminDataManagementScreenState extends State<AdminDataManagementScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  late final ChurchSnapLocalBackupService _service;
  late Future<ChurchSnapLocalBackupAccess> _accessFuture;

  bool _acknowledged = false;
  bool _busy = false;
  bool _obscurePassword = true;
  String _progressMessage = '';

  @override
  void initState() {
    super.initState();

    _service = ChurchSnapLocalBackupService(churchId: widget.churchId);
    _accessFuture = _service.checkAccess();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _createBackup() async {
    if (_busy) {
      return;
    }

    final password = _passwordController.text;
    final confirmation = _confirmationController.text;

    if (password.length < 12) {
      _showMessage('Use a backup password with at least 12 characters.');
      return;
    }

    if (password != confirmation) {
      _showMessage('The backup passwords do not match.');
      return;
    }

    if (!_acknowledged) {
      _showMessage(
        'Confirm that you understand the backup password cannot be recovered.',
      );
      return;
    }

    setState(() {
      _busy = true;
      _progressMessage = 'Preparing the encrypted backup...';
    });

    try {
      final result = await _service.createEncryptedBackup(
        password: password,
        onProgress: (message) {
          if (!mounted) {
            return;
          }

          setState(() {
            _progressMessage = message;
          });
        },
      );

      if (!mounted) {
        return;
      }

      if (result.wasCancelled) {
        _showMessage('Local backup cancelled.');
        return;
      }

      _passwordController.clear();
      _confirmationController.clear();

      setState(() {
        _acknowledged = false;
      });

      final auditNote = result.auditLogged
          ? ''
          : ' The file was saved, but the activity log could not be updated.';

      _showMessage(
        'Encrypted backup saved: ${result.fileName}. '
        '${result.recordCount} records from '
        '${result.collectionCount} collections.$auditNote',
      );
    } on ChurchSnapLocalBackupException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Unable to create the local backup. '
          'Check the connection and administrator permissions.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progressMessage = '';
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChurchSnapScreen(
        title: 'Data Management',
        subtitle:
            'Create an encrypted local backup of this church’s Firestore records.',
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.security_rounded),
                  title: Text(
                    'Encrypted local backup',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    'The backup is encrypted before it leaves ChurchSnap. '
                    'Firebase remains the primary live database.',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.download_rounded),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Web browsers control the download location. '
                          'Enable “Ask where to save each file before '
                          'downloading” in your browser settings when you '
                          'want to choose a folder for every backup.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Included: church settings, members, private member '
                  'profiles, events, sermons, prayer records, attendance, '
                  'ministries, groups, giving records, and administrative '
                  'activity stored in Firestore.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Excluded: sign-in passwords, authentication credentials, '
                  'Firebase Storage files, payment-card or bank credentials, '
                  'and member-only sermon bookmarks.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<ChurchSnapLocalBackupAccess>(
            future: _accessFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unable to verify administrator access.',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _accessFuture = _service.checkAccess();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final access = snapshot.data;

              if (access == null || !access.isAllowed) {
                return AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: const Text(
                      'Administrator access required',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      access?.reason ??
                          'Only a ChurchSnap administrator may use this tool.',
                    ),
                  ),
                );
              }

              return _buildBackupForm(access);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupForm(ChurchSnapLocalBackupAccess access) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Authorized administrator: ${access.displayName}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a strong password and store it separately from the '
            'backup file. ChurchSnap cannot recover this password.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            enabled: !_busy,
            obscureText: _obscurePassword,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Backup password',
              helperText: 'Minimum 12 characters',
              suffixIcon: IconButton(
                onPressed: _busy
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
          const SizedBox(height: 12),
          TextField(
            controller: _confirmationController,
            enabled: !_busy,
            obscureText: _obscurePassword,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'Confirm backup password',
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _acknowledged,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: _busy
                ? null
                : (value) {
                    setState(() {
                      _acknowledged = value ?? false;
                    });
                  },
            title: const Text(
              'I understand this password cannot be recovered by ChurchSnap.',
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 10),
            Text(
              _progressMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _createBackup,
            icon: const Icon(Icons.backup_rounded),
            label: Text(
              _busy ? 'Creating Encrypted Backup...' : 'Create Local Backup',
            ),
          ),
        ],
      ),
    );
  }
}
