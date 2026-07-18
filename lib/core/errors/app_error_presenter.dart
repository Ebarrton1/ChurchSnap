import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AppErrorPresenter {
  const AppErrorPresenter._();

  static String message(
    Object error, {
    String fallback =
        'Something went wrong. Please check your connection and try again.',
  }) {
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' || 'unauthorized' =>
          'ChurchSnap does not have permission to complete that action.',
        'unavailable' || 'network-request-failed' =>
          'ChurchSnap cannot reach the service. Check your internet connection.',
        'too-many-requests' =>
          'Too many attempts were made. Please try again shortly.',
        'user-disabled' => 'This ChurchSnap account is currently disabled.',
        'not-found' => 'The requested ChurchSnap record could not be found.',
        'already-exists' => 'That ChurchSnap record already exists.',
        'cancelled' => 'The action was cancelled before it finished.',
        _ => fallback,
      };
    }

    final rawMessage = error.toString().trim();

    if (rawMessage.startsWith('Bad state: ')) {
      return rawMessage.substring('Bad state: '.length);
    }

    if (rawMessage.startsWith('Invalid argument(s): ')) {
      return rawMessage.substring('Invalid argument(s): '.length);
    }

    return fallback;
  }

  static void showSnackBar(
    BuildContext context,
    Object error, {
    String fallback =
        'Something went wrong. Please check your connection and try again.',
  }) {
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);

    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message(error, fallback: fallback))),
      );
  }
}
