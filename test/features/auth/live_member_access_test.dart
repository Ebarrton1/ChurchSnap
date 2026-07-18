import 'package:churchsnap/core/errors/app_error_presenter.dart';
import 'package:churchsnap/features/auth/models/churchsnap_user.dart';
import 'package:churchsnap/features/auth/models/live_member_access.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const visitor = ChurchSnapUser(
    id: 'member-1',
    churchId: 'church-1',
    displayName: 'Grace Visitor',
    email: 'grace@example.com',
    role: 'visitor',
    isEmailVerified: true,
    isActive: true,
  );

  group('LiveMemberAccess', () {
    test('applies a visitor-to-member change immediately', () {
      final access = LiveMemberAccess.fromMap(const <String, dynamic>{
        'displayName': 'Grace Visitor',
        'email': 'grace@example.com',
        'role': 'member',
        'isActive': true,
      }, fallback: visitor);

      final updatedUser = access.mergeWith(visitor);

      expect(access.differsFrom(visitor), isTrue);
      expect(updatedUser.role, 'member');
      expect(updatedUser.isEmailVerified, isTrue);
      expect(updatedUser.churchId, 'church-1');
    });

    test('applies account deactivation immediately', () {
      final access = LiveMemberAccess.fromMap(const <String, dynamic>{
        'role': 'visitor',
        'isActive': false,
      }, fallback: visitor);

      final updatedUser = access.mergeWith(visitor);

      expect(updatedUser.isActive, isFalse);
      expect(updatedUser.displayName, visitor.displayName);
      expect(updatedUser.email, visitor.email);
    });

    test('preserves existing values when optional fields are absent', () {
      final access = LiveMemberAccess.fromMap(
        const <String, dynamic>{},
        fallback: visitor,
      );

      expect(access.differsFrom(visitor), isFalse);
      expect(access.displayName, visitor.displayName);
      expect(access.email, visitor.email);
      expect(access.role, visitor.role);
      expect(access.isActive, visitor.isActive);
    });
  });

  group('AppErrorPresenter', () {
    test('maps permission failures to a friendly message', () {
      final message = AppErrorPresenter.message(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      expect(
        message,
        'ChurchSnap does not have permission to complete that action.',
      );
    });

    test('maps network failures to a friendly message', () {
      final message = AppErrorPresenter.message(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(
        message,
        'ChurchSnap cannot reach the service. '
        'Check your internet connection.',
      );
    });

    test('uses a supplied safe fallback for unknown errors', () {
      expect(
        AppErrorPresenter.message(
          Exception('internal implementation detail'),
          fallback: 'Please try that ChurchSnap action again.',
        ),
        'Please try that ChurchSnap action again.',
      );
    });
  });
}
