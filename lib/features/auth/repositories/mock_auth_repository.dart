import '../../../core/services/service_result.dart';
import '../models/churchsnap_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  ChurchSnapUser? _currentUser;

  @override
  ChurchSnapUser? get currentUser => _currentUser;

  @override
  Future<ServiceResult<ChurchSnapUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return ServiceResult.failure('Email and password are required.');
    }
    _currentUser = ChurchSnapUser(
      id: 'demo-member-001',
      churchId: 'demo-church',
      displayName: 'ChurchSnap Member',
      email: email.trim(),
      role: 'member',
      isEmailVerified: true,
    );
    return ServiceResult.success(_currentUser!);
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> createAccount({
    required String displayName,
    required String email,
    required String password,
    required String churchId,
  }) async {
    if (displayName.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().length < 6) {
      return ServiceResult.failure(
        'Please enter a name, email, and password with at least 6 characters.',
      );
    }
    _currentUser = ChurchSnapUser(
      id: 'demo-new-member',
      churchId: churchId.trim().isEmpty ? 'demo-church' : churchId.trim(),
      displayName: displayName.trim(),
      email: email.trim(),
      role: 'member',
    );
    return ServiceResult.success(_currentUser!);
  }

  @override
  Future<ServiceResult<void>> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      return ServiceResult.failure('Email is required.');
    }
    return ServiceResult.success(null);
  }

  @override
  Future<ServiceResult<void>> signOut() async {
    _currentUser = null;
    return ServiceResult.success(null);
  }
}
