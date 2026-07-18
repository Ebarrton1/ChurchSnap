import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member_directory_entry.dart';
import '../repositories/member_directory_repository.dart';

final memberDirectoryRepositoryByChurchProvider =
    Provider.family<MemberDirectoryRepository, String>((ref, churchId) {
      return MemberDirectoryRepository(churchId: churchId);
    });

final memberDirectoryEntriesByChurchProvider =
    StreamProvider.family<List<MemberDirectoryEntry>, String>((ref, churchId) {
      return ref
          .watch(memberDirectoryRepositoryByChurchProvider(churchId))
          .watchEntries();
    });
