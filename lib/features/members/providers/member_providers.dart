import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/member_repository.dart';
import '../services/member_service.dart';

final memberRepositoryProvider = Provider<MemberRepository>(
  (ref) => MemberRepository(),
);

final memberServiceProvider = Provider<MemberService>(
  (ref) => MemberService(ref.read(memberRepositoryProvider)),
);

final memberRepositoryByChurchProvider =
    Provider.family<MemberRepository, String>((ref, churchId) {
      return MemberRepository(churchId: churchId);
    });

final memberServiceByChurchProvider = Provider.family<MemberService, String>((
  ref,
  churchId,
) {
  return MemberService(ref.read(memberRepositoryByChurchProvider(churchId)));
});
