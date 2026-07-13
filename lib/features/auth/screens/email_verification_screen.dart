import 'package:flutter/material.dart';

import '../state/auth_controller.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _checking = false;
  bool _resending = false;
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    final controllerError = widget.authController.errorMessage;
    final visibleMessage = _statusMessage ?? controllerError;
    final visibleMessageIsError = _statusMessage == null
        ? controllerError != null
        : _statusIsError;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 48),
            Center(
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Verify your email',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              'ChurchSnap requires verification for:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 6),
            Text(
              user?.email ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            const Text(
              'A verification email is requested automatically after sign-in. '
              'Open the link in that email, then return to ChurchSnap and tap '
              'the button below. Check your spam or junk folder as well.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.45),
            ),
            if (visibleMessage != null) ...[
              const SizedBox(height: 18),
              Text(
                visibleMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: visibleMessageIsError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: _checking || _resending ? null : _checkVerification,
              icon: _checking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.verified_rounded),
              label: Text(_checking ? 'Checking...' : 'I verified my email'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _checking || _resending ? null : _resendVerification,
              icon: _resending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _resending ? 'Sending...' : 'Resend verification email',
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _checking || _resending
                  ? null
                  : () => widget.authController.signOut(),
              child: const Text('Use a different account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkVerification() async {
    setState(() {
      _checking = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    final verified = await widget.authController.refreshEmailVerification();

    if (!mounted) {
      return;
    }

    setState(() {
      _checking = false;

      if (!verified) {
        _statusMessage =
            widget.authController.errorMessage ??
            'Your email is not verified yet.';
        _statusIsError = true;
      }
    });
  }

  Future<void> _resendVerification() async {
    setState(() {
      _resending = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    final sent = await widget.authController.resendEmailVerification();

    if (!mounted) {
      return;
    }

    setState(() {
      _resending = false;
      _statusMessage = sent
          ? 'Verification email sent. Check your inbox, spam, and junk folders.'
          : widget.authController.errorMessage ??
                'Unable to send the verification email.';
      _statusIsError = !sent;
    });
  }
}
