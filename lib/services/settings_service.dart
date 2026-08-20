import 'package:hive_flutter/hive_flutter.dart';

import '../models/settings.dart';

/// Persistent storage for [AppSettings] using a single Hive box of primitives.
class SettingsService {
  static const String _boxName = 'ignis_settings';
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static AppSettings get current => AppSettings(
        fontFamily: _box.get('fontFamily') as String?,
        fontSize: (_box.get('fontSize') as double?) ?? 16.0,
      );

  static Future<void> save(AppSettings settings) async {
    await _box.put('fontFamily', settings.fontFamily);
    await _box.put('fontSize', settings.fontSize);
  }
}
