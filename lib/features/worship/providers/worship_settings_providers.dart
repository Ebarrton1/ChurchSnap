import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/worship_settings.dart';
import '../repositories/worship_settings_repository.dart';

final worshipSettingsRepositoryProvider =
    Provider.family<WorshipSettingsRepository, String>((ref, churchId) {
      return WorshipSettingsRepository(churchId: churchId);
    });

final worshipSettingsProvider = StreamProvider.family<WorshipSettings, String>((
  ref,
  churchId,
) {
  return ref.watch(worshipSettingsRepositoryProvider(churchId)).watchSettings();
});
