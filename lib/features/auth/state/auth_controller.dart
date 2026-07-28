import 'package:flutter/foundation.dart';

import '../../../core/auth/app_roles.dart';
import '../../../core/services/service_result.dart';
import '../models/churchsnap_user.dart';
import '../models/live_member_access.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firebase/firebase_auth_repository_stub.dart';
import '../services/account_session_service.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthController extends ChangeNotifier {
  AuthController({
    AuthRepository? repository,
    AccountSessionService? accountSessionService,
  }) : _repository = repository ?? FirebaseAuthRepository(),
       _accountSessionService =
           accountSessionService ??
           (repository == null
               ? FirebaseAccountSessionService()
               : NoopAccountSessionService()) {
    _restoreSession();
  }

  final AuthRepository _repository;
  final AccountSessionService _accountSessionService;

  ChurchSnapUser? _currentUser;
  AuthStatus _status = AuthStatus.loading;
  String? _errorMessage;
  bool _endingReplacedSession = false;

  ChurchSnapUser? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get currentSessionId => _accountSessionService.currentSessionId;

  bool get isSignedIn =>
      _status == AuthStatus.authenticated && _currentUser != null;

  bool get isAdmin => AppRoles.canAccessAdmin(_currentUser?.role ?? '');

  bool get isVisitor => AppRoles.isVisitor(_currentUser?.role ?? '');

  bool get canAccessMemberPrivate =>
      AppRoles.canAccessMemberPrivate(_currentUser?.role ?? '');

  bool get isGuest {
    final user = _currentUser;

    if (user == null || user.role != 'visitor') {
      return false;
    }

    return user.email.trim().isEmpty;
  }

  Stream<AccountSessionRecord> watchAccountSession(String userId) {
    return _accountSessionService.watchSession(userId);
  }

  Future<void> _restoreSession() async {
    _status = AuthStatus.loading;
    _errorMessage = null;

    try {
      final restoredUser = await _repository.restoreCurrentUser();

      if (restoredUser != null && !_isGuestUser(restoredUser)) {
        final sessionIsActive = await _accountSessionService.restoreSession(
          userId: restoredUser.id,
          churchId: restoredUser.churchId,
        );

        if (!sessionIsActive) {
          await _repository.signOut();

          _currentUser = null;
          _status = AuthStatus.unauthenticated;
          _errorMessage =
              'Your ChurchSnap account is active on another device. '
              'Sign in again to use this device instead.';

          notifyListeners();
          return;
        }
      }

      _currentUser = restoredUser;
      _status = restoredUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } catch (error) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Unable to restore your ChurchSnap session.';
      debugPrint('Session restoration failed: $error');
    }

    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading();

    final result = await _repository.signInWithEmail(email, password);
    final signedIn = _handleAuthResult(result);

    if (!signedIn) {
      return false;
    }

    if (!await _activateSingleDeviceSession()) {
      return false;
    }

    final signedInUser = _currentUser;

    if (signedInUser != null && !signedInUser.isEmailVerified) {
      final verificationResult = await _repository.sendEmailVerification();

      _currentUser = signedInUser;
      _status = AuthStatus.authenticated;
      _errorMessage = verificationResult.isSuccess
          ? null
          : verificationResult.errorMessage ??
                'Unable to send the verification email.';

      notifyListeners();
    }

    return true;
  }

  Future<bool> createAccount({
    required String displayName,
    required String email,
    required String password,
    required String churchId,
  }) async {
    _setLoading();

    final result = await _repository.createAccount(
      displayName: displayName,
      email: email,
      password: password,
      churchId: churchId,
    );

    if (!_handleAuthResult(result)) {
      return false;
    }

    return _activateSingleDeviceSession();
  }

  Future<bool> continueAsVisitor({required String churchId}) async {
    _setLoading();

    final result = await _repository.signInAsVisitor(churchId: churchId);

    return _handleAuthResult(result);
  }

  Future<bool> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      _errorMessage = 'Enter your email address first.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();

    final result = await _repository.sendPasswordReset(email);

    _errorMessage = result.isSuccess ? null : result.errorMessage;

    notifyListeners();
    return result.isSuccess;
  }

  Future<bool> resendEmailVerification() async {
    final existingUser = _currentUser;

    if (existingUser == null) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'No signed-in account was found.';
      notifyListeners();
      return false;
    }

    _setLoading();

    final result = await _repository.sendEmailVerification();

    _currentUser = existingUser;
    _status = AuthStatus.authenticated;
    _errorMessage = result.isSuccess ? null : result.errorMessage;

    notifyListeners();
    return result.isSuccess;
  }

  Future<bool> refreshEmailVerification() async {
    final existingUser = _currentUser;

    if (existingUser == null) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'No signed-in account was found.';
      notifyListeners();
      return false;
    }

    _setLoading();

    final result = await _repository.refreshCurrentUser();

    if (result.isSuccess && result.data != null) {
      _currentUser = result.data;
      _status = AuthStatus.authenticated;

      if (result.data!.isEmailVerified) {
        _errorMessage = null;
        notifyListeners();
        return true;
      }

      _errorMessage =
          'Your email is not verified yet. Open the verification link, '
          'then check again.';
      notifyListeners();
      return false;
    }

    _currentUser = existingUser;
    _status = AuthStatus.authenticated;
    _errorMessage = result.errorMessage ?? 'Unable to refresh your account.';

    notifyListeners();
    return false;
  }

  Future<bool> signOut() async {
    final existingUser = _currentUser;

    _setLoading();

    if (existingUser != null && !_isGuestUser(existingUser)) {
      try {
        await _accountSessionService.releaseSession(userId: existingUser.id);
      } catch (error) {
        debugPrint('Unable to release the account session: $error');
      }
    }

    final result = await _repository.signOut();

    if (result.isSuccess) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;

      notifyListeners();
      return true;
    }

    _currentUser = existingUser;
    _status = existingUser == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    _errorMessage = result.errorMessage ?? 'Unable to sign out.';

    notifyListeners();
    return false;
  }

  Future<void> endSessionReplaced() async {
    if (_endingReplacedSession) {
      return;
    }

    _endingReplacedSession = true;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signOut();
    } catch (error) {
      debugPrint('Unable to close the replaced account session: $error');
    }

    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage =
        'Your ChurchSnap account was signed in on another device. '
        'This device has been signed out for your protection.';
    _endingReplacedSession = false;

    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void applyLiveMemberAccess(LiveMemberAccess access) {
    final existingUser = _currentUser;

    if (existingUser == null || existingUser.id == 'guest') {
      return;
    }

    if (!access.differsFrom(existingUser)) {
      return;
    }

    _currentUser = access.mergeWith(existingUser);
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _activateSingleDeviceSession() async {
    final user = _currentUser;

    if (user == null || _isGuestUser(user)) {
      return true;
    }

    try {
      await _accountSessionService.claimSession(
        userId: user.id,
        churchId: user.churchId,
      );

      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Unable to claim the account session: $error');
      await _repository.signOut();

      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage =
          'ChurchSnap could not secure this device session. '
          'Check your connection and sign in again.';

      notifyListeners();
      return false;
    }
  }

  bool _isGuestUser(ChurchSnapUser user) {
    return user.role == 'visitor' && user.email.trim().isEmpty;
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  bool _handleAuthResult(ServiceResult<ChurchSnapUser> result) {
    if (result.isSuccess && result.data != null) {
      _currentUser = result.data;
      _status = AuthStatus.authenticated;
      _errorMessage = null;

      notifyListeners();
      return true;
    }

    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = result.errorMessage ?? 'Authentication failed.';

    notifyListeners();
    return false;
  }
}
