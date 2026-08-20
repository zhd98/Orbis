import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/settings.dart';
import '../services/settings_service.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(SettingsService.current);

  Future<void> update(AppSettings settings) async {
    state = settings;
    await SettingsService.save(settings);
  }

  /// Set the editor font. [fontFamily] = null restores the system default.
  Future<void> setFont(String? fontFamily) =>
      update(AppSettings(fontFamily: fontFamily, fontSize: state.fontSize));
}
