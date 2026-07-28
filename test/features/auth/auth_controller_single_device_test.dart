import 'package:churchsnap/core/services/service_result.dart';
import 'package:churchsnap/features/auth/models/churchsnap_user.dart';
import 'package:churchsnap/features/auth/repositories/auth_repository.dart';
import 'package:churchsnap/features/auth/services/account_session_service.dart';
import 'package:churchsnap/features/auth/state/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

final testUser = ChurchSnapUser(
  id: 'user-1',
  churchId: 'church-1',
  displayName: 'Test Member',
  email: 'member@example.com',
  role: 'member',
  isEmailVerified: true,
  isActive: true,
);

Future<void> settleController() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test('email sign-in claims the current device session', () async {
    final repository = _FakeAuthRepository();
    final sessions = _FakeAccountSessionService();
    final controller = AuthController(
      repository: repository,
      accountSessionService: sessions,
    );

    await settleController();

    final signedIn = await controller.signIn('member@example.com', 'password');

    expect(signedIn, isTrue);
    expect(controller.isSignedIn, isTrue);
    expect(sessions.claimCalls, 1);
    expect(sessions.lastClaimedUserId, testUser.id);
    expect(sessions.lastClaimedChurchId, testUser.churchId);
  });

  test('a restored session owned by another device is rejected', () async {
    final repository = _FakeAuthRepository(restoredUser: testUser);
    final sessions = _FakeAccountSessionService(restoreAllowed: false);

    final controller = AuthController(
      repository: repository,
      accountSessionService: sessions,
    );

    await settleController();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.currentUser, isNull);
    expect(repository.signOutCalls, 1);
    expect(controller.errorMessage, contains('active on another device'));
  });

  test(
    'a displaced device signs out without releasing the new session',
    () async {
      final repository = _FakeAuthRepository();
      final sessions = _FakeAccountSessionService();
      final controller = AuthController(
        repository: repository,
        accountSessionService: sessions,
      );

      await settleController();
      await controller.signIn('member@example.com', 'password');

      await controller.endSessionReplaced();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(controller.currentUser, isNull);
      expect(repository.signOutCalls, 1);
      expect(sessions.releaseCalls, 0);
      expect(controller.errorMessage, contains('signed in on another device'));
    },
  );

  test('normal sign-out releases only the current device session', () async {
    final repository = _FakeAuthRepository();
    final sessions = _FakeAccountSessionService();
    final controller = AuthController(
      repository: repository,
      accountSessionService: sessions,
    );

    await settleController();
    await controller.signIn('member@example.com', 'password');

    final signedOut = await controller.signOut();

    expect(signedOut, isTrue);
    expect(sessions.releaseCalls, 1);
    expect(repository.signOutCalls, 1);
    expect(controller.status, AuthStatus.unauthenticated);
  });
}

class _FakeAccountSessionService implements AccountSessionService {
  _FakeAccountSessionService({this.restoreAllowed = true});

  final bool restoreAllowed;

  int claimCalls = 0;
  int releaseCalls = 0;
  String? lastClaimedUserId;
  String? lastClaimedChurchId;

  @override
  String? get currentSessionId => 'local-session-id-12345678901234567890';

  @override
  Future<void> claimSession({
    required String userId,
    required String churchId,
  }) async {
    claimCalls++;
    lastClaimedUserId = userId;
    lastClaimedChurchId = churchId;
  }

  @override
  Future<void> releaseSession({required String userId}) async {
    releaseCalls++;
  }

  @override
  Future<bool> restoreSession({
    required String userId,
    required String churchId,
  }) async {
    return restoreAllowed;
  }

  @override
  Stream<AccountSessionRecord> watchSession(String userId) {
    return Stream<AccountSessionRecord>.value(
      const AccountSessionRecord(
        exists: true,
        sessionId: 'local-session-id-12345678901234567890',
        isFromCache: false,
      ),
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.restoredUser});

  final ChurchSnapUser? restoredUser;

  int signOutCalls = 0;
  ChurchSnapUser? _currentUser;

  @override
  ChurchSnapUser? get currentUser => _currentUser;

  @override
  Future<ServiceResult<ChurchSnapUser>> createAccount({
    required String displayName,
    required String email,
    required String password,
    required String churchId,
  }) async {
    _currentUser = testUser;
    return ServiceResult<ChurchSnapUser>.success(testUser);
  }

  @override
  Future<ChurchSnapUser?> restoreCurrentUser() async {
    _currentUser = restoredUser;
    return restoredUser;
  }

  @override
  Future<ServiceResult<void>> sendEmailVerification() async {
    return ServiceResult<void>.success(null);
  }

  @override
  Future<ServiceResult<void>> sendPasswordReset(String email) async {
    return ServiceResult<void>.success(null);
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> refreshCurrentUser() async {
    return ServiceResult<ChurchSnapUser>.success(_currentUser ?? testUser);
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> signInAsVisitor({
    required String churchId,
  }) async {
    _currentUser = ChurchSnapUser(
      id: 'guest',
      churchId: 'church-1',
      displayName: 'Guest Visitor',
      email: '',
      role: 'visitor',
      isEmailVerified: true,
      isActive: true,
    );

    return ServiceResult<ChurchSnapUser>.success(_currentUser!);
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    _currentUser = testUser;
    return ServiceResult<ChurchSnapUser>.success(testUser);
  }

  @override
  Future<ServiceResult<void>> signOut() async {
    signOutCalls++;
    _currentUser = null;
    return ServiceResult<void>.success(null);
  }
}
