import 'package:churchsnap/core/services/service_result.dart';
import 'package:churchsnap/features/auth/models/churchsnap_user.dart';
import 'package:churchsnap/features/auth/repositories/auth_repository.dart';
import 'package:churchsnap/features/auth/services/account_deletion_service.dart';
import 'package:churchsnap/features/auth/services/account_session_service.dart';
import 'package:churchsnap/features/auth/state/auth_controller.dart';
import 'package:churchsnap/screens/settings/account_deletion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const memberUser = ChurchSnapUser(
  id: 'member-1',
  churchId: 'church-1',
  displayName: 'Test Member',
  email: 'member@example.com',
  role: 'member',
  isEmailVerified: true,
  isActive: true,
);

Future<void> settleController() async {
  // Do not use Future.delayed here because widget tests use a fake clock.
  // Yield through microtasks so AuthController can finish restoring its user.
  for (var index = 0; index < 8; index++) {
    await Future<void>.value();
  }
}

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

void main() {
  testWidgets('registered member can complete verified deletion flow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _FakeAuthRepository(restoredUser: memberUser);
    final service = _FakeDeletionService();
    final controller = AuthController(
      repository: repository,
      accountSessionService: NoopAccountSessionService(),
    );

    addTearDown(controller.dispose);

    await settleController();

    await tester.pumpWidget(
      MaterialApp(
        home: _DeletionTestLauncher(
          authController: controller,
          deletionService: service,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('openAccountDeletion')));
    await tester.pumpAndSettle();

    final submitFinder = find.byKey(const Key('accountDeletionSubmit'));

    await scrollTo(tester, submitFinder);

    await tester.enterText(
      find.byKey(const Key('accountDeletionPassword')),
      'correct-password',
    );

    await tester.enterText(
      find.byKey(const Key('accountDeletionConfirmation')),
      'DELETE',
    );

    await tester.tap(find.byKey(const Key('accountDeletionAcknowledgement')));
    await tester.pump();

    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('accountDeletionFinalConfirm')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('accountDeletionFinalConfirm')));

    // Successful deletion returns to the first application route,
    // exactly as it does under ChurchSnap's AuthGate.
    await tester.pumpAndSettle();

    expect(service.calls, 1);
    expect(service.lastPassword, 'correct-password');
    expect(service.lastChurchId, 'church-1');
    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.currentUser, isNull);

    expect(find.byKey(const Key('deletionTestLauncher')), findsOneWidget);

    // The authenticated deletion route must be removed after sign-out.
    expect(find.byType(AccountDeletionScreen), findsNothing);
    expect(find.text('Open account deletion'), findsOneWidget);
  });

  testWidgets('administrator must transfer responsibility first', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const administrator = ChurchSnapUser(
      id: 'admin-1',
      churchId: 'church-1',
      displayName: 'Test Administrator',
      email: 'admin@example.com',
      role: 'admin',
      isEmailVerified: true,
      isActive: true,
    );

    final controller = AuthController(
      repository: _FakeAuthRepository(restoredUser: administrator),
      accountSessionService: NoopAccountSessionService(),
    );

    addTearDown(controller.dispose);

    await settleController();

    await tester.pumpWidget(
      MaterialApp(
        home: AccountDeletionScreen(
          authController: controller,
          deletionService: _FakeDeletionService(),
        ),
      ),
    );

    await scrollTo(tester, find.text('Account deletion is not available yet'));

    expect(find.textContaining('Transfer administrator'), findsOneWidget);

    expect(find.byKey(const Key('accountDeletionSubmit')), findsNothing);
  });

  testWidgets('anonymous visitor has no registered account to delete', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const guestUser = ChurchSnapUser(
      id: 'guest',
      churchId: 'church-1',
      displayName: 'Guest Visitor',
      email: '',
      role: 'visitor',
      isEmailVerified: true,
      isActive: true,
    );

    final controller = AuthController(
      repository: _FakeAuthRepository(restoredUser: guestUser),
      accountSessionService: NoopAccountSessionService(),
    );

    addTearDown(controller.dispose);

    await settleController();

    await tester.pumpWidget(
      MaterialApp(
        home: AccountDeletionScreen(
          authController: controller,
          deletionService: _FakeDeletionService(),
        ),
      ),
    );

    await scrollTo(tester, find.text('Account deletion is not available yet'));

    expect(find.textContaining('Anonymous visitor mode'), findsOneWidget);

    expect(find.byKey(const Key('accountDeletionSubmit')), findsNothing);
  });
}

class _DeletionTestLauncher extends StatelessWidget {
  const _DeletionTestLauncher({
    required this.authController,
    required this.deletionService,
  });

  final AuthController authController;
  final AccountDeletionService deletionService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('deletionTestLauncher'),
      body: Center(
        child: FilledButton(
          key: const Key('openAccountDeletion'),
          onPressed: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => AccountDeletionScreen(
                  authController: authController,
                  deletionService: deletionService,
                ),
              ),
            );
          },
          child: const Text('Open account deletion'),
        ),
      ),
    );
  }
}

class _FakeDeletionService implements AccountDeletionService {
  int calls = 0;
  String? lastPassword;
  String? lastChurchId;

  @override
  Future<AccountDeletionResult> deleteAccount({
    required String password,
    required String churchId,
  }) async {
    calls++;
    lastPassword = password;
    lastChurchId = churchId;

    return const AccountDeletionResult.success();
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.restoredUser});

  final ChurchSnapUser restoredUser;
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
    _currentUser = restoredUser;
    return ServiceResult<ChurchSnapUser>.success(restoredUser);
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> refreshCurrentUser() async {
    return ServiceResult<ChurchSnapUser>.success(_currentUser ?? restoredUser);
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
  Future<ServiceResult<ChurchSnapUser>> signInAsVisitor({
    required String churchId,
  }) async {
    _currentUser = restoredUser;
    return ServiceResult<ChurchSnapUser>.success(restoredUser);
  }

  @override
  Future<ServiceResult<ChurchSnapUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    _currentUser = restoredUser;
    return ServiceResult<ChurchSnapUser>.success(restoredUser);
  }

  @override
  Future<ServiceResult<void>> signOut() async {
    _currentUser = null;
    return ServiceResult<void>.success(null);
  }
}
