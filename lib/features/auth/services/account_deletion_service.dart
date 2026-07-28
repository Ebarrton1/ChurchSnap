import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDeletionResult {
  const AccountDeletionResult._({required this.isSuccess, this.errorMessage});

  const AccountDeletionResult.success() : this._(isSuccess: true);

  const AccountDeletionResult.failure(String message)
    : this._(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
}

abstract class AccountDeletionService {
  Future<AccountDeletionResult> deleteAccount({
    required String password,
    required String churchId,
  });
}

class FirebaseAccountDeletionService implements AccountDeletionService {
  FirebaseAccountDeletionService({
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  @override
  Future<AccountDeletionResult> deleteAccount({
    required String password,
    required String churchId,
  }) async {
    final normalizedPassword = password.trim();
    final normalizedChurchId = churchId.trim();

    if (normalizedPassword.isEmpty) {
      return const AccountDeletionResult.failure(
        'Enter your current password.',
      );
    }

    if (normalizedChurchId.isEmpty) {
      return const AccountDeletionResult.failure(
        'Your connected church could not be identified.',
      );
    }

    final user = _auth.currentUser;
    final email = user?.email?.trim() ?? '';

    if (user == null || email.isEmpty || user.isAnonymous) {
      return const AccountDeletionResult.failure(
        'Only registered email accounts can be deleted here.',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: normalizedPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.getIdToken(true);

      final callable = _functions.httpsCallable(
        'deleteChurchSnapAccount',
        options: HttpsCallableOptions(timeout: const Duration(minutes: 9)),
      );

      final result = await callable.call<Map<String, dynamic>>(
        <String, dynamic>{
          'churchId': normalizedChurchId,
          'confirmation': 'DELETE',
        },
      );

      final data = result.data;

      if (data['deleted'] != true) {
        return const AccountDeletionResult.failure(
          'ChurchSnap did not confirm that the account was deleted.',
        );
      }

      return const AccountDeletionResult.success();
    } on FirebaseAuthException catch (error) {
      return AccountDeletionResult.failure(_authError(error));
    } on FirebaseFunctionsException catch (error) {
      return AccountDeletionResult.failure(_functionsError(error));
    } catch (_) {
      return const AccountDeletionResult.failure(
        'ChurchSnap could not delete the account. Check your connection '
        'and try again.',
      );
    }
  }

  String _authError(FirebaseAuthException error) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'The password is incorrect.';
      case 'requires-recent-login':
        return 'Sign out, sign in again, and retry account deletion.';
      case 'too-many-requests':
        return 'Too many attempts. Wait before trying again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Account verification failed.';
    }
  }

  String _functionsError(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'failed-precondition':
        return error.message ??
            'Transfer protected church responsibilities before deletion.';
      case 'permission-denied':
        return 'ChurchSnap could not verify the connected church.';
      case 'unauthenticated':
        return 'Sign in again before deleting the account.';
      case 'invalid-argument':
        return error.message ?? 'The deletion request was incomplete.';
      case 'unavailable':
        return 'The deletion service is temporarily unavailable.';
      default:
        return error.message ??
            'ChurchSnap could not complete account deletion.';
    }
  }
}
