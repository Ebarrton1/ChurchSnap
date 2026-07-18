import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/app_roles.dart';
import '../../../core/errors/app_error_presenter.dart';
import '../models/live_member_access.dart';
import '../state/auth_controller.dart';

class LiveMemberSession extends StatefulWidget {
  const LiveMemberSession({
    super.key,
    required this.churchId,
    required this.userId,
    required this.authController,
    required this.child,
  });

  final String churchId;
  final String userId;
  final AuthController authController;
  final Widget child;

  @override
  State<LiveMemberSession> createState() => _LiveMemberSessionState();
}

class _LiveMemberSessionState extends State<LiveMemberSession> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _memberSubscription;

  bool _hasReceivedInitialSnapshot = false;
  String? _lastReportedError;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void didUpdateWidget(covariant LiveMemberSession oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.churchId != widget.churchId ||
        oldWidget.userId != widget.userId) {
      _memberSubscription?.cancel();
      _hasReceivedInitialSnapshot = false;
      _lastReportedError = null;
      _startListening();
    }
  }

  @override
  void dispose() {
    _memberSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _startListening() {
    if (widget.userId == 'guest') {
      return;
    }

    _memberSubscription = FirebaseFirestore.instance
        .collection('churches')
        .doc(widget.churchId)
        .collection('members')
        .doc(widget.userId)
        .snapshots()
        .listen(_handleSnapshot, onError: _handleStreamError);
  }

  void _handleSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      unawaited(widget.authController.signOut());
      return;
    }

    final currentUser = widget.authController.currentUser;

    if (currentUser == null || currentUser.id != widget.userId) {
      return;
    }

    final previousRole = currentUser.role;
    final previousActiveState = currentUser.isActive;
    final access = LiveMemberAccess.fromMap(
      snapshot.data()!,
      fallback: currentUser,
    );

    widget.authController.applyLiveMemberAccess(access);

    if (!_hasReceivedInitialSnapshot) {
      _hasReceivedInitialSnapshot = true;
      return;
    }

    if (previousRole != access.role) {
      _showRoleChange(previousRole: previousRole, newRole: access.role);
    }

    if (previousActiveState && !access.isActive) {
      _showMessage(
        'Your ChurchSnap account has been deactivated. '
        'Contact a church administrator for assistance.',
      );
    }
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    final message = AppErrorPresenter.message(
      error,
      fallback:
          'ChurchSnap could not refresh your membership access. '
          'Your current session will remain open.',
    );

    if (_lastReportedError == message) {
      return;
    }

    _lastReportedError = message;
    _showMessage(message);
  }

  void _showRoleChange({
    required String previousRole,
    required String newRole,
  }) {
    _showMessage(
      'Your ChurchSnap role changed from '
      '${AppRoles.label(previousRole)} to ${AppRoles.label(newRole)}. '
      'Your available features have refreshed automatically.',
    );
  }

  void _showMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);

      if (messenger == null) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }
}
