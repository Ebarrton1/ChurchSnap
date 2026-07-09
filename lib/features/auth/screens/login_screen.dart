import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../notifications/repositories/notification_repository.dart';
import '../../notifications/services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;

  const LoginScreen({super.key, required this.authController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'member@churchsnap.app');
  final passwordController = TextEditingController(text: 'password');
  final nameController = TextEditingController();
  final churchIdController = TextEditingController(text: 'demo-church');
  bool isCreatingAccount = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    churchIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.authController;

    return Scaffold(
      body: SafeArea(
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
                    'Sign in as a member, create an account, or continue as a guest visitor.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (isCreatingAccount) ...[
              _AuthField(
                controller: nameController,
                label: 'Full name',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 12),
              _AuthField(
                controller: churchIdController,
                label: 'Church ID',
                icon: Icons.badge_rounded,
              ),
              const SizedBox(height: 12),
            ],
            _AuthField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock_rounded,
              obscureText: true,
            ),
            if (auth.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                auth.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: auth.status == AuthStatus.loading ? null : _submit,
              icon: Icon(
                isCreatingAccount
                    ? Icons.person_add_alt_1_rounded
                    : Icons.login_rounded,
              ),
              label: Text(isCreatingAccount ? 'Create Account' : 'Sign In'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: auth.status == AuthStatus.loading
                  ? null
                  : () =>
                        setState(() => isCreatingAccount = !isCreatingAccount),
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text(
                isCreatingAccount
                    ? 'I already have an account'
                    : 'Create a new account',
              ),
            ),
            TextButton(
              onPressed: auth.status == AuthStatus.loading
                  ? null
                  : widget.authController.continueAsGuest,
              child: const Text('Continue as Guest'),
            ),
            TextButton(
              onPressed: auth.status == AuthStatus.loading
                  ? null
                  : () async {
                      final ok = await widget.authController.sendPasswordReset(
                        emailController.text,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Password reset email preview sent.'
                                : 'Enter your email first.',
                          ),
                        ),
                      );
                    },
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final ok = isCreatingAccount
        ? await widget.authController.createAccount(
            displayName: nameController.text,
            email: emailController.text,
            password: passwordController.text,
            churchId: churchIdController.text,
          )
        : await widget.authController.signIn(
            emailController.text,
            passwordController.text,
          );

    if (!mounted || !ok) return;

    final user = widget.authController.currentUser;

    if (user != null) {
      await NotificationService(
        NotificationRepository(FirebaseFirestore.instance),
      ).initializeMessaging(userId: user.id, churchId: 'demo-church');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Signed in successfully.')));
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
