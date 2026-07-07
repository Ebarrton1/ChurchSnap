// This file documents the production Firebase implementation target.
// Keep this stub until you run `flutterfire configure` and add Firebase packages.
//
// Planned packages:
// - firebase_core
// - firebase_auth
// - cloud_firestore
// - google_sign_in
// - sign_in_with_apple
//
// The production class should implement AuthRepository and map FirebaseAuth users
// to ChurchSnapUser records stored under churches/{churchId}/members/{uid}.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/service_result.dart';
import '../../../../firebase/firebase_paths.dart';
import '../../models/churchsnap_user.dart';
import '../auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String defaultChurchId = 'demo-church';

  @override
  ChurchSnapUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    return ChurchSnapUser(
      id: user.uid,
      churchId: defaultChurchId,
      displayName: user.displayName ?? 'ChurchSnap Member',
      email: user.email ?? '',
      role: 'member',
      isEmailVerified: user.emailVerified,
    );
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return ServiceResult.failure('Unable to sign in.');
      }

      return ServiceResult.success(await _loadOrCreateUser(user));
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_friendlyError(e));
    } catch (_) {
      return ServiceResult.failure('Sign in failed. Please try again.');
    }
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> createAccount({
    required String displayName,
    required String email,
    required String password,
    required String churchId,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return ServiceResult.failure('Unable to create account.');
      }

      await user.updateDisplayName(displayName.trim());

      final appUser = ChurchSnapUser(
        id: user.uid,
        churchId: churchId.trim().isEmpty ? defaultChurchId : churchId.trim(),
        displayName: displayName.trim(),
        email: user.email ?? email.trim(),
        role: 'member',
        isEmailVerified: user.emailVerified,
      );

      await _saveUser(appUser);

      return ServiceResult.success(appUser);
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_friendlyError(e));
    } catch (_) {
      return ServiceResult.failure(
        'Account creation failed. Please try again.',
      );
    }
  }

  @override
  Future<ServiceResult<void>> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return ServiceResult.success(null);
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_friendlyError(e));
    } catch (_) {
      return ServiceResult.failure('Password reset failed. Please try again.');
    }
  }

  @override
  Future<ServiceResult<void>> signOut() async {
    await _auth.signOut();
    return ServiceResult.success(null);
  }

  Future<ChurchSnapUser> _loadOrCreateUser(User user) async {
    final memberRef = _firestore
        .collection(FirebasePaths.members(defaultChurchId))
        .doc(user.uid);

    final snapshot = await memberRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      return ChurchSnapUser.fromMap(snapshot.data()!);
    }

    final appUser = ChurchSnapUser(
      id: user.uid,
      churchId: defaultChurchId,
      displayName: user.displayName ?? 'ChurchSnap Member',
      email: user.email ?? '',
      role: 'member',
      isEmailVerified: user.emailVerified,
    );

    await _saveUser(appUser);
    return appUser;
  }

  Future<void> _saveUser(ChurchSnapUser user) async {
    await _firestore
        .collection(FirebasePaths.members(user.churchId))
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
