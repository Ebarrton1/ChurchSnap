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
    final normalizedChurchId = churchId.trim();

    if (normalizedName.isEmpty) {
      return ServiceResult.failure('Enter your full name.');
    }

    if (normalizedEmail.isEmpty) {
      return ServiceResult.failure('Enter your email address.');
    }

    if (password.length < 6) {
      return ServiceResult.failure('Password must be at least 6 characters.');
    }

    if (normalizedChurchId.isEmpty) {
      return ServiceResult.failure('Choose your church.');
    }

    try {
      if (!await _churchAcceptsVisitors(normalizedChurchId)) {
        return ServiceResult.failure(
          'The selected church is not accepting visitor connections.',
        );
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
        churchId: normalizedChurchId,
        displayName: normalizedName,
        email: refreshedUser.email ?? normalizedEmail,
        role: 'visitor',
        isEmailVerified: refreshedUser.emailVerified,
        isActive: true,
      );

      final savedUser = await _saveUser(appUser);
      await _saveChurchLink(
        userId: refreshedUser.uid,
        churchId: normalizedChurchId,
      );

      if (!refreshedUser.emailVerified) {
        try {
          await refreshedUser.sendEmailVerification();
        } on FirebaseAuthException {
          // The verification screen provides a resend action.
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
  Future<ServiceResult<ChurchSnapUser>> signInAsVisitor({
    required String churchId,
  }) async {
    final normalizedChurchId = churchId.trim();

    if (normalizedChurchId.isEmpty) {
      return ServiceResult.failure('Choose a church first.');
    }

    try {
      if (!await _churchAcceptsVisitors(normalizedChurchId)) {
        return ServiceResult.failure(
          'This church is not accepting visitor connections.',
        );
      }

      final existingUser = _auth.currentUser;

      if (existingUser != null && !existingUser.isAnonymous) {
        await _auth.signOut();
      }

      User? visitorUser = _auth.currentUser;

      if (visitorUser == null || !visitorUser.isAnonymous) {
        final credential = await _auth.signInAnonymously();
        visitorUser = credential.user;
      }

      if (visitorUser == null) {
        return ServiceResult.failure('Unable to start visitor access.');
      }

      final appUser = ChurchSnapUser(
        id: visitorUser.uid,
        churchId: normalizedChurchId,
        displayName: 'Guest Visitor',
        email: '',
        role: 'visitor',
        isEmailVerified: true,
        isActive: true,
      );

      final savedUser = await _saveUser(appUser);
      await _saveChurchLink(
        userId: visitorUser.uid,
        churchId: normalizedChurchId,
      );

      _cachedUser = savedUser;
      return ServiceResult.success(savedUser);
    } on FirebaseAuthException catch (error) {
      return ServiceResult.failure(_friendlyError(error));
    } catch (_) {
      return ServiceResult.failure('Visitor access failed. Please try again.');
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
        return ServiceResult.success(null);
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
    final churchId = await _resolveChurchId(user.uid);
    final memberReference = _firestore
        .collection(FirebasePaths.members(churchId))
        .doc(user.uid);

    final snapshot = await memberReference.get();
    final data = snapshot.data();

    if (snapshot.exists && data != null) {
      final savedUser = ChurchSnapUser(
        id: user.uid,
        churchId: churchId,
        displayName:
            data['displayName'] as String? ??
            user.displayName ??
            (user.isAnonymous ? 'Guest Visitor' : 'ChurchSnap Member'),
        email: data['email'] as String? ?? user.email ?? '',
        role:
            data['role'] as String? ??
            (user.isAnonymous ? 'visitor' : 'member'),
        isEmailVerified: user.isAnonymous || user.emailVerified,
        isActive: data['isActive'] as bool? ?? true,
      );

      await memberReference.set(savedUser.toMap(), SetOptions(merge: true));
      await _saveChurchLink(userId: user.uid, churchId: churchId);

      return savedUser;
    }

    final appUser = ChurchSnapUser(
      id: user.uid,
      churchId: churchId,
      displayName: user.isAnonymous
          ? 'Guest Visitor'
          : user.displayName ?? 'ChurchSnap Member',
      email: user.email ?? '',
      role: 'visitor',
      isEmailVerified: user.isAnonymous || user.emailVerified,
      isActive: true,
    );

    final savedUser = await _saveUser(appUser);
    await _saveChurchLink(userId: user.uid, churchId: churchId);

    return savedUser;
  }

  Future<String> _resolveChurchId(String userId) async {
    final linkSnapshot = await _firestore
        .collection('userChurchLinks')
        .doc(userId)
        .get();

    final linkedChurchId = (linkSnapshot.data()?['churchId'] as String? ?? '')
        .trim();

    if (linkedChurchId.isNotEmpty) {
      return linkedChurchId;
    }

    final defaultMemberSnapshot = await _firestore
        .collection(FirebasePaths.members(defaultChurchId))
        .doc(userId)
        .get();

    if (defaultMemberSnapshot.exists) {
      return defaultChurchId;
    }

    return defaultChurchId;
  }

  Future<bool> _churchAcceptsVisitors(String churchId) async {
    final snapshot = await _firestore
        .collection('churches')
        .doc(churchId)
        .get();

    if (!snapshot.exists) {
      return false;
    }

    final data = snapshot.data() ?? const <String, dynamic>{};

    return (data['isActive'] as bool? ?? true) &&
        (data['visitorAccessEnabled'] as bool? ?? true);
  }

  Future<void> _saveChurchLink({
    required String userId,
    required String churchId,
  }) async {
    await _firestore.collection('userChurchLinks').doc(userId).set(
      <String, dynamic>{
        'churchId': churchId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
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
        return 'Visitor access is not enabled in Firebase Authentication.';
      case 'requires-recent-login':
        return 'Please sign in again before continuing.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
}
