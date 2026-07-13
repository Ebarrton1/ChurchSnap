import 'package:flutter/foundation.dart';

import '../../../core/auth/app_roles.dart';
import '../../../core/services/service_result.dart';
import '../models/churchsnap_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firebase/firebase_auth_repository_stub.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
    : _repository = repository ?? FirebaseAuthRepository() {
    _restoreSession();
  }

  final AuthRepository _repository;

  ChurchSnapUser? _currentUser;
  AuthStatus _status = AuthStatus.loading;
  String? _errorMessage;

  ChurchSnapUser? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isSignedIn =>
      _status == AuthStatus.authenticated && _currentUser != null;

  bool get isAdmin => AppRoles.canAccessAdmin(_currentUser?.role ?? '');

  Future<void> _restoreSession() async {
    _status = AuthStatus.loading;
    _errorMessage = null;

    try {
      final restoredUser = await _repository.restoreCurrentUser();

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

    return _handleAuthResult(result);
  }

  Future<bool> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      _errorMessage = 'Enter your email address first.';
      notifyListeners();
      return false;
    }

    // Password reset must not switch the entire authentication gate to the
    // loading screen. Doing so disposes LoginScreen before its confirmation
    // dialog can be displayed.
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

  void continueAsGuest() {
    _currentUser = const ChurchSnapUser(
      id: 'guest',
      churchId: 'demo-church',
      displayName: 'Guest Visitor',
      email: 'guest@churchsnap.local',
      role: 'visitor',
      isEmailVerified: false,
    );

    _status = AuthStatus.authenticated;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
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
