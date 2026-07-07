import 'package:flutter/foundation.dart';

import '../../../core/services/service_result.dart';
import '../models/churchsnap_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firebase/firebase_auth_repository_stub.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
    : _repository = repository ?? FirebaseAuthRepository() {
    _currentUser = _repository.currentUser;
    _status = _currentUser == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
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
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> signIn(String email, String password) async {
    _setLoading();
    final result = await _repository.signInWithEmail(email, password);
    return _handleAuthResult(result);
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
    _setLoading();
    final result = await _repository.sendPasswordReset(email);
    _status = _currentUser == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    _errorMessage = result.isSuccess ? null : result.errorMessage;
    notifyListeners();
    return result.isSuccess;
  }

  Future<void> signOut() async {
    _setLoading();
    await _repository.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
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
