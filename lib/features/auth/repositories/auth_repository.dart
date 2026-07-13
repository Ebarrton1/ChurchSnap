import '../../../core/services/service_result.dart';
import '../models/churchsnap_user.dart';

abstract class AuthRepository {
  ChurchSnapUser? get currentUser;

  Future<ChurchSnapUser?> restoreCurrentUser();

  Future<ServiceResult<ChurchSnapUser>> signInWithEmail(
    String email,
    String password,
  );

  Future<ServiceResult<ChurchSnapUser>> createAccount({
    required String displayName,
    required String email,
    required String password,
    required String churchId,
  });

  Future<ServiceResult<void>> sendPasswordReset(String email);

  Future<ServiceResult<void>> sendEmailVerification();

  Future<ServiceResult<ChurchSnapUser>> refreshCurrentUser();

  Future<ServiceResult<void>> signOut();
}
