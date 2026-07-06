import 'service_result.dart';

class AppUser {
  final String id;
  final String displayName;
  final String email;
  final String role;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.role = 'member',
  });
}

abstract class AuthService {
  AppUser? get currentUser;
  Future<ServiceResult<AppUser>> signInWithEmail(String email, String password);
  Future<ServiceResult<void>> signOut();
}

class MockAuthService implements AuthService {
  AppUser? _currentUser = const AppUser(
    id: 'demo-member-001',
    displayName: 'Everton Barrett',
    email: 'member@churchsnap.app',
    role: 'member',
  );

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<ServiceResult<AppUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    _currentUser = AppUser(
      id: 'demo-member-001',
      displayName: 'ChurchSnap Member',
      email: email,
    );
    return ServiceResult.success(_currentUser);
  }

  @override
  Future<ServiceResult<void>> signOut() async {
    _currentUser = null;
    return ServiceResult.success(null);
  }
}
