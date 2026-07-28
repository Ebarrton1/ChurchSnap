import 'dart:async';

import 'package:flutter/material.dart';

import '../services/account_session_service.dart';
import '../state/auth_controller.dart';

class SingleDeviceSessionGuard extends StatefulWidget {
  const SingleDeviceSessionGuard({
    super.key,
    required this.userId,
    required this.expectedSessionId,
    required this.authController,
    required this.child,
  });

  final String userId;
  final String? expectedSessionId;
  final AuthController authController;
  final Widget child;

  @override
  State<SingleDeviceSessionGuard> createState() =>
      _SingleDeviceSessionGuardState();
}

class _SingleDeviceSessionGuardState extends State<SingleDeviceSessionGuard> {
  StreamSubscription<AccountSessionRecord>? _subscription;
  bool _endingSession = false;
  String? _lastStreamError;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void didUpdateWidget(covariant SingleDeviceSessionGuard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId ||
        oldWidget.expectedSessionId != widget.expectedSessionId) {
      _subscription?.cancel();
      _endingSession = false;
      _lastStreamError = null;
      _startListening();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _startListening() {
    final expectedSessionId = widget.expectedSessionId?.trim() ?? '';

    if (widget.userId.trim().isEmpty || expectedSessionId.isEmpty) {
      return;
    }

    _subscription = widget.authController
        .watchAccountSession(widget.userId)
        .listen(_handleRecord, onError: _handleStreamError);
  }

  void _handleRecord(AccountSessionRecord record) {
    if (_endingSession) {
      return;
    }

    final expectedSessionId = widget.expectedSessionId?.trim() ?? '';
    final activeSessionId = record.sessionId?.trim() ?? '';

    if (record.exists &&
        expectedSessionId.isNotEmpty &&
        activeSessionId == expectedSessionId) {
      return;
    }

    if (record.isFromCache && !record.exists) {
      return;
    }

    _endingSession = true;
    unawaited(widget.authController.endSessionReplaced());
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    final message = error.toString().trim();

    if (message.isEmpty || _lastStreamError == message) {
      return;
    }

    _lastStreamError = message;
    debugPrint('Account-session listener failed: $error');
  }
}
