import 'package:flutter/material.dart';

import '../repositories/firebase/firebase_auth_repository_stub.dart';
import '../state/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isCreatingAccount = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.authController;
    final loading = auth.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.church_rounded, color: Colors.white, size: 46),
                    SizedBox(height: 18),
                    Text(
                      'Welcome to ChurchSnap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sign in to connect with your church community.',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_isCreatingAccount) ...[
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: _fieldDecoration(
                    label: 'Full name',
                    icon: Icons.person_rounded,
                  ),
                  validator: (value) {
                    if (!_isCreatingAccount) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your full name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                decoration: _fieldDecoration(
                  label: 'Email',
                  icon: Icons.email_rounded,
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: [
                  _isCreatingAccount
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                onFieldSubmitted: loading ? null : (_) => _submit(),
                decoration:
                    _fieldDecoration(
                      label: 'Password',
                      icon: Icons.lock_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password.';
                  }
                  if (_isCreatingAccount && value.length < 6) {
                    return 'Use at least 6 characters.';
                  }
                  return null;
                },
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  auth.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: loading ? null : _submit,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isCreatingAccount
                            ? Icons.person_add_alt_1_rounded
                            : Icons.login_rounded,
                      ),
                label: Text(
                  loading
                      ? 'Please wait...'
                      : _isCreatingAccount
                      ? 'Create Account'
                      : 'Sign In',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: loading ? null : _toggleMode,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: Text(
                  _isCreatingAccount
                      ? 'I already have an account'
                      : 'Create a new account',
                ),
              ),
              if (!_isCreatingAccount) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: loading ? null : _continueAsGuest,
                  icon: const Icon(Icons.explore_rounded),
                  label: const Text('Browse as guest'),
                ),
              ],
              TextButton(
                onPressed: loading ? null : _sendPasswordReset,
                child: const Text('Forgot password?'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Guest access includes published church content. Sign in for '
                'RSVP, check-in, prayer submission, giving history, member '
                'profile, volunteer, and administrative features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Enter your email address.';

    final atIndex = email.indexOf('@');
    final dotIndex = email.lastIndexOf('.');

    if (atIndex <= 0 ||
        dotIndex <= atIndex + 1 ||
        dotIndex == email.length - 1) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  void _toggleMode() {
    widget.authController.clearError();
    setState(() {
      _isCreatingAccount = !_isCreatingAccount;
    });
  }

  Future<void> _continueAsGuest() async {
    FocusScope.of(context).unfocus();

    final opened = await widget.authController.continueAsGuest();

    if (!mounted || opened) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.authController.errorMessage ?? 'Unable to start guest access.',
        ),
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    FocusScope.of(context).unfocus();

    final emailError = _validateEmail(_emailController.text);

    if (emailError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    final email = _emailController.text.trim();

    final sent = await widget.authController.sendPasswordReset(email);

    if (!mounted) {
      return;
    }

    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.authController.errorMessage ??
                'Unable to send the password reset email.',
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.mark_email_read_rounded, size: 40),
          title: const Text('Check your email'),
          content: Text(
            'A password reset link was sent to:\n\n'
            '$email\n\n'
            'Open the newest ChurchSnap email and follow the link to choose '
            'a new password. Check your Spam or Junk folder if it does not '
            'appear in your inbox.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isCreatingAccount) {
      await widget.authController.createAccount(
        displayName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        churchId: FirebaseAuthRepository.defaultChurchId,
      );
      return;
    }

    await widget.authController.signIn(
      _emailController.text,
      _passwordController.text,
    );
  }
}
