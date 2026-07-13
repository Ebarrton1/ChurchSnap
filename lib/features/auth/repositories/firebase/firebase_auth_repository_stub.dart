import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  ChurchSnapUser? _cachedUser;

  static const String defaultChurchId = 'demo-church';

  @override
  ChurchSnapUser? get currentUser => _cachedUser;

  @override
  Future<ChurchSnapUser?> restoreCurrentUser() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      _cachedUser = null;
      return null;
    }

    await firebaseUser.reload();

    final refreshedUser = _auth.currentUser;

    if (refreshedUser == null) {
      _cachedUser = null;
      return null;
    }

    await refreshedUser.getIdToken(true);

    if (refreshedUser.isAnonymous) {
      final guest = ChurchSnapUser.guest(id: refreshedUser.uid);
      _cachedUser = guest;
      return guest;
    }

    final appUser = await _loadOrCreateUser(refreshedUser);
    _cachedUser = appUser;
    return appUser;
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty || password.isEmpty) {
      return ServiceResult.failure('Enter your email and password.');
    }

    try {
      if (_auth.currentUser?.isAnonymous == true) {
        await _auth.signOut();
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return ServiceResult.failure('Unable to sign in.');
      }

      await user.reload();

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return ServiceResult.failure('Unable to restore the signed-in user.');
      }

      await refreshedUser.getIdToken(true);

      final appUser = await _loadOrCreateUser(refreshedUser);
      _cachedUser = appUser;

      return ServiceResult.success(appUser);
    } on FirebaseAuthException catch (error) {
      return ServiceResult.failure(_friendlyError(error));
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
    final normalizedName = displayName.trim();
    final normalizedEmail = email.trim();
    final normalizedChurchId = churchId.trim().isEmpty
        ? defaultChurchId
        : churchId.trim();

    if (normalizedName.isEmpty) {
      return ServiceResult.failure('Enter your full name.');
    }

    if (normalizedEmail.isEmpty) {
      return ServiceResult.failure('Enter your email address.');
    }

    if (password.length < 6) {
      return ServiceResult.failure('Password must be at least 6 characters.');
    }

    if (normalizedChurchId != defaultChurchId) {
      return ServiceResult.failure(
        'This testing build currently supports the ChurchSnap test church only.',
      );
    }

    try {
      if (_auth.currentUser?.isAnonymous == true) {
        await _auth.signOut();
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return ServiceResult.failure('Unable to create account.');
      }

      await user.updateDisplayName(normalizedName);
      await user.reload();

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return ServiceResult.failure('Unable to finish account setup.');
      }

      final appUser = ChurchSnapUser(
        id: refreshedUser.uid,
        churchId: defaultChurchId,
        displayName: normalizedName,
        email: refreshedUser.email ?? normalizedEmail,
        role: 'member',
        isEmailVerified: refreshedUser.emailVerified,
        isActive: true,
      );

      final savedUser = await _saveUser(appUser);

      if (!refreshedUser.emailVerified) {
        try {
          await refreshedUser.sendEmailVerification();
        } on FirebaseAuthException {
          // Account creation remains successful. The verification screen
          // provides a resend action if the initial email could not be sent.
        }
      }

      _cachedUser = savedUser;
      return ServiceResult.success(savedUser);
    } on FirebaseAuthException catch (error) {
      return ServiceResult.failure(_friendlyError(error));
    } catch (_) {
      return ServiceResult.failure(
        'Account creation failed. Please try again.',
      );
    }
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> continueAsGuest() async {
    try {
      final existingUser = _auth.currentUser;

      if (existingUser != null && !existingUser.isAnonymous) {
        return ServiceResult.failure(
          'Sign out of the current account before entering guest mode.',
        );
      }

      if (existingUser?.isAnonymous == true) {
        final guest = ChurchSnapUser.guest(id: existingUser!.uid);
        _cachedUser = guest;
        return ServiceResult.success(guest);
      }

      final credential = await _auth.signInAnonymously();
      final user = credential.user;

      if (user == null) {
        return ServiceResult.failure('Unable to start guest access.');
      }

      final guest = ChurchSnapUser.guest(id: user.uid);
      _cachedUser = guest;
      return ServiceResult.success(guest);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'operation-not-allowed') {
        return ServiceResult.failure(
          'Guest access is not enabled in Firebase Authentication yet.',
        );
      }

      return ServiceResult.failure(_friendlyError(error));
    } catch (_) {
      return ServiceResult.failure(
        'Unable to start guest access. Please try again.',
      );
    }
  }

  @override
  Future<ServiceResult<void>> sendPasswordReset(String email) async {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      return ServiceResult.failure('Enter your email address first.');
    }

    try {
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
      return ServiceResult.success(null);
    } on FirebaseAuthException catch (error) {
      return ServiceResult.failure(_friendlyError(error));
    } catch (_) {
      return ServiceResult.failure('Password reset failed. Please try again.');
    }
  }

  @override
  Future<ServiceResult<void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return ServiceResult.failure('No signed-in account was found.');
      }

      if (user.isAnonymous) {
        return ServiceResult.failure(
          'Guest accounts do not use email verification.',
        );
      }

      await user.reload();

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return ServiceResult.failure('No signed-in account was found.');
      }

      if (refreshedUser.emailVerified) {
        return ServiceResult.success(null);
      }

      await refreshedUser.sendEmailVerification();
      return ServiceResult.success(null);
    } on FirebaseAuthException catch (error) {
      return ServiceResult.failure(_friendlyError(error));
    } catch (_) {
      return ServiceResult.failure(
        'Unable to send the verification email. Please try again.',
      );
    }
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> refreshCurrentUser() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return ServiceResult.failure('No signed-in account was found.');
      }

      await user.reload();

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return ServiceResult.failure('No signed-in account was found.');
      }

      await refreshedUser.getIdToken(true);

      if (refreshedUser.isAnonymous) {
        final guest = ChurchSnapUser.guest(id: refreshedUser.uid);
        _cachedUser = guest;
        return ServiceResult.success(guest);
      }

      final appUser = await _loadOrCreateUser(refreshedUser);
      _cachedUser = appUser;

      return ServiceResult.success(appUser);
    } on FirebaseAuthException catch (error) {
      return ServiceResult.failure(_friendlyError(error));
    } catch (_) {
      return ServiceResult.failure(
        'Unable to refresh your account. Please try again.',
      );
    }
  }

  @override
  Future<ServiceResult<void>> signOut() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        if (currentUser.isAnonymous) {
          try {
            await currentUser.delete();
          } on FirebaseAuthException {
            // Sign-out still proceeds if anonymous account cleanup fails.
          }
        } else {
          await _removeCurrentMessagingToken(currentUser);
        }
      }

      await _auth.signOut();
      _cachedUser = null;
      return ServiceResult.success(null);
    } on FirebaseAuthException catch (error) {
      return ServiceResult.failure(_friendlyError(error));
    } catch (_) {
      return ServiceResult.failure('Unable to sign out. Please try again.');
    }
  }

  Future<ChurchSnapUser> _loadOrCreateUser(User user) async {
    if (user.isAnonymous) {
      return ChurchSnapUser.guest(id: user.uid);
    }

    final memberReference = _firestore
        .collection(FirebasePaths.members(defaultChurchId))
        .doc(user.uid);

    final snapshot = await memberReference.get();
    final data = snapshot.data();

    if (snapshot.exists && data != null) {
      final savedUser = ChurchSnapUser(
        id: user.uid,
        churchId: defaultChurchId,
        displayName:
            data['displayName'] as String? ??
            user.displayName ??
            'ChurchSnap Member',
        email: data['email'] as String? ?? user.email ?? '',
        role: data['role'] as String? ?? 'member',
        isEmailVerified: user.emailVerified,
        isActive: data['isActive'] as bool? ?? true,
      );

      await memberReference.set(savedUser.toMap(), SetOptions(merge: true));

      return savedUser;
    }

    final appUser = ChurchSnapUser(
      id: user.uid,
      churchId: defaultChurchId,
      displayName: user.displayName ?? 'ChurchSnap Member',
      email: user.email ?? '',
      role: 'member',
      isEmailVerified: user.emailVerified,
      isActive: true,
    );

    return _saveUser(appUser);
  }

  Future<ChurchSnapUser> _saveUser(ChurchSnapUser user) async {
    final memberReference = _firestore
        .collection(FirebasePaths.members(user.churchId))
        .doc(user.id);

    final memberSnapshot = await memberReference.get();
    final existingData = memberSnapshot.data();

    final savedRole = memberSnapshot.exists
        ? (existingData?['role'] as String?) ?? user.role
        : user.role;

    final savedIsActive = memberSnapshot.exists
        ? (existingData?['isActive'] as bool?) ?? true
        : user.isActive;

    final savedUser = ChurchSnapUser(
      id: user.id,
      churchId: user.churchId,
      displayName: user.displayName,
      email: user.email,
      role: savedRole,
      isEmailVerified: user.isEmailVerified,
      isActive: savedIsActive,
    );

    await memberReference.set(savedUser.toMap(), SetOptions(merge: true));

    return savedUser;
  }

  Future<void> _removeCurrentMessagingToken(User user) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        final memberReference = _firestore
            .collection(FirebasePaths.members(defaultChurchId))
            .doc(user.uid);

        final memberSnapshot = await memberReference.get();
        final savedToken = memberSnapshot.data()?['fcmToken'] as String?;

        if (savedToken == token) {
          await memberReference.update({
            'fcmToken': FieldValue.delete(),
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // Notification cleanup is best-effort and must not block sign-out.
    }
  }

  String _friendlyError(FirebaseAuthException error) {
    switch (error.code) {
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
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'requires-recent-login':
        return 'Please sign in again before continuing.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
}
