import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/church_resource.dart';
import '../repositories/church_resource_repository.dart';

final churchResourceRepositoryByChurchProvider =
    Provider.family<ChurchResourceRepository, String>((ref, churchId) {
      return ChurchResourceRepository(churchId: churchId);
    });

final publishedChurchResourcesByChurchProvider =
    StreamProvider.family<List<ChurchResource>, String>((ref, churchId) {
      return ref
          .watch(churchResourceRepositoryByChurchProvider(churchId))
          .watchPublishedResources();
    });

final adminChurchResourcesByChurchProvider =
    StreamProvider.family<List<ChurchResource>, String>((ref, churchId) {
      return ref
          .watch(churchResourceRepositoryByChurchProvider(churchId))
          .watchAllResources();
    });
