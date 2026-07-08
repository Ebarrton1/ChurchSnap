import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/member_repository.dart';
import '../services/member_service.dart';

final memberRepositoryProvider = Provider<MemberRepository>(
  (ref) => MemberRepository(),
);

final memberServiceProvider = Provider<MemberService>(
  (ref) => MemberService(ref.read(memberRepositoryProvider)),
);
