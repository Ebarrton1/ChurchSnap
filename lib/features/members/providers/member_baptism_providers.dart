import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member_baptism_record.dart';
import '../repositories/member_baptism_repository.dart';

final memberBaptismRepositoryProvider =
    Provider.family<MemberBaptismRepository, String>((ref, churchId) {
      return MemberBaptismRepository(churchId: churchId);
    });

final memberBaptismRecordsProvider =
    StreamProvider.family<List<MemberBaptismRecord>, String>((ref, churchId) {
      return ref
          .watch(memberBaptismRepositoryProvider(churchId))
          .watchRecords();
    });

final recentBaptismsByChurchProvider =
    StreamProvider.family<List<MemberBaptismRecord>, String>((ref, churchId) {
      return ref
          .watch(memberBaptismRepositoryProvider(churchId))
          .watchRecords()
          .map((records) => MemberBaptismCalculator.recent(records: records));
    });

final recentBaptismCountProvider = StreamProvider.family<int, String>((
  ref,
  churchId,
) {
  return ref
      .watch(memberBaptismRepositoryProvider(churchId))
      .watchRecords()
      .map(
        (records) => MemberBaptismCalculator.recent(records: records).length,
      );
});
